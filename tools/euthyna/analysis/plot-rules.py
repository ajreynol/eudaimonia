#!/usr/bin/env python3
"""Draw the rule scatter: partitioned proof size against partitioned rule size.

One point per proof rule. The x axis is the rule itself -- the lines of
`__eo_prog_<rule>` and the helpers it claims. The y axis is what proving it
costs -- the lines of the rule-proof layer it claims. Both are partitioned over
the coreness order, so both are disjoint and sum to their layer, and a point's
position is a share of a real total rather than a reach that overlaps its
neighbours.

Both axes are logarithmic, because both span three orders of magnitude, and the
diagonals are the point of the chart: a line of constant proof-per-rule-line
ratio. A rule far above the 100x diagonal is *hard* -- little rule, much proof.
A rule below the 1x diagonal is *cheap* -- more rule than proof. That is the
"short but hard to prove" / "large but easy to prove" reading, and on log axes
it is a distance, not a squint.

Colour carries nothing here. Seven theory families would need seven categorical
hues, and a scatter is an all-pairs form where the palette validates three; the
families are shown as small multiples instead, which is the documented
alternative and reads better anyway. The single series needs no legend -- the
title names it.

Usage:
  plot-rules.py --partition rule-partition.csv --out rules.html [--meta meta.json]
"""

from __future__ import annotations

import argparse
import csv
import html
import json
import math
import sys
from pathlib import Path

# Theory families, by rule-name prefix. A heuristic and labelled as one on the
# page: it groups what the names suggest, and the names are not a taxonomy.
FAMILIES = {
    "bv": "bitvectors",
    "str": "strings", "string": "strings", "seq": "strings", "re": "strings",
    "quant": "quantifiers",
    "dt": "datatypes",
    "arith": "arithmetic",
    "array": "arrays", "arrays": "arrays",
    "sets": "sets",
}
FAMILY_ORDER = ["core / other", "strings", "bitvectors", "arithmetic",
                "datatypes", "quantifiers", "arrays", "sets"]


def family_of(rule: str) -> str:
    return FAMILIES.get(rule.split("_")[0].lower(), "core / other")


def load(path: Path) -> list[dict]:
    rows = []
    with path.open() as fh:
        for r in csv.DictReader(fh):
            row = {k: (v if k == "rule" else int(v)) for k, v in r.items()}
            row["family"] = family_of(row["rule"])
            row["ratio"] = row["proof_loc"] / max(row["rule_loc"], 1)
            rows.append(row)
    return rows


def notable(rows: list[dict], n: int = 9) -> set[str]:
    """Rules worth a direct label: the extremes of each reading."""
    picked: list[str] = []
    picked += [r["rule"] for r in sorted(rows, key=lambda r: -r["proof_loc"])[:4]]
    picked += [r["rule"] for r in sorted(rows, key=lambda r: -r["ratio"])[:3]]
    picked += [r["rule"] for r in sorted(rows, key=lambda r: r["ratio"])[:2]]
    picked += [r["rule"] for r in sorted(rows, key=lambda r: -r["rule_loc"])[:1]]
    out: list[str] = []
    for name in picked:
        if name not in out:
            out.append(name)
    return set(out[:n])


