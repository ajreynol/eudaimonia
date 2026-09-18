#!/usr/bin/env python3
"""Build the public reports from saved measurements, without a Logos checkout.

The site root lists reports, euthyna/ shows the latest snapshot, and
euthyna/snapshots/<id>/ keeps a link to each dated measurement.
Only Python's standard library is needed. No network access is used.
"""

from __future__ import annotations

import argparse
import html
import importlib.util
import json
import shutil
from pathlib import Path
from urllib.parse import quote, urlsplit

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_URL = "https://ajreynol.github.io/eudaimonia"
SOURCE_URL = "https://github.com/ajreynol/eudaimonia/tree/main/tools/euthyna"
DOWNLOADS = ("rule-partition.csv", "meta.json", "summary.json")

spec = importlib.util.spec_from_file_location("plot_rules", ROOT / "analysis/plot-rules.py")
plot = importlib.util.module_from_spec(spec)
spec.loader.exec_module(plot)


def index_page(snapshots: list[dict], base_url: str) -> str:
    latest = snapshots[0]
    esc = html.escape
    rows = []
    for snapshot in snapshots:
        meta = snapshot["meta"]
        link = f'euthyna/snapshots/{quote(snapshot["id"])}/index.html'
        rows.append(
            f'<tr><td><a href="{link}">{esc(snapshot["id"])}</a></td>'
            f'<td>{len(snapshot["rows"]):,}</td>'
            f'<td>{sum(r["proof_loc"] for r in snapshot["rows"]):,}</td>'
            f'<td>{"Includes uncommitted changes" if meta.get("logos_dirty") else "Clean checkout"}</td></tr>'
        )
    date = esc(latest["meta"]["started"][:10])
    count = len(latest["rows"])
    return f'''<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Eudaimonia reports — Euthyna's measurements of Logos</title>
<meta name="description" content="Interactive reports on the size and structure of Logos proofs. Explore rule and proof lines, download figures, and share dated measurements.">
<meta property="og:title" content="Euthyna reports — what a proof rule costs to prove">
<meta property="og:description" content="Explore {count} Logos CPC rules, with interactive graphics and downloadable data.">
<link rel="canonical" href="{esc(base_url)}/">
<style>
  :root {{ color-scheme: light dark; --bg: #f9f9f7; --card: #fff;
    --text: #171b22; --muted: #555e6d; --line: #dce1e8; --link: #175fbb; }}
  @media (prefers-color-scheme: dark) {{ :root {{ --bg: #101419; --card: #181e27;
    --text: #eef2f8; --muted: #b2bed0; --line: #334052; --link: #8dbdff; }} }}
  * {{ box-sizing: border-box; }}
  body {{ margin: 0; background: var(--bg); color: var(--text);
    font: 16px/1.6 system-ui, sans-serif; }}
  main {{ max-width: 1060px; margin: auto; padding: 48px 24px 72px; }}
  a {{ color: var(--link); text-underline-offset: 3px; }}
  nav, .eyebrow, .meta {{ color: var(--muted); font-size: 0.9rem; }}
  nav {{ display: flex; flex-wrap: wrap; gap: 20px; margin-bottom: 40px; }}
  h1 {{ font-size: clamp(2rem, 5vw, 3.2rem); line-height: 1.15; max-width: 800px; }}
  h2 {{ font-size: 1.5rem; line-height: 1.3; }}
  p {{ max-width: 760px; }}
  .card {{ padding: 24px; margin: 32px 0; background: var(--card);
    border: 1px solid var(--line); border-radius: 12px; }}
  .button {{ display: inline-block; padding: 10px 18px; border-radius: 6px;
    background: var(--link); color: var(--bg); text-decoration: none; font-weight: 600; }}
  .tablewrap {{ overflow-x: auto; }}
  table {{ width: 100%; border-collapse: collapse; font-size: 0.9rem; }}
  th, td {{ text-align: left; padding: 12px; border-bottom: 1px solid var(--line); }}
  th {{ color: var(--muted); }}
  footer {{ border-top: 1px solid var(--line); margin-top: 40px; padding-top: 20px; }}
</style>
</head>
<body><main>
<nav aria-label="Site"><strong>Eudaimonia / Reports</strong>
<a href="https://github.com/ajreynol/eudaimonia">Repository</a>
<a href="{SOURCE_URL}">About Euthyna</a></nav>
<p class="eyebrow">EUTHYNA · MEASURING LOGOS</p>
<h1>What does a proof rule cost to prove?</h1>
<p>Explore the size and structure of the Lean proofs behind
<a href="https://github.com/cvc5/logos">Logos</a>, cvc5's verified proof checker.
Euthyna measures saved revisions and makes the results available to browse, download, and share.</p>
<article class="card">
<p class="eyebrow">LATEST MEASUREMENT · {date}</p>
<h2>Lines of rule code vs. lines of proof</h2>
<p>One point for each of {count} CPC proof rules. Compare the whole calculus,
explore theory families, or inspect the complete table.</p>
<p><a class="button" href="euthyna/index.html">Explore the interactive report →</a></p>
<p class="meta">Rule and proof lines are partitioned: shared code is assigned once,
to the first rule that uses it in the maintained order. These are code sizes,
not measurements of human effort.</p>
</article>
<h2>Share a report</h2>
<p>Share the <a href="euthyna/index.html">latest report</a> to follow new measurements.
For a particular finding, use its <strong>Copy snapshot link</strong> button:
the dated link keeps pointing to that measurement. Each report includes a CSV
download, snapshot metadata, and an SVG figure you can use in slides or documents.</p>
<h2>Saved snapshots</h2>
<div class="tablewrap"><table>
<thead><tr><th>Measurement / Logos revision</th><th>Rules</th><th>Attributed proof lines</th><th>Source state</th></tr></thead>
<tbody>{''.join(rows)}</tbody></table></div>
<p class="meta">Snapshots marked as including uncommitted changes cannot be reproduced
from the Logos commit alone. The saved measurements are provided with every report.</p>
<footer><a href="{SOURCE_URL}/docs/partition.md">How the partition works</a> ·
<a href="{SOURCE_URL}/docs/method.md">Measurement method</a> ·
<a href="{SOURCE_URL}/data/snapshots">Source data</a></footer>
</main></body></html>
'''


