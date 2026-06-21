#!/usr/bin/env python3
"""生成 OKF bundle 自包含可视化 HTML（概念图 + 详情面板）。"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any, Dict, List, Optional, Set, Tuple

SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR))
import okf_lib  # noqa: E402

MARKDOWN_LINK_RE = re.compile(r"(?<!!)\[[^\]]*\]\(([^)]+)\)")

TYPE_COLORS: Dict[str, str] = {
    "Business Domain": "#4e79a7",
    "Business Subdomain": "#59a14f",
    "Bounded Context": "#76b7b2",
    "Aggregate": "#edc948",
    "Ability": "#b07aa1",
    "Product Line": "#ff9da7",
    "Product Module": "#9c755f",
    "Feature": "#bab0ac",
    "Use Case": "#e15759",
    "System": "#499894",
    "Application": "#86bcb6",
    "Microservice": "#f28e2b",
    "API Endpoint": "#d37295",
    "Data Store": "#79706e",
    "Entity": "#b6992d",
    "Middleware Binding": "#8cd17d",
    "Component": "#499894",
}

FALLBACK_COLORS = [
    "#4e79a7",
    "#f28e2b",
    "#e15759",
    "#76b7b2",
    "#59a14f",
    "#edc948",
    "#b07aa1",
    "#ff9da7",
    "#9c755f",
    "#bab0ac",
]


def _repo_root() -> Path:
    return Path(__file__).resolve().parents[2]


def _bundle_root(repo: Path, bundle: str) -> Path:
    return (repo / bundle).resolve()


def concept_id(bundle_root: Path, path: Path) -> str:
    rel = path.resolve().relative_to(bundle_root.resolve())
    return rel.with_suffix("").as_posix()


def _strip_fragment(link: str) -> str:
    if "#" in link:
        return link.split("#", 1)[0]
    return link


def normalize_link_target(
    source_path: Path,
    link: str,
    bundle_root: Path,
) -> Optional[str]:
    link = _strip_fragment(link.strip())
    if not link or link.startswith(("#", "http://", "https://", "mailto:")):
        return None
    if not link.endswith(".md"):
        return None
    if link.startswith("/"):
        target = bundle_root / link.lstrip("/")
    else:
        target = (source_path.parent / link).resolve()
    try:
        rel = target.resolve().relative_to(bundle_root.resolve())
    except ValueError:
        return None
    if rel.suffix != ".md":
        return None
    return rel.with_suffix("").as_posix()


def extract_edges(
    body: str,
    source_path: Path,
    bundle_root: Path,
) -> List[str]:
    targets: List[str] = []
    seen: Set[str] = set()
    for match in MARKDOWN_LINK_RE.finditer(body):
        target_id = normalize_link_target(source_path, match.group(1), bundle_root)
        if target_id is None or target_id in seen:
            continue
        seen.add(target_id)
        targets.append(target_id)
    return targets


def _type_color(type_name: str, index: int) -> str:
    if type_name in TYPE_COLORS:
        return TYPE_COLORS[type_name]
    return FALLBACK_COLORS[index % len(FALLBACK_COLORS)]


def build_bundle_data(bundle_root: Path, name: str) -> Dict[str, Any]:
    concepts: Dict[str, Dict[str, Any]] = {}
    edges: List[Dict[str, str]] = []
    edge_keys: Set[Tuple[str, str]] = set()

    paths = list(okf_lib.scan_concepts(bundle_root))
    for path in paths:
        text = path.read_text(encoding="utf-8")
        meta, body = okf_lib.parse_frontmatter(text)
        cid = concept_id(bundle_root, path)
        type_val = meta.get("type")
        type_name = "" if type_val is None else str(type_val)
        title = str(meta.get("title") or path.stem)
        description = meta.get("description")
        tags_raw = meta.get("tags")
        if isinstance(tags_raw, list):
            tags = [str(t) for t in tags_raw]
        elif tags_raw is None:
            tags = []
        else:
            tags = [str(tags_raw)]

        concepts[cid] = {
            "id": cid,
            "type": type_name,
            "title": title,
            "description": description,
            "tags": tags,
            "body": body.strip(),
            "backlinks": [],
        }

    for path in paths:
        source_id = concept_id(bundle_root, path)
        _, body = okf_lib.parse_frontmatter(path.read_text(encoding="utf-8"))
        for target_id in extract_edges(body, path, bundle_root):
            key = (source_id, target_id)
            if key in edge_keys:
                continue
            edge_keys.add(key)
            edges.append({"source": source_id, "target": target_id})
            if target_id in concepts:
                concepts[target_id]["backlinks"].append(source_id)

    for concept in concepts.values():
        concept["backlinks"] = sorted(set(concept["backlinks"]))

    types = sorted({c["type"] for c in concepts.values() if c["type"]})
    type_colors = {t: _type_color(t, i) for i, t in enumerate(types)}

    return {
        "name": name,
        "concepts": concepts,
        "edges": edges,
        "types": types,
        "typeColors": type_colors,
    }


HTML_TEMPLATE = """<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{title}</title>
<script src="https://unpkg.com/cytoscape@3.28.1/dist/cytoscape.min.js"></script>
<script src="https://unpkg.com/marked/marked.min.js"></script>
<style>
:root {{
  --bg: #0f1419;
  --panel: #1a2332;
  --border: #2d3a4d;
  --text: #e6edf3;
  --muted: #8b949e;
  --accent: #58a6ff;
}}
* {{ box-sizing: border-box; }}
body {{
  margin: 0;
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
  background: var(--bg);
  color: var(--text);
  height: 100vh;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}}