TEMPLATE = """<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Euthyna &mdash; what a proof rule costs to prove</title>
<style>
  * { box-sizing: border-box; }
  html, body { margin: 0; padding: 0; }
  body { background: #f9f9f7; }
  @media (prefers-color-scheme: dark) {
    html:not([data-theme="light"]) body { background: #0d0d0d; }
  }
  html[data-theme="dark"] body { background: #0d0d0d; }
  .viz-root {
    color-scheme: light;
    --surface-1: #fcfcfb;
    --plane: #f9f9f7;
    --text-primary: #0b0b0b;
    --text-secondary: #52514e;
    --muted: #898781;
    --grid: #e1e0d9;
    --axis: #c3c2b7;
    --series-1: #2a78d6;
    --border: rgba(11,11,11,0.10);
    background: var(--plane);
    color: var(--text-primary);
    font-family: system-ui, -apple-system, "Segoe UI", sans-serif;
    line-height: 1.5;
    margin: 0 auto;
    max-width: 1080px;
    padding: 32px 20px 64px;
  }
  @media (prefers-color-scheme: dark) {
    :root:where(:not([data-theme="light"])) .viz-root {
      color-scheme: dark;
      --surface-1: #1a1a19;
      --plane: #0d0d0d;
      --text-primary: #ffffff;
      --text-secondary: #c3c2b7;
      --muted: #898781;
      --grid: #2c2c2a;
      --axis: #383835;
      --series-1: #3987e5;
      --border: rgba(255,255,255,0.10);
    }
  }
  :root[data-theme="dark"] .viz-root {
    color-scheme: dark;
    --surface-1: #1a1a19;
    --plane: #0d0d0d;
    --text-primary: #ffffff;
    --text-secondary: #c3c2b7;
    --muted: #898781;
    --grid: #2c2c2a;
    --axis: #383835;
    --series-1: #3987e5;
    --border: rgba(255,255,255,0.10);
  }
  .viz-root h1 { font-size: 1.5rem; margin: 0 0 4px; letter-spacing: -0.01em; }
  .viz-root h2 { font-size: 1.05rem; margin: 40px 0 4px; letter-spacing: -0.01em; }
  .viz-root .sub { color: var(--text-secondary); font-size: 0.9rem; margin: 0 0 8px; }
  .viz-root .note { color: var(--muted); font-size: 0.8rem; margin: 6px 0 0; }
  .card {
    background: var(--surface-1);
    border: 1px solid var(--border);
    border-radius: 10px;
    padding: 16px;
    margin-top: 16px;
  }
  .tiles { display: flex; flex-wrap: wrap; gap: 12px; margin-top: 16px; }
  .tile {
    background: var(--surface-1); border: 1px solid var(--border);
    border-radius: 10px; padding: 12px 16px; flex: 1 1 150px;
  }
  .tile .v { font-size: 1.5rem; font-weight: 600; letter-spacing: -0.02em; }
  .tile .k { color: var(--text-secondary); font-size: 0.78rem; }
  svg { display: block; width: 100%; height: auto; overflow: visible; }
  .gridline { stroke: var(--grid); stroke-width: 1; }
  .axisline { stroke: var(--axis); stroke-width: 1; }
  .isoline { stroke: var(--axis); stroke-width: 1; stroke-dasharray: 3 4; }
  .tick { fill: var(--muted); font-size: 11px; font-variant-numeric: tabular-nums; }
  .axistitle { fill: var(--text-secondary); font-size: 12px; }
  .isolabel { fill: var(--muted); font-size: 10px; }
  .zonelabel { fill: var(--muted); font-size: 11px; font-style: italic; }
  .dot { fill: var(--series-1); fill-opacity: 0.55; stroke: var(--surface-1); stroke-width: 1.5; }
  .dot.hi { fill-opacity: 1; }
  .dotlabel { fill: var(--text-secondary); font-size: 10px; }
  .facet-title { fill: var(--text-secondary); font-size: 11px; }
  .facet-n { fill: var(--muted); font-size: 10px; }
  #tip {
    position: fixed; pointer-events: none; opacity: 0; transition: opacity .1s;
    background: var(--surface-1); border: 1px solid var(--border);
    border-radius: 8px; padding: 8px 10px; font-size: 12px;
    box-shadow: 0 4px 16px rgba(0,0,0,.16); z-index: 10; max-width: 260px;
  }
  #tip .r { font-weight: 600; }
  #tip .l { color: var(--text-secondary); }
  table { border-collapse: collapse; width: 100%; font-size: 12px; }
  th, td { text-align: right; padding: 4px 8px; border-bottom: 1px solid var(--border); }
  th:first-child, td:first-child { text-align: left; }
  th { color: var(--text-secondary); font-weight: 600; position: sticky; top: 0;
       background: var(--surface-1); }
  td { font-variant-numeric: tabular-nums; }
  .tablewrap { max-height: 420px; overflow: auto; }
  details { margin-top: 16px; }
  summary { cursor: pointer; color: var(--text-secondary); font-size: 0.9rem; }
</style>
</head>
<body>

<div class="viz-root">
  <h1>What a proof rule costs to prove</h1>
  <p class="sub">__SUBTITLE__</p>

  <div class="tiles">__TILES__</div>

  <div class="card">
    <svg id="main" viewBox="0 0 900 560" role="img"
         aria-label="Scatter of partitioned proof lines against partitioned rule lines,
                     one point per proof rule, both axes logarithmic."></svg>
    <p class="note">Both axes are logarithmic. Dashed diagonals are lines of constant
      proof-per-rule-line. Both measures are partitioned over the coreness order, so
      each is a share of its layer and the columns sum; a rule's position depends on
      what more core rules already claimed.</p>
  </div>

  <h2>The same rules, by theory family</h2>
  <p class="sub">Same axes, same scale, one facet per family. Families are grouped by
    rule-name prefix &mdash; a heuristic, not a taxonomy.</p>
  <div class="card">
    <svg id="facets" viewBox="0 0 900 420" role="img"
         aria-label="Small multiples of the same scatter, one panel per theory family."></svg>
  </div>

  <details>
    <summary>Table view &mdash; all __N__ rules, by partitioned proof size</summary>
    <div class="card tablewrap">
      <table>
        <thead><tr>
          <th>rule</th><th>order</th><th>rule LOC</th><th>proof LOC</th>
          <th>proof files</th><th>ratio</th><th>proof reach</th>
        </tr></thead>
        <tbody id="tbody"></tbody>
      </table>
    </div>
  </details>
</div>
<div id="tip"></div>

<script>
const DATA = __DATA__;
const FAMILY_ORDER = __FAMILIES__;
const NOTABLE = new Set(__NOTABLE__);
const fmt = n => n.toLocaleString('en-US');
const SVGNS = 'http://www.w3.org/2000/svg';

const el = (name, attrs, text) => {
  const e = document.createElementNS(SVGNS, name);
  for (const k in attrs) e.setAttribute(k, attrs[k]);
  if (text !== undefined) e.textContent = text;
  return e;
};

// --- scales ---------------------------------------------------------------
const XD = [1, 1000], YD = [10, 100000];
const lg = v => Math.log10(Math.max(v, 0.5));

function makeScales(box) {
  const x = v => box.l + (lg(v) - lg(XD[0])) / (lg(XD[1]) - lg(XD[0])) * (box.w);
  const y = v => box.t + box.h - (lg(v) - lg(YD[0])) / (lg(YD[1]) - lg(YD[0])) * (box.h);
  return {x, y};
}

function decades(d) {
  const out = [];
  for (let p = Math.ceil(lg(d[0])); p <= Math.floor(lg(d[1])); p++) out.push(Math.pow(10, p));
  return out;
}

// --- main chart -----------------------------------------------------------
function drawMain() {
  const svg = document.getElementById('main');
  svg.replaceChildren();
  const box = {l: 84, t: 30, w: 784, h: 470};
  const {x, y} = makeScales(box);

  // iso-ratio diagonals, drawn first so marks sit above them
  for (const r of [1, 10, 100, 1000]) {
    const pts = [];
    for (const xv of [XD[0], XD[1]]) {
      const yv = xv * r;
      if (yv >= YD[0] && yv <= YD[1]) pts.push([xv, yv]);
    }
    // clip against the y domain
    const a = [XD[0], Math.max(YD[0], XD[0] * r)];
    const b = [Math.min(XD[1], YD[1] / r), Math.min(YD[1], XD[1] * r)];
    if (a[1] > YD[1] || b[1] < YD[0]) continue;
    const ax = XD[0] * r < YD[0] ? YD[0] / r : XD[0];
    svg.appendChild(el('line', {
      class: 'isoline', x1: x(ax), y1: y(ax * r), x2: x(b[0]), y2: y(b[1]),
    }));
    svg.appendChild(el('text', {
      class: 'isolabel', x: x(b[0]) - 4, y: y(b[1]) + 12, 'text-anchor': 'end',
    }, r === 1 ? '1x' : fmt(r) + 'x'));
  }

  // gridlines + ticks
  for (const t of decades(XD)) {
    svg.appendChild(el('line', {class: 'gridline', x1: x(t), y1: box.t, x2: x(t), y2: box.t + box.h}));
    svg.appendChild(el('text', {class: 'tick', x: x(t), y: box.t + box.h + 16, 'text-anchor': 'middle'}, fmt(t)));
  }
  for (const t of decades(YD)) {
    svg.appendChild(el('line', {class: 'gridline', x1: box.l, y1: y(t), x2: box.l + box.w, y2: y(t)}));
    svg.appendChild(el('text', {class: 'tick', x: box.l - 8, y: y(t) + 4, 'text-anchor': 'end'}, fmt(t)));
  }
  svg.appendChild(el('line', {class: 'axisline', x1: box.l, y1: box.t + box.h, x2: box.l + box.w, y2: box.t + box.h}));
  svg.appendChild(el('line', {class: 'axisline', x1: box.l, y1: box.t, x2: box.l, y2: box.t + box.h}));

  svg.appendChild(el('text', {class: 'axistitle', x: box.l + box.w, y: box.t + box.h + 34, 'text-anchor': 'end'},
    'lines of rule  (__eo_prog_ + helpers claimed)'));
  const yt = el('text', {
    class: 'axistitle', 'text-anchor': 'middle',
    transform: `translate(${box.l - 56} ${box.t + box.h / 2}) rotate(-90)`,
  }, 'lines of proof  (rule-proof layer claimed)');
  svg.appendChild(yt);

  // zone labels
  svg.appendChild(el('text', {class: 'zonelabel', x: box.l + 12, y: box.t + 30},
    'short rule, hard to prove'));
  svg.appendChild(el('text', {class: 'zonelabel', x: box.l + box.w - 12, y: box.t + box.h - 14,
    'text-anchor': 'end'}, 'large rule, easy to prove'));

  // marks
  const marks = el('g', {});
  for (const d of DATA) {
    const c = el('circle', {
      class: 'dot' + (NOTABLE.has(d.rule) ? ' hi' : ''),
      cx: x(d.rule_loc), cy: y(d.proof_loc), r: 4,
    });
    marks.appendChild(c);
  }
  svg.appendChild(marks);

  // Direct labels on the notable few, nudged apart. A greedy pass: walk them
  // top to bottom and push any label that would sit within a line-height of the
  // one above it, with a leader back to its mark once it has moved.
  const placed = [];
  const labels = DATA.filter(d => NOTABLE.has(d.rule))
    .map(d => ({d, px: x(d.rule_loc), py: y(d.proof_loc)}))
    .sort((a, b) => a.py - b.py);

  for (const L of labels) {
    const right = L.px < box.l + box.w * 0.66;
    let ly = L.py + 3;
    for (const p of placed) {
      if (Math.abs(p.lx - (L.px + (right ? 9 : -9))) < 150 && Math.abs(p.ly - ly) < 12) {
        ly = p.ly + 12;
      }
    }
    const lx = L.px + (right ? 9 : -9);
    placed.push({lx, ly});
    if (Math.abs(ly - (L.py + 3)) > 2) {
      svg.appendChild(el('line', {
        class: 'isoline', 'stroke-dasharray': '', x1: L.px + (right ? 4 : -4),
        y1: L.py, x2: lx - (right ? 2 : -2), y2: ly - 3,
      }));
    }
    svg.appendChild(el('text', {
      class: 'dotlabel', x: lx, y: ly, 'text-anchor': right ? 'start' : 'end',
    }, L.d.rule));
  }

  attachHover(svg, box, x, y, DATA);
}

// --- facets ---------------------------------------------------------------
function drawFacets() {
  const svg = document.getElementById('facets');
  svg.replaceChildren();
  const fams = FAMILY_ORDER.filter(f => DATA.some(d => d.family === f));
  const cols = 4, cw = 900 / cols, ch = 226;
  fams.forEach((fam, i) => {
    const gx = (i % cols) * cw, gy = Math.floor(i / cols) * ch;
    const box = {l: gx + 46, t: gy + 40, w: cw - 62, h: ch - 82};
    const {x, y} = makeScales(box);
    const g = el('g', {});

    for (const t of decades(YD)) {
      g.appendChild(el('line', {class: 'gridline', x1: box.l, y1: y(t), x2: box.l + box.w, y2: y(t)}));
    }
    g.appendChild(el('line', {class: 'axisline', x1: box.l, y1: box.t + box.h, x2: box.l + box.w, y2: box.t + box.h}));
    g.appendChild(el('line', {class: 'axisline', x1: box.l, y1: box.t, x2: box.l, y2: box.t + box.h}));

    const rows = DATA.filter(d => d.family === fam);
    const sum = rows.reduce((a, d) => a + d.proof_loc, 0);
    // Header on two lines: a count beside the title collides with it at this
    // width, and a truncated count reads as a smaller number rather than a
    // clipped one.
    g.appendChild(el('text', {class: 'facet-title', x: box.l - 4, y: gy + 15}, fam));
    g.appendChild(el('text', {class: 'facet-n', x: box.l - 4, y: gy + 29},
      fmt(rows.length) + ' rules · ' + fmt(sum) + ' lines'));

    for (const d of rows) {
      g.appendChild(el('circle', {class: 'dot', cx: x(d.rule_loc), cy: y(d.proof_loc), r: 2.6}));
    }
    for (const t of [10, 1000, 100000]) {
      g.appendChild(el('text', {class: 'tick', x: box.l - 6, y: y(t) + 3, 'text-anchor': 'end'}, fmt(t)));
    }
    for (const t of [1, 100]) {
      g.appendChild(el('text', {class: 'tick', x: x(t), y: box.t + box.h + 13, 'text-anchor': 'middle'}, fmt(t)));
    }
    svg.appendChild(g);
  });
  svg.setAttribute('viewBox', `0 0 900 ${Math.ceil(fams.length / cols) * ch}`);
}

// --- hover: nearest point, generous hit area ------------------------------
function attachHover(svg, box, x, y, rows) {
  const tip = document.getElementById('tip');
  const hit = el('rect', {
    x: box.l, y: box.t, width: box.w, height: box.h, fill: 'transparent',
  });
  svg.appendChild(hit);
  let last = null;

  const find = (mx, my) => {
    let best = null, bestD = Infinity;
    for (const d of rows) {
      const dx = x(d.rule_loc) - mx, dy = y(d.proof_loc) - my;
      const dist = dx * dx + dy * dy;
      if (dist < bestD) { bestD = dist; best = d; }
    }
    return bestD <= 24 * 24 ? best : null;
  };

  svg.addEventListener('pointermove', ev => {
    const pt = svg.createSVGPoint();
    pt.x = ev.clientX; pt.y = ev.clientY;
    const loc = pt.matrixTransform(svg.getScreenCTM().inverse());
    const d = find(loc.x, loc.y);
    if (!d) { tip.style.opacity = 0; last = null; return; }
    if (d !== last) {
      last = d;
      tip.innerHTML =
        `<div class="r">${d.rule}</div>` +
        `<div><span class="l">rule</span> ${fmt(d.rule_loc)} lines · ` +
        `<span class="l">proof</span> ${fmt(d.proof_loc)} lines</div>` +
        `<div><span class="l">ratio</span> ${d.ratio >= 10 ? Math.round(d.ratio) : d.ratio.toFixed(1)}x ` +
        `proof per line of rule</div>` +
        `<div><span class="l">order</span> #${d.order} · ` +
        `<span class="l">files</span> ${fmt(d.proof_files)} · ` +
        `<span class="l">${d.family}</span></div>`;
    }
    tip.style.opacity = 1;
    tip.style.left = Math.min(ev.clientX + 14, window.innerWidth - 280) + 'px';
    tip.style.top = (ev.clientY + 16) + 'px';
  });
  svg.addEventListener('pointerleave', () => { tip.style.opacity = 0; last = null; });
}

// --- table ----------------------------------------------------------------
function drawTable() {
  const tb = document.getElementById('tbody');
  const rows = [...DATA].sort((a, b) => b.proof_loc - a.proof_loc);
  tb.replaceChildren();
  for (const d of rows) {
    const tr = document.createElement('tr');
    tr.innerHTML =
      `<td>${d.rule}</td><td>${d.order}</td><td>${fmt(d.rule_loc)}</td>` +
      `<td>${fmt(d.proof_loc)}</td><td>${fmt(d.proof_files)}</td>` +
      `<td>${d.ratio >= 10 ? Math.round(d.ratio) : d.ratio.toFixed(1)}</td>` +
      `<td>${fmt(d.proof_reach_loc)}</td>`;
    tb.appendChild(tr);
  }
}

drawMain();
drawFacets();
drawTable();
</script>
</body>
</html>
"""