def build_site(source: Path, out: Path, base_url: str) -> list[dict]:
    source, out = source.resolve(), out.resolve()
    if out == source or source in out.parents or out in source.parents:
        raise ValueError("site output must be separate from the snapshot inputs")
    url = urlsplit(base_url)
    if url.scheme not in ("https", "http") or not url.netloc or url.query or url.fragment:
        raise ValueError("base URL must be an absolute HTTP(S) URL without a query or fragment")
    base_url = base_url.rstrip("/")

    snapshots = []
    for path in sorted(source.iterdir()):
        if not path.is_dir() or path.name.startswith("."):
            continue
        for name in DOWNLOADS:
            if not (path / name).is_file():
                raise ValueError(f"incomplete snapshot: {path.name}/{name} is missing")
        meta = json.loads((path / "meta.json").read_text())
        rows = plot.load(path / "rule-partition.csv")
        if not rows or not meta.get("started") or not meta.get("logos_commit"):
            raise ValueError(f"incomplete snapshot: {path.name} has no rows, date, or revision")
        snapshots.append({"id": path.name, "path": path, "meta": meta, "rows": rows})
    if not snapshots:
        raise ValueError("no saved snapshots to publish")
    snapshots.sort(key=lambda s: (s["meta"]["started"], s["id"]), reverse=True)

    out.mkdir(parents=True, exist_ok=True)
    (out / ".nojekyll").write_text("")
    (out / "index.html").write_text(index_page(snapshots, base_url), encoding="utf-8")
    for snapshot in snapshots:
        snapshot_id = snapshot["id"]
        relative = f"euthyna/snapshots/{quote(snapshot_id)}/"
        publication = {
            "id": snapshot_id,
            "permalink": f"{base_url}/{relative}",
            "index": "../../../index.html",
            "latest": "../../index.html",
            "snapshot": "index.html",
            "method": f"{SOURCE_URL}/docs/partition.md",
            "data": "rule-partition.csv",
            "metadata": "meta.json",
        }
        dest = out / "euthyna/snapshots" / snapshot_id
        dest.mkdir(parents=True, exist_ok=True)
        (dest / "index.html").write_text(
            plot.build(snapshot["rows"], snapshot["meta"], publication), encoding="utf-8"
        )
        for name in DOWNLOADS:
            shutil.copyfile(snapshot["path"] / name, dest / name)
        if snapshot is snapshots[0]:
            # Render the latest page directly: it works offline and needs no redirect.
            prefix = f"snapshots/{quote(snapshot_id)}/"
            publication.update(index="../index.html", latest="index.html",
                               snapshot=f"{prefix}index.html", data=f"{prefix}rule-partition.csv",
                               metadata=f"{prefix}meta.json")
            (out / "euthyna/index.html").write_text(
                plot.build(snapshot["rows"], snapshot["meta"], publication), encoding="utf-8"
            )
    return snapshots


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--snapshots", type=Path, default=ROOT / "data/snapshots")
    parser.add_argument("--out", type=Path, default=ROOT / "site")
    parser.add_argument("--base-url", default=DEFAULT_URL)
    args = parser.parse_args()
    try:
        snapshots = build_site(args.snapshots, args.out, args.base_url)
    except (ValueError, OSError) as error:
        parser.exit(1, f"euthyna site: {error}\n")
    print(f"Built {len(snapshots)} reports: {args.out.resolve() / 'index.html'}")
    print(f"After deployment: {args.base_url.rstrip('/')}/")
    print(f"Latest report: {args.base_url.rstrip('/')}/euthyna/")


if __name__ == "__main__":
    main()
