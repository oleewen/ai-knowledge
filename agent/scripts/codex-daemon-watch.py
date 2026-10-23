#!/usr/bin/env python3
"""Restart a running Codex desktop app when a new managed daemon is observed."""
import argparse
from contextlib import contextmanager
import fcntl
import json
import logging
from logging.handlers import RotatingFileHandler
import os
from pathlib import Path
import signal
import subprocess
import time
from typing import Callable, Iterator, List, Optional, Protocol, TypedDict

LOG = logging.getLogger("codex-daemon-watch")


def read_identity(pid_file: Path) -> Optional[str]:
    """Validate the published PID against the live process before trusting its identity."""
    try:
        record = json.loads(pid_file.read_text())
        if not isinstance(record, dict):
            return None
        pid = record.get("pid")
        start = record.get("processStartTime")
        if type(pid) is not int or pid <= 1 or not isinstance(start, str) or not start:
            return None
        output = subprocess.check_output(
            ["/bin/ps", "-p", str(pid), "-o", "lstart=", "-o", "command="],
            text=True, stderr=subprocess.DEVNULL, timeout=2,
            env=dict(os.environ, LC_ALL="C"),
        )
        fields = output.split()
        if " ".join(fields[:5]) != " ".join(start.split()):
            return None
        if "app-server" not in fields[5:] or "--managed-daemon" not in fields[5:]:
            return None
        return json.dumps([pid, start, record.get("processIdentity")], sort_keys=True)
    except (FileNotFoundError, json.JSONDecodeError, UnicodeError,
            subprocess.CalledProcessError, subprocess.TimeoutExpired):
        return None