def build(rows: list[dict], meta: dict) -> str:
    rows_sorted = sorted(rows, key=lambda r: r["order"])
    ratios = sorted(r["ratio"] for r in rows)
    median_ratio = ratios[len(ratios) // 2]
    total_proof = sum(r["proof_loc"] for r in rows)
    total_rule = sum(r["rule_loc"] for r in rows)

    tiles = [
        ("rules", f"{len(rows):,}"),
        ("lines of proof, partitioned", f"{total_proof:,}"),
        ("lines of rule, partitioned", f"{total_rule:,}"),
        ("median proof per line of rule", f"{median_ratio:,.0f}×"),
        ("widest spread in that ratio", f"{max(ratios) / min(ratios):,.0f}×"),
    ]
    tile_html = "".join(
        f'<div class="tile"><div class="v">{html.escape(v)}</div>'
        f'<div class="k">{html.escape(k)}</div></div>'
        for k, v in tiles
    )

    commit = meta.get("logos_commit", "")
    subtitle = (
        f"Every proof rule of CPC, {len(rows)} of them, with both measures partitioned so "
        f"each is a share of its layer. Logos {commit[:12] or 'unknown'}"
        f"{', ' + meta['started'][:10] if meta.get('started') else ''}."
    )

    keep = ["rule", "order", "rule_loc", "proof_loc", "proof_files", "proof_reach_loc",
            "ratio", "family"]
    data = [{k: (round(r[k], 3) if k == "ratio" else r[k]) for k in keep} for r in rows_sorted]

    return (
        TEMPLATE
        .replace("__DATA__", json.dumps(data, separators=(",", ":")))
        .replace("__FAMILIES__", json.dumps(FAMILY_ORDER))
        .replace("__NOTABLE__", json.dumps(sorted(notable(rows))))
        .replace("__TILES__", tile_html)
        .replace("__SUBTITLE__", html.escape(subtitle))
        .replace("__N__", str(len(rows)))
    )


def main(argv: list[str]) -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--partition", required=True, help="rule-partition.py --csv output")
    ap.add_argument("--out", required=True, help="HTML file to write")
    ap.add_argument("--meta", help="a snapshot's meta.json, for the subtitle")
    args = ap.parse_args(argv)

    rows = load(Path(args.partition))
    if not rows:
        print("error: no rows in partition CSV", file=sys.stderr)
        return 2
    meta = {}
    if args.meta and Path(args.meta).is_file():
        meta = json.loads(Path(args.meta).read_text())

    out = Path(args.out)
    out.write_text(build(rows, meta), encoding="utf-8")
    print(f"wrote {out} ({len(rows)} rules)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
