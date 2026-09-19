#!/usr/bin/env python3
"""Partitioned lines of proof, and lines of rule, per proof rule.

`cpc-rule-loc.py` reports each rule's transitive *reach*, and says plainly that
it is not a partition: a support file shared by four hundred rules is counted
four hundred times, so the column sums to twenty times the layer it measures.
That is the right answer to "what does this rule's proof depend on" and the
wrong one to "what does this rule cost", and cost is the question.

So this partitions instead, the way `cpc-loc-summary.py` partitions its buckets:
walk the rules in coreness order, and give every file to the *first* rule that
reaches it. Shared support lands on the most core rule that uses it; every later
rule reports only what it adds. The columns are disjoint and sum to their layer.

Two layers are partitioned, and they are the two axes of the scatter this
exists to draw:

  PROOF   The rule-proof layer -- bucket (f) of `cpc-loc-summary.py`, and
          nothing else. The central theorems are excluded entirely: type
          preservation, canonicity, translation, non-vacuity, closedness and
          the top-level soundness theorem are their own categories upstream,
          they are not any rule's cost, and attributing them to rules would
          bury the thing being looked for. The definitional base, the checker
          and the parser are excluded for the same reason.

  RULE    The rule itself: `__eo_prog_<rule>` in the checker, plus the helper
          definitions it calls, partitioned over the same order.

The partition is a function of `rule-order.txt`, which is append-only for
exactly this reason -- see `rule-order.py`. A rule's PROOF is not a property of
the rule alone: it is what the rule adds *given everything more core than it*.
Read the pair, not either number by itself.

Reconciliation is the guarantee. PROOF sums to bucket (f)'s line count as
`cpc-loc-summary.py` computes it, and the run fails if it does not.

Usage:
  rule-partition.py --root PATH [--order FILE] [--csv | --json]
"""

from __future__ import annotations

import argparse
import csv
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from euthyna_lean import (  # noqa: E402
    Tree, build_def_graph, def_closure, prog_name, read_order,
)

HERE = Path(__file__).resolve().parent
DEFAULT_ORDER = HERE / "rule-order.txt"


def partition(tree: Tree, order: list[str]) -> dict:
    """Partition the rule-proof layer and the checker's rule code over `order`."""
    layer, _buckets = tree.bucket_f()
    layer_loc = tree.total_loc(layer)

    prog_loc, prog_deps = build_def_graph(tree.root)

    present = set(tree.rule_names())
    ordered = [r for r in order if r in present]
    unordered = sorted(present - set(order))

    claimed_files: set[str] = set()
    claimed_defs: set[str] = set()
    rows = []

    for index, rule in enumerate(ordered, start=1):
        # PROOF: the rule's cone, restricted to the rule-proof layer, minus
        # everything a more core rule already claimed.
        cone = tree.rule_cone(rule) & layer
        own = cone - claimed_files
        claimed_files |= own

        # RULE: the rule's checker implementation and its helper closure, minus
        # helpers a more core rule already claimed.
        name = prog_name(rule)
        if name in prog_deps:
            dcone = def_closure(name, prog_deps)
            down = dcone - claimed_defs
            claimed_defs |= down
            rule_loc = sum(prog_loc[d] for d in down)
            rule_own = prog_loc.get(name, 0)
            rule_reach = sum(prog_loc[d] for d in dcone)
            rule_defs = len(down)
        else:
            dcone, down = set(), set()
            rule_loc = rule_own = rule_reach = rule_defs = 0

        rows.append({
            "rule": rule,
            "order": index,
            "proof_loc": tree.total_loc(own),
            "proof_files": len(own),
            "proof_reach_loc": tree.total_loc(cone),
            "proof_reach_files": len(cone),
            "rule_loc": rule_loc,
            "rule_defs": rule_defs,
            "rule_own_loc": rule_own,
            "rule_reach_loc": rule_reach,
        })

    unclaimed = layer - claimed_files
    partitioned = sum(r["proof_loc"] for r in rows)

    return {
        "rules": rows,
        "layer": {
            "files": len(layer),
            "lines": layer_loc,
            "partitioned_lines": partitioned,
            "unclaimed_files": len(unclaimed),
            "unclaimed_lines": tree.total_loc(unclaimed),
            "unclaimed": sorted(unclaimed, key=lambda m: (-tree.loc(m), m)),
        },
        "rule_code": {
            "defs_partitioned": len(claimed_defs),
            "lines_partitioned": sum(r["rule_loc"] for r in rows),
        },
        "order": {
            "file": str(DEFAULT_ORDER.name),
            "ordered": len(ordered),
            "unordered": unordered,
        },
    }