header {{
  padding: 12px 16px;
  border-bottom: 1px solid var(--border);
  background: var(--panel);
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  align-items: center;
}}
header h1 {{
  margin: 0;
  font-size: 1.1rem;
  font-weight: 600;
  flex: 1 1 200px;
}}
.controls {{
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  align-items: center;
}}
input[type="search"] {{
  background: var(--bg);
  border: 1px solid var(--border);
  color: var(--text);
  padding: 6px 10px;
  border-radius: 6px;
  min-width: 220px;
}}
select {{
  background: var(--bg);
  border: 1px solid var(--border);
  color: var(--text);
  padding: 6px 10px;
  border-radius: 6px;
}}
main {{
  flex: 1;
  display: grid;
  grid-template-columns: 1fr 380px;
  min-height: 0;
}}
#cy {{
  background: radial-gradient(circle at 30% 20%, #1a2332 0%, var(--bg) 70%);
}}
aside {{
  border-left: 1px solid var(--border);
  background: var(--panel);
  display: flex;
  flex-direction: column;
  min-height: 0;
}}
#detail {{
  flex: 1;
  overflow: auto;
  padding: 16px;
}}
#detail h2 {{ margin: 0 0 8px; font-size: 1.2rem; }}
#detail .meta {{ color: var(--muted); font-size: 0.85rem; margin-bottom: 12px; }}
#detail .tags span {{
  display: inline-block;
  background: var(--bg);
  border: 1px solid var(--border);
  border-radius: 4px;
  padding: 2px 6px;
  margin: 2px 4px 2px 0;
  font-size: 0.75rem;
}}
#detail .body {{
  border-top: 1px solid var(--border);
  padding-top: 12px;
  line-height: 1.55;
  font-size: 0.92rem;
}}
#detail .body a {{ color: var(--accent); }}
#detail .body pre {{
  background: var(--bg);
  padding: 10px;
  border-radius: 6px;
  overflow: auto;
}}
#backlinks {{
  border-top: 1px solid var(--border);
  padding: 12px 16px;
  max-height: 160px;
  overflow: auto;
}}
#backlinks h3 {{ margin: 0 0 8px; font-size: 0.9rem; }}
#backlinks ul {{ margin: 0; padding-left: 18px; }}
#backlinks li {{ margin: 4px 0; }}
#backlinks a {{ color: var(--accent); cursor: pointer; text-decoration: none; }}
#backlinks a:hover {{ text-decoration: underline; }}
#legend {{
  border-top: 1px solid var(--border);
  padding: 10px 16px;
  max-height: 140px;
  overflow: auto;
}}
#legend h3 {{ margin: 0 0 8px; font-size: 0.85rem; color: var(--muted); }}
.legend-item {{
  display: inline-flex;
  align-items: center;
  margin: 2px 10px 2px 0;
  font-size: 0.75rem;
}}
.legend-swatch {{
  width: 10px;
  height: 10px;
  border-radius: 50%;
  margin-right: 5px;
}}
.empty-hint {{ color: var(--muted); font-style: italic; }}
@media (max-width: 900px) {{
  main {{ grid-template-columns: 1fr; grid-template-rows: 55vh 1fr; }}
  aside {{ border-left: none; border-top: 1px solid var(--border); }}
}}
</style>
</head>
<body>
<header>
  <h1>{title}</h1>
  <div class="controls">
    <input type="search" id="search" placeholder="搜索 title / id / tags…" autocomplete="off">
    <select id="typeFilter">
      <option value="">全部类型</option>
    </select>
  </div>
</header>
<main>
  <div id="cy"></div>
  <aside>
    <div id="detail"><p class="empty-hint">点击节点查看概念详情</p></div>
    <div id="backlinks"><h3>Cited by</h3><p class="empty-hint">—</p></div>
    <div id="legend"><h3>类型图例</h3></div>
  </aside>
