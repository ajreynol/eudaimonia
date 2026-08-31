#!/usr/bin/env python3
"""Euthyna's first derived analysis: turn a snapshot into numbers about it.

The vendored scripts under `upstream/` each answer one question well and stop
there. `classify-rule-status.py` says whether a rule is proven; `cpc-rule-loc.py`
says how many lines each rule's proof reaches; `cpc-loc-summary.py` says how the
whole development divides into layers. None of them says anything about the
*shape* of the result, and shape is what Euthyna is after.

So this reads a snapshot's raw outputs and derives:

  status        the proven/unproven/out-of-scope counts, whole and core.

  layers        the LOC of each layer of the development, and what share of the
                proof each holds.

  floor         the smallest proof reach of any rule. Every rule's proof
                transitively reaches at least this much, so this is the fixed
                cost of stating *any* rule correctness proof at all -- the
                shared support and checker scaffolding, measured rather than
                asserted.

  surplus       proof reach minus the floor, per rule. This is the part of a
                rule's proof that is about *that rule*, and it is the number a
                generality argument has to move: the floor is paid once, the
                surplus is paid 591 times.

  concentration what share of the total surplus the heaviest tenth of rules
                holds. A development where a few rules carry the weight admits
                a different improvement than one where the cost is flat.

  leverage      the sum of per-rule proof reach divided by the actual size of
                the rule-proof layer. Per-rule reach double-counts everything
                shared, so this ratio is how many times the average line of the
                rule layer is reached. High leverage means shared support is
                doing a lot of work; it also means a change there is felt
                everywhere.

  ratio         proof reach against the size of the `__eo_prog_` implementation
                the rule is proven about -- the price, in lines of proof, of a
                line of checker.

Usage:
  analysis/derive.py <snapshot>            emit summary.json on stdout
  analysis/derive.py --report <snapshot>   print the human-readable report
"""

from __future__ import annotations

import csv
import json
import re
import statistics as stats
import sys
from pathlib import Path

# ---------------------------------------------------------------------------
# Reading the raw measures.
# ---------------------------------------------------------------------------

STATUS_SUMMARY_RE = re.compile(r"^(Proven|Unproven|OutOfScope|Total)\t(\d+)$", re.M)

PIECE_RE = re.compile(
    r"^\((?P<key>[1-5])\)\s+(?P<title>.+?)\s*$"
    r"(?:\n.*?)??"
    r"\n\s*(?:total proof )?files:\s*(?P<files>\d+)\s+(?:total proof )?lines:\s*(?P<lines>\d+)",
    re.M,
)
BUCKET_RE = re.compile(
    r"^\s{4}\((?P<key>[a-g])\)\s+(?P<title>.+?)\s*\n"
    r"\s+files:\s*(?P<files>\d+)\s+lines:\s*(?P<lines>\d+)",
    re.M,
)
PARSER_SPLIT_RE = re.compile(
    r"signature-independent parser:\s*(\d+).*?generated configuration:\s*(\d+)", re.S
)


def read_status(path: Path) -> dict | None:
    """The summary block of a classify-rule-status.py run."""
    if not path.is_file():
        return None
    text = path.read_text()
    counts = {k: int(v) for k, v in STATUS_SUMMARY_RE.findall(text)}
    return counts or None


def read_layers(path: Path) -> dict | None:
    """The pieces and buckets of a cpc-loc-summary.py run."""
    if not path.is_file():
        return None
    text = path.read_text()

    pieces = {}
    for m in PIECE_RE.finditer(text):
        pieces[m.group("key")] = {
            "title": m.group("title"),
            "files": int(m.group("files")),
            "lines": int(m.group("lines")),
        }

    buckets = {}
    for m in BUCKET_RE.finditer(text):
        # Section (5) repeats the letters without counts; first win keeps (4).
        buckets.setdefault(
            m.group("key"),
            {
                "title": m.group("title"),
                "files": int(m.group("files")),
                "lines": int(m.group("lines")),
            },
        )

    if not pieces:
        return None

    split = PARSER_SPLIT_RE.search(text)
    if split:
        pieces.setdefault("3", {})["parser_generic"] = int(split.group(1))
        pieces["3"]["parser_generated"] = int(split.group(2))

    return {"pieces": pieces, "buckets": buckets}