FIELDS = ["rule", "order", "proof_loc", "proof_files", "proof_reach_loc",
          "proof_reach_files", "rule_loc", "rule_defs", "rule_own_loc",
          "rule_reach_loc"]


def report(result: dict) -> str:
    out: list[str] = []
    w = out.append
    layer = result["layer"]
    rows = result["rules"]

    w("Partitioned per-rule LOC  (PROOF = bucket (f) only; central theorems excluded)")
    w("  Every proof file is claimed by the most core rule that reaches it, so")
    w("  the PROOF column is disjoint and sums to the rule-proof layer.")
    w("")
    w(f"{'#':>4} {'RULE':38s} {'PROOF':>8s} {'files':>6s} {'RULE_LOC':>9s} {'defs':>5s}"
      f" {'reach':>8s}")
    w("-" * 82)
    for r in sorted(rows, key=lambda r: (-r["proof_loc"], r["rule"])):
        w(f"{r['order']:>4} {r['rule']:38s} {r['proof_loc']:8d} {r['proof_files']:6d}"
          f" {r['rule_loc']:9d} {r['rule_defs']:5d} {r['proof_reach_loc']:8d}")
    w("-" * 82)
    w(f"{'':4} {'PARTITION TOTAL':38s} {layer['partitioned_lines']:8d}"
      f" {layer['files'] - layer['unclaimed_files']:6d}"
      f" {result['rule_code']['lines_partitioned']:9d}")
    w(f"{'':4} {'rule-proof layer (bucket f)':38s} {layer['lines']:8d} {layer['files']:6d}")
    if layer["unclaimed_files"]:
        w(f"{'':4} {'unclaimed by any rule':38s} {layer['unclaimed_lines']:8d}"
          f" {layer['unclaimed_files']:6d}")
        for m in layer["unclaimed"][:10]:
            w(f"{'':6} {m}")
    if result["order"]["unordered"]:
        w("")
        w(f"  {len(result['order']['unordered'])} rules are not in the order file and were"
          " skipped:")
        for r in result["order"]["unordered"][:10]:
            w(f"    {r}")
        w("  Run 'euthyna rules update'.")
    return "\n".join(out)


def main(argv: list[str]) -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--root", required=True, help="the Logos tree to measure")
    ap.add_argument("--order", help=f"the coreness order (default {DEFAULT_ORDER})")
    ap.add_argument("--csv", action="store_true", help="machine-readable CSV")
    ap.add_argument("--json", action="store_true", help="full result as JSON")
    ap.add_argument(
        "--allow-mismatch",
        action="store_true",
        help="report rather than fail when the partition does not sum to the layer",
    )
    args = ap.parse_args(argv)

    order_path = Path(args.order or DEFAULT_ORDER)
    if not order_path.is_file():
        print(f"error: no order file at {order_path}; run 'euthyna rules seed'", file=sys.stderr)
        return 2

    tree = Tree(args.root)
    if not tree.rule_names():
        print(f"error: no rules under {args.root}", file=sys.stderr)
        return 2

    result = partition(tree, read_order(order_path))
    layer = result["layer"]

    # The reconciliation that makes this a partition rather than an estimate.
    accounted = layer["partitioned_lines"] + layer["unclaimed_lines"]
    if accounted != layer["lines"]:
        print(
            "error: partition does not reconcile with the rule-proof layer.\n"
            f"  partitioned {layer['partitioned_lines']} + unclaimed"
            f" {layer['unclaimed_lines']} = {accounted}, layer is {layer['lines']}.\n"
            "  euthyna_lean.bucket_f() has drifted from cpc-loc-summary.py.",
            file=sys.stderr,
        )
        if not args.allow_mismatch:
            return 3

    if args.json:
        print(json.dumps(result, indent=2))
    elif args.csv:
        writer = csv.DictWriter(sys.stdout, fieldnames=FIELDS)
        writer.writeheader()
        for row in sorted(result["rules"], key=lambda r: r["order"]):
            writer.writerow(row)
    else:
        print(report(result))
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