</main>
<script id="okf-bundle-data" type="application/json">
{json_data}
</script>
<script>
(function () {{
  const bundle = JSON.parse(document.getElementById('okf-bundle-data').textContent);
  const concepts = bundle.concepts;
  const typeColors = bundle.typeColors || {{}};
  let cy = null;
  let selectedId = null;

  function normalizeLinkToId(href, baseId) {{
    if (!href) return null;
    let link = href.split('#')[0].trim();
    if (!link.endsWith('.md')) return null;
    if (link.startsWith('http://') || link.startsWith('https://')) return null;
    let rel;
    if (link.startsWith('/')) {{
      rel = link.replace(/^\\/+/, '').replace(/\\.md$/, '');
    }} else {{
      const baseParts = baseId.split('/');
      baseParts.pop();
      const linkParts = link.replace(/\\.md$/, '').split('/');
      for (const part of linkParts) {{
        if (part === '..') baseParts.pop();
        else if (part !== '.' && part !== '') baseParts.push(part);
      }}
      rel = baseParts.join('/');
    }}
    return concepts[rel] ? rel : null;
  }}

  function buildElements() {{
    const nodes = Object.values(concepts).map(c => ({{
      data: {{
        id: c.id,
        label: c.title || c.id,
        type: c.type || 'unknown',
        title: c.title,
        tags: (c.tags || []).join(' '),
        searchText: [c.id, c.title, ...(c.tags || [])].join(' ').toLowerCase(),
      }},
    }}));
    const nodeIds = new Set(nodes.map(n => n.data.id));
    const edges = bundle.edges
      .filter(e => nodeIds.has(e.source) && nodeIds.has(e.target))
      .map((e, i) => ({{
        data: {{ id: 'e' + i, source: e.source, target: e.target }},
      }}));
    return nodes.concat(edges);
  }}

  function renderLegend() {{
    const el = document.getElementById('legend');
    const items = (bundle.types || []).map(t => {{
      const color = typeColors[t] || '#888';
      return `<span class="legend-item"><span class="legend-swatch" style="background:${{color}}"></span>${{t}}</span>`;
    }}).join('');
    el.innerHTML = '<h3>类型图例</h3>' + (items || '<span class="empty-hint">无</span>');
  }}

  function populateTypeFilter() {{
    const sel = document.getElementById('typeFilter');
    (bundle.types || []).forEach(t => {{
      const opt = document.createElement('option');
      opt.value = t;
      opt.textContent = t;
      sel.appendChild(opt);
    }});
  }}

  function nodeStyle() {{
    const style = [
      {{
        selector: 'node',
        style: {{
          label: 'data(label)',
          'text-valign': 'bottom',
          'text-halign': 'center',
          'font-size': '9px',
          color: '#c9d1d9',
          'text-outline-color': '#0f1419',
          'text-outline-width': 2,
          'background-color': '#888',
          width: 28,
          height: 28,
        }},
      }},
      {{
        selector: 'edge',
        style: {{
          width: 1.2,
          'line-color': '#3d4f66',
          'target-arrow-color': '#3d4f66',
          'target-arrow-shape': 'triangle',
          'curve-style': 'bezier',
          opacity: 0.65,
        }},
      }},
      {{
        selector: 'node:selected',
        style: {{
          'border-width': 3,
          'border-color': '#58a6ff',
        }},
      }},
      {{
        selector: '.hidden',
        style: {{ display: 'none' }},
      }},
      {{
        selector: '.faded',
        style: {{ opacity: 0.15 }},
      }},
    ];
    (bundle.types || []).forEach(t => {{
      style.push({{
        selector: `node[type = "${{t.replace(/"/g, '\\\\"')}}"]`,
        style: {{ 'background-color': typeColors[t] || '#888' }},
      }});
    }});
    return style;
  }}

  function initGraph() {{
    cy = cytoscape({{
      container: document.getElementById('cy'),
      elements: buildElements(),
      style: nodeStyle(),
      layout: {{ name: 'cose', animate: false, padding: 40 }},
      minZoom: 0.2,
      maxZoom: 3,
    }});
    cy.on('tap', 'node', evt => selectConcept(evt.target.id()));
    cy.on('tap', evt => {{
      if (evt.target === cy) {{
        selectedId = null;
        cy.$('node:selected').unselect();
      }}
    }});
  }}

  function applyFilters() {{
    if (!cy) return;
    const q = document.getElementById('search').value.trim().toLowerCase();
    const typeVal = document.getElementById('typeFilter').value;
    cy.nodes().removeClass('hidden faded');
    cy.edges().removeClass('hidden faded');
    cy.nodes().forEach(node => {{
      const d = node.data();
      let visible = true;
      if (typeVal && d.type !== typeVal) visible = false;
      if (visible && q && !d.searchText.includes(q)) visible = false;
      if (!visible) node.addClass('hidden');
    }});
    cy.edges().forEach(edge => {{
      if (edge.source().hasClass('hidden') || edge.target().hasClass('hidden')) {{
        edge.addClass('hidden');
      }}
    }});
    if (q || typeVal) {{
      cy.nodes(':visible').forEach(n => {{
        if (selectedId && n.id() !== selectedId) n.addClass('faded');
      }});
    }}
  }}

  function renderBacklinks(id) {{
    const box = document.getElementById('backlinks');
    const c = concepts[id];
    const links = (c && c.backlinks) || [];
    if (!links.length) {{
      box.innerHTML = '<h3>Cited by</h3><p class="empty-hint">无引用</p>';
      return;
    }}
    const items = links.map(src => {{
      const sc = concepts[src];
      const label = sc ? (sc.title || src) : src;
      return `<li><a data-id="${{src}}">${{label}}</a> <span class="empty-hint">(${{src}})</span></li>`;
    }}).join('');
    box.innerHTML = '<h3>Cited by</h3><ul>' + items + '</ul>';
    box.querySelectorAll('a[data-id]').forEach(a => {{
      a.addEventListener('click', e => {{
        e.preventDefault();
        selectConcept(a.getAttribute('data-id'));
      }});
    }});
  }}

  function renderDetail(id) {{
    const c = concepts[id];
    const detail = document.getElementById('detail');
    if (!c) {{
      detail.innerHTML = '<p class="empty-hint">概念不存在</p>';
      return;
    }}
    const desc = c.description != null && c.description !== '' ? String(c.description) : '—';
    const tags = (c.tags || []).map(t => `<span>${{t}}</span>`).join('') || '<span class="empty-hint">—</span>';
    const bodyHtml = marked.parse(c.body || '', {{ breaks: true }});
    detail.innerHTML =
      `<h2>${{c.title || c.id}}</h2>` +
      `<div class="meta"><div><strong>ID:</strong> ${{c.id}}</div>` +
      `<div><strong>Type:</strong> ${{c.type || '—'}}</div>` +
      `<div><strong>Description:</strong> ${{desc}}</div></div>` +
      `<div class="tags">${{tags}}</div>` +
      `<div class="body">${{bodyHtml}}</div>`;
    detail.querySelector('.body').addEventListener('click', e => {{
      const a = e.target.closest('a');
      if (!a) return;
      const targetId = normalizeLinkToId(a.getAttribute('href'), id);
      if (targetId) {{
        e.preventDefault();
        selectConcept(targetId);
      }}
    }});
  }}

  function selectConcept(id) {{
    if (!concepts[id]) return;
    selectedId = id;
    if (cy) {{
      const node = cy.getElementById(id);
      if (node.nonempty()) {{
        cy.$('node:selected').unselect();
        node.select();
        cy.animate({{ center: {{ eles: node }}, zoom: Math.max(cy.zoom(), 1.2) }}, {{ duration: 250 }});
      }}
    }}
    renderDetail(id);
    renderBacklinks(id);
  }}

  document.getElementById('search').addEventListener('input', applyFilters);
  document.getElementById('typeFilter').addEventListener('change', applyFilters);

  renderLegend();
  populateTypeFilter();
  initGraph();
}})();
</script>
</body>
</html>
"""


def render_html(data: Dict[str, Any]) -> str:
    title = str(data.get("name") or "OKF Bundle")
    json_data = json.dumps(data, ensure_ascii=False, indent=2)
    return HTML_TEMPLATE.format(title=title, json_data=json_data)


def generate_visualization(
    bundle_root: Path,
    out_path: Path,
    name: str,
) -> None:
    data = build_bundle_data(bundle_root, name)
    html = render_html(data)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(html, encoding="utf-8")


def main(argv: Optional[List[str]] = None) -> int:
    parser = argparse.ArgumentParser(description="生成 OKF bundle 可视化 HTML")
    parser.add_argument("--bundle", required=True, help="bundle 名称，如 application")
    parser.add_argument("--out", required=True, help="输出 HTML 路径（相对仓库根）")
    parser.add_argument("--name", default="OKF Bundle", help="页面标题")
    parser.add_argument("--repo", default=None, help="仓库根目录（默认：脚本上两级）")
    args = parser.parse_args(argv)

    repo = Path(args.repo).resolve() if args.repo else _repo_root()
    bundle_root = _bundle_root(repo, args.bundle)
    if not bundle_root.is_dir():
        print(f"error: bundle 不存在: {bundle_root}", file=sys.stderr)
        return 1

    out_path = (repo / args.out).resolve()
    generate_visualization(bundle_root, out_path, args.name)
    size = out_path.stat().st_size
    print(f"wrote {out_path} ({size} bytes, {len(list(okf_lib.scan_concepts(bundle_root)))} concepts)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