@contextmanager
def singleton(path: Path) -> Iterator[bool]:
    """Hold an OS lock; process exit automatically releases it, including after a crash."""
    with path.open("a") as handle:
        try:
            fcntl.flock(handle, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            yield False
            return
        try:
            yield True
        finally:
            fcntl.flock(handle, fcntl.LOCK_UN)


class App(TypedDict):
    pid: int
    path: str


class Desktop(Protocol):
    def apps(self) -> List[App]: ...
    def quit(self, app: App) -> bool: ...
    def open(self, path: str) -> None: ...


class MacDesktop:
    """Use AppKit identities, never a broad process-name match or ambiguous bundle launch."""

    @staticmethod
    def _jxa(script: str, *args: str) -> str:
        result = subprocess.run(
            ["/usr/bin/osascript", "-l", "JavaScript", "-e", script, *args],
            text=True, capture_output=True, check=True, timeout=5,
        )
        return result.stdout.strip()

    def apps(self) -> List[App]:
        result = self._jxa("""
ObjC.import('AppKit');
var apps = $.NSRunningApplication.runningApplicationsWithBundleIdentifier('com.openai.codex');
var result = [];
for (var i = 0; i < apps.count; i++) {
    var app = apps.objectAtIndex(i);
    if (!app.terminated) {
        result.push({pid: Number(app.processIdentifier), path: ObjC.unwrap(app.bundleURL.path)});
    }
}
JSON.stringify(result);
""")
        return json.loads(result)

    def quit(self, app: App) -> bool:
        # Recheck both PID and bundle path immediately before requesting normal termination.
        result = self._jxa("""
ObjC.import('AppKit');
function run(argv) {
    var app = $.NSRunningApplication.runningApplicationWithProcessIdentifier(Number(argv[0]));
    if (!app || app.isNil() || app.terminated) return 'false';
    if (ObjC.unwrap(app.bundleIdentifier) !== 'com.openai.codex' ||
        ObjC.unwrap(app.bundleURL.path) !== argv[1]) return 'false';
    return app.terminate ? 'true' : 'false';
}
""", str(app["pid"]), app["path"])
        return result == "true"

    def open(self, path: str) -> None:
        subprocess.run(
            ["/usr/bin/open", "-a", path], check=True, capture_output=True, text=True, timeout=5,
        )


def restart_desktop(
    desktop: Desktop, timeout: float = 30,
    clock: Callable[[], float] = time.monotonic,
    sleep: Callable[[float], None] = time.sleep,
) -> bool:
    """Quit normally, await exit, then reopen that exact bundle; never force-kill."""
    apps = desktop.apps()
    if not apps:
        LOG.info("Desktop is closed; skipping this daemon instance")
        return False
    if len(apps) != 1:
        LOG.error("Multiple Codex desktop instances found; refusing an ambiguous restart")
        return False
    original = apps[0]
    LOG.info("Requesting desktop quit: PID=%s path=%s", original["pid"], original["path"])
    if not desktop.quit(original):
        LOG.error("Desktop quit request declined or target changed; skipping restart")
        return False

    deadline = clock() + timeout
    while True:
        apps = desktop.apps()
        if not any(app["pid"] == original["pid"] for app in apps):
            break
        if clock() >= deadline:
            LOG.error("Desktop did not exit within %ss; no force-kill or reopen", timeout)
            return False
        sleep(min(0.5, max(0, deadline - clock())))

    # Respect a user-initiated reopen while waiting instead of launching a second copy.
    if apps:
        if len(apps) == 1 and apps[0]["path"] == original["path"]:
            LOG.info("Desktop already reopened at the expected path")
            return True
        LOG.error("Another desktop instance appeared; skipping reopen")
        return False
    desktop.open(original["path"])
    deadline = clock() + timeout
    while True:
        if any(app["path"] == original["path"] for app in desktop.apps()):
            LOG.info("Desktop restarted at %s; process detected, service readiness not checked",
                     original["path"])
            return True
        if clock() >= deadline:
            LOG.error("Desktop process not detected within %ss after open", timeout)
            return False
        sleep(min(0.5, max(0, deadline - clock())))


class Monitor:
    def __init__(
        self, reader: Callable[[], Optional[str]], restart: Callable[[], object],
        clock: Callable[[], float] = time.monotonic,
    ) -> None:
        self.reader = reader
        self.restart = restart
        self.clock = clock
        self.initialized = False
        self.last_identity: Optional[str] = None
        self.cooldown_until = 0.0

    def tick(self, identity: Optional[str]) -> None:
        if not self.initialized:
            self.initialized = True
            self.last_identity = identity
            LOG.info("Startup baseline recorded (daemon present=%s); no desktop restart",
                     identity is not None)
            return
        # A missing PID file during atomic publication must not reset the deduplication key.
        if identity is None or identity == self.last_identity:
            return
        self.last_identity = identity
        if self.clock() < self.cooldown_until:
            LOG.info("Daemon change absorbed during restart cooldown")
            return
        LOG.info("New daemon instance detected; restarting the running desktop")
        try:
            self.restart()
        except (OSError, subprocess.SubprocessError, ValueError):
            LOG.exception("Desktop restart failed; waiting for the next daemon instance")
        finally:
            # Absorb starts caused by our own desktop restart, including delayed starts.
            self.cooldown_until = self.clock() + 60
            current = self.reader()
            if current is not None:
                self.last_identity = current

    def run(self) -> None:
        while True:
            self.tick(self.reader())
            time.sleep(2)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--codex-home", type=Path,
                        default=Path(os.environ.get("CODEX_HOME", str(Path.home() / ".codex"))))
    parser.add_argument("--state-dir", type=Path,
                        default=Path.home() / "Library/Logs/codex-daemon-watch")
    args = parser.parse_args()
    args.state_dir.mkdir(parents=True, exist_ok=True)
    handler = RotatingFileHandler(args.state_dir / "watch.log", maxBytes=1048576, backupCount=3)
    handler.setFormatter(logging.Formatter("%(asctime)s %(levelname)s %(message)s"))
    LOG.addHandler(handler)
    LOG.setLevel(logging.INFO)
    reader = lambda: read_identity(args.codex_home / "app-server-daemon/daemon.pid")
    def stop(signum, frame):
        raise KeyboardInterrupt
    signal.signal(signal.SIGTERM, stop)
    with singleton(args.state_dir / "watch.lock") as acquired:
        if not acquired:
            LOG.warning("Another monitor is running; exiting")
            return
        LOG.info("Desktop-restart monitor started; first observation establishes baseline")
        try:
            Monitor(reader, lambda: restart_desktop(MacDesktop())).run()
        except KeyboardInterrupt:
            LOG.info("Monitor stopped")
        except Exception:
            LOG.exception("Monitor failed")
            raise


if __name__ == "__main__":
    main()