def read_rule_loc(path: Path) -> list[dict] | None:
    """The rows of a cpc-rule-loc.py --csv run."""
    if not path.is_file():
        return None
    with path.open() as fh:
        rows = [
            {
                "rule": r["rule"],
                "proof_loc": int(r["proof_loc"]),
                "proof_files": int(r["proof_files"]),
                "eo_prog_loc": int(r["eo_prog_loc"]),
                "eo_prog_defs": int(r["eo_prog_defs"]),
            }
            for r in csv.DictReader(fh)
        ]
    return rows or None


def read_checks(snapshot: Path) -> dict:
    """The pass/fail measures, read from the run log."""
    log = snapshot / "measures.tsv"
    out = {}
    if not log.is_file():
        return out
    for line in log.read_text().splitlines()[1:]:
        parts = line.split("\t")
        if len(parts) < 3:
            continue
        name, _needs, status = parts[0], parts[1], parts[2]
        out[name] = "skipped" if status == "skipped" else ("pass" if status == "0" else "fail")
    return out


# ---------------------------------------------------------------------------
# Deriving.
# ---------------------------------------------------------------------------


def quantiles(values: list[int]) -> dict:
    ordered = sorted(values)
    n = len(ordered)
    return {
        "n": n,
        "min": ordered[0],
        "p25": ordered[n // 4],
        "median": int(stats.median(ordered)),
        "p75": ordered[(3 * n) // 4],
        "max": ordered[-1],
        "mean": round(stats.mean(ordered), 1),
        "total": sum(ordered),
    }


def derive_rules(rows: list[dict], rule_layer_lines: int | None) -> dict:
    proof = [r["proof_loc"] for r in rows]
    prog = [r["eo_prog_loc"] for r in rows]

    floor = min(proof)
    surplus = sorted(((r["proof_loc"] - floor, r["rule"]) for r in rows), reverse=True)
    surplus_values = [s for s, _ in surplus]
    total_surplus = sum(surplus_values)

    decile = max(1, len(rows) // 10)
    top_decile_share = (
        round(sum(surplus_values[:decile]) / total_surplus, 4) if total_surplus else 0.0
    )

    ratios = [r["proof_loc"] / r["eo_prog_loc"] for r in rows if r["eo_prog_loc"]]

    derived = {
        "count": len(rows),
        "proof_loc": quantiles(proof),
        "eo_prog_loc": quantiles(prog),
        "proof_files": quantiles([r["proof_files"] for r in rows]),
        "floor": {
            "lines": floor,
            "rule": min(rows, key=lambda r: r["proof_loc"])["rule"],
            "share_of_median_reach": round(floor / stats.median(proof), 4),
        },
        "surplus": {
            "total": total_surplus,
            "median": int(stats.median(surplus_values)),
            "max": surplus_values[0],
            "top_decile_share": top_decile_share,
            "zero_surplus_rules": sum(1 for s in surplus_values if s == 0),
            "heaviest": [{"rule": n, "surplus": s} for s, n in surplus[:15]],
        },
        "proof_per_prog_line": {
            "median": round(stats.median(ratios), 1),
            "min": round(min(ratios), 1),
            "max": round(max(ratios), 1),
        },
    }

    if rule_layer_lines:
        derived["leverage"] = {
            "summed_reach": sum(proof),
            "rule_layer_lines": rule_layer_lines,
            "factor": round(sum(proof) / rule_layer_lines, 1),
            "marginal_lines_per_rule": round(rule_layer_lines / len(rows), 1),
        }
    return derived


def summarize(snapshot: Path) -> dict:
    meta = {}
    meta_path = snapshot / "meta.json"
    if meta_path.is_file():
        meta = json.loads(meta_path.read_text())

    layers = read_layers(snapshot / "loc-summary.txt")
    rows = read_rule_loc(snapshot / "rule-loc.csv")
    rule_layer_lines = None
    if layers and "f" in layers["buckets"]:
        rule_layer_lines = layers["buckets"]["f"]["lines"]

    summary = {
        "snapshot": snapshot.name,
        "meta": meta,
        "checks": read_checks(snapshot),
        "status": {
            "all": read_status(snapshot / "rule-status.tsv"),
            "core": read_status(snapshot / "core-rule-status.tsv"),
        },
        "layers": layers,
        "rules": derive_rules(rows, rule_layer_lines) if rows else None,
    }
    return summary


# ---------------------------------------------------------------------------
# Reporting.
# ---------------------------------------------------------------------------


def thousands(n: float) -> str:
    return f"{n:,.0f}"


def report(summary: dict) -> str:
    out: list[str] = []
    w = out.append

    meta = summary.get("meta", {})
    w(f"Euthyna snapshot  {summary['snapshot']}")
    commit = meta.get("logos_commit", "unknown")
    w(f"  Logos {commit[:12]}{' (dirty)' if meta.get('logos_dirty') else ''}"
      f"  measured {meta.get('started', '?')}")
    w("")

    status = summary.get("status", {}).get("all")
    core = summary.get("status", {}).get("core")
    if status:
        w("Proof status")
        w(f"  all rules    {thousands(status.get('Total', 0)):>9}"
          f"   proven {thousands(status.get('Proven', 0))}"
          f"   unproven {thousands(status.get('Unproven', 0))}"
          f"   out of scope {thousands(status.get('OutOfScope', 0))}")
        if core:
            w(f"  core rules   {thousands(core.get('Total', 0)):>9}"
              f"   proven {thousands(core.get('Proven', 0))}"
              f"   unproven {thousands(core.get('Unproven', 0))}")
        w("")

    checks = summary.get("checks", {})
    if checks:
        w("Structural checks")
        for name in ("proof-hygiene", "proof-modularity", "rule-style", "checker-soundness"):
            if name in checks:
                w(f"  {name:<20} {checks[name]}")
        w("")

    layers = summary.get("layers")
    if layers:
        w("Layers  (LOC = non-blank, non-comment)")
        for key in sorted(layers["pieces"]):
            p = layers["pieces"][key]
            if "title" not in p:
                continue
            w(f"  ({key}) {p['title'][:52]:<52} {thousands(p['lines']):>9}"
              f"  {p['files']:>4} files")
        buckets = layers.get("buckets", {})
        if buckets:
            proof_total = layers["pieces"].get("4", {}).get("lines", 0)
            w("")
            w("  Proof, by bucket (disjoint)")
            for key in sorted(buckets):
                b = buckets[key]
                share = f"{100 * b['lines'] / proof_total:5.1f}%" if proof_total else "     "
                w(f"    ({key}) {b['title'][:46]:<46} {thousands(b['lines']):>9} {share}")
        w("")

    rules = summary.get("rules")
    if rules:
        pl = rules["proof_loc"]
        w(f"Per-rule proof reach  ({rules['count']} rules)")
        w(f"  min {thousands(pl['min'])}   p25 {thousands(pl['p25'])}"
          f"   median {thousands(pl['median'])}   p75 {thousands(pl['p75'])}"
          f"   max {thousands(pl['max'])}")
        fl = rules["floor"]
        w("")
        w("Derived")
        w(f"  floor                 {thousands(fl['lines']):>9}  lines every rule proof reaches"
          f" ({fl['rule']})")
        sp = rules["surplus"]
        w(f"  surplus, median       {thousands(sp['median']):>9}  lines a rule adds over the floor")
        w(f"  surplus, total        {thousands(sp['total']):>9}")
        w(f"  top-decile share      {sp['top_decile_share'] * 100:>8.1f}%  of surplus held by the"
          f" heaviest {max(1, rules['count'] // 10)} rules")
        lev = rules.get("leverage")
        if lev:
            w(f"  leverage              {lev['factor']:>9}x  times the average rule-layer line is"
              " reached")
            w(f"  marginal per rule     {thousands(lev['marginal_lines_per_rule']):>9}  lines of"
              " rule layer per rule")
        w(f"  proof per prog line   {rules['proof_per_prog_line']['median']:>9}x  median")
        w("")
        w("Heaviest rules by surplus")
        for entry in sp["heaviest"][:10]:
            w(f"  {entry['rule']:<40} {thousands(entry['surplus']):>9}")

    return "\n".join(out)


def main(argv: list[str]) -> int:
    as_report = "--report" in argv
    args = [a for a in argv if not a.startswith("--")]
    if len(args) != 1:
        print(__doc__.strip().splitlines()[-3], file=sys.stderr)
        print("usage: derive.py [--report] <snapshot>", file=sys.stderr)
        return 2

    snapshot = Path(args[0]).resolve()
    if not snapshot.is_dir():
        print(f"error: no snapshot directory: {snapshot}", file=sys.stderr)
        return 2

    cached = snapshot / "summary.json"
    if as_report and cached.is_file():
        summary = json.loads(cached.read_text())
    else:
        summary = summarize(snapshot)

    if as_report:
        print(report(summary))
    else:
        print(json.dumps(summary, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
