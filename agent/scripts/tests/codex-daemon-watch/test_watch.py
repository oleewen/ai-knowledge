"""Behavior tests for daemon-triggered desktop restarts; never control real apps."""
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

MODULE = Path(__file__).resolve().parents[2] / "codex-daemon-watch.py"
spec = importlib.util.spec_from_file_location("watch", MODULE)
watch = importlib.util.module_from_spec(spec)
spec.loader.exec_module(watch)


class FakeClock:
    def __init__(self):
        self.now = 0.0

    def __call__(self):
        return self.now

    def sleep(self, seconds):
        self.now += seconds


class FakeDesktop:
    def __init__(self):
        self.current = [{"pid": 123, "path": "/Applications/ChatGPT 2.app"}]
        self.actions = []
        self.quit_accepted = True
        self.quit_exits = True
        self.open_starts = True

    def apps(self):
        return list(self.current)

    def quit(self, app):
        self.actions.append(("quit", app["pid"], app["path"]))
        if self.quit_accepted and self.quit_exits:
            self.current = []
        return self.quit_accepted

    def open(self, path):
        self.actions.append(("open", path))
        if self.open_starts:
            self.current = [{"pid": 456, "path": path}]


class WatchTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.pid = self.root / "daemon.pid"
        self.record = {"pid": 123, "processStartTime": "Fri Oct 23 15:11:05 2026",
                       "processIdentity": {"uniqueId": 9}}
        self.pid.write_text(json.dumps(self.record))
        self.clock = FakeClock()

    def test_rejects_stale_pid_and_non_daemon(self):
        good = "Fri Oct 23 15:11:05 2026 /bin/codex app-server --managed-daemon"
        for output, expected in [(good, True), (good.replace("15:11", "15:12"), False),
                                 (good.replace("--managed-daemon", ""), False)]:
            with patch.object(watch.subprocess, "check_output", return_value=output):
                self.assertEqual(watch.read_identity(self.pid) is not None, expected)

    def test_invalid_pid_file_does_not_trigger(self):
        for content in ["{}", "[]", "{", '{"pid":-1}', '{"pid":true}']:
            self.pid.write_text(content)
            self.assertIsNone(watch.read_identity(self.pid))

    def monitor(self, actions, reader=lambda: None):
        return watch.Monitor(reader, lambda: actions.append("restart"), clock=self.clock)

    def test_first_observation_is_baseline_only(self):
        actions = []
        monitor = self.monitor(actions)
        monitor.tick("existing")
        monitor.tick(None)
        monitor.tick("existing")
        self.assertEqual(actions, [])
        monitor.tick("new")
        monitor.tick("new")
        self.assertEqual(actions, ["restart"])

    def test_first_daemon_after_initial_absence_triggers(self):
        actions = []
        monitor = self.monitor(actions)
        monitor.tick(None)
        monitor.tick("first")
        self.assertEqual(actions, ["restart"])

    def test_changes_during_action_and_cooldown_are_absorbed(self):
        actions = []
        monitor = self.monitor(actions, reader=lambda: "self-induced")
        monitor.tick("baseline")
        monitor.tick("external")
        monitor.tick("self-induced")
        self.clock.sleep(20)
        monitor.tick("during-cooldown")
        self.clock.sleep(61)
        monitor.tick("during-cooldown")
        self.assertEqual(actions, ["restart"])
        monitor.tick("later-external")
        self.assertEqual(actions, ["restart", "restart"])

    def test_failed_action_is_not_retried_for_same_instance(self):
        calls = []
        def fail():
            calls.append(1)
            raise OSError("unable to quit")
        monitor = watch.Monitor(lambda: None, fail, clock=self.clock)
        monitor.tick("baseline")
        monitor.tick("next")
        self.clock.sleep(120)
        monitor.tick("next")
        self.assertEqual(calls, [1])

    def restart(self, desktop):
        return watch.restart_desktop(desktop, timeout=3, clock=self.clock, sleep=self.clock.sleep)

    def test_normal_restart_uses_exact_running_path(self):
        desktop = FakeDesktop()
        self.assertTrue(self.restart(desktop))
        self.assertEqual(desktop.actions, [
            ("quit", 123, "/Applications/ChatGPT 2.app"),
            ("open", "/Applications/ChatGPT 2.app")])

    def test_closed_desktop_is_not_opened(self):
        desktop = FakeDesktop()
        desktop.current = []
        self.assertFalse(self.restart(desktop))
        self.assertEqual(desktop.actions, [])

    def test_ambiguous_desktop_instances_are_not_quit(self):
        desktop = FakeDesktop()
        desktop.current.append({"pid": 789, "path": "/Applications/ChatGPT.app"})
        self.assertFalse(self.restart(desktop))
        self.assertEqual(desktop.actions, [])

    def test_declined_quit_does_not_open(self):
        desktop = FakeDesktop()
        desktop.quit_accepted = False
        self.assertFalse(self.restart(desktop))
        self.assertEqual([a[0] for a in desktop.actions], ["quit"])

    def test_quit_timeout_never_forces_kill_or_reopens(self):
        desktop = FakeDesktop()
        desktop.quit_exits = False
        self.assertFalse(self.restart(desktop))
        self.assertEqual([a[0] for a in desktop.actions], ["quit"])
        self.assertLessEqual(self.clock.now, 3)

    def test_launch_timeout_does_not_retry_restart(self):
        desktop = FakeDesktop()
        desktop.open_starts = False
        self.assertFalse(self.restart(desktop))
        self.assertEqual([a[0] for a in desktop.actions], ["quit", "open"])

    def test_user_reopen_during_quit_is_not_launched_twice(self):
        desktop = FakeDesktop()
        def quit(app):
            desktop.current = [{"pid": 999, "path": app["path"]}]
            return True
        desktop.quit = quit
        self.assertTrue(self.restart(desktop))
        self.assertEqual(desktop.actions, [])

    def test_singleton_lock(self):
        with watch.singleton(self.root / "watch.lock") as acquired:
            self.assertTrue(acquired)
            with watch.singleton(self.root / "watch.lock") as second:
                self.assertFalse(second)


if __name__ == "__main__":
    unittest.main()
