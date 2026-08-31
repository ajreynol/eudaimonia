#!/usr/bin/env python3
"""Maintain Euthyna's coreness order over the proof rules.

The partition in `rule-partition.py` attributes every shared proof file to the
*most core* rule that reaches it. "Most core" is not a fact the source can be
asked for, so it is a decision, and this is where the decision is written down:
`rule-order.txt` is a total order over the rules, maintained here, and the
partition is a function of it.

The order is **append-only**. New rules go on the end; deleted rules come out;
nothing is ever moved. That rule is what makes two snapshots comparable — if
positions could shift, a rule's partitioned size could change without a line of
its proof changing, and a series of measurements would be meaningless. The cost
of the discipline is that a genuinely fundamental rule added next year still
sorts last and so claims nothing that an existing rule already holds. That is
the intended trade: stability over freshness, with `reseed` as the deliberate,
dated escape hatch.

Seeding, done once:

  1. The 164 rules of Logos's own `core-rules.txt`, in that file's order. It is
     a curated list -- it opens `scope`, `process_scope`, `ite_eq`, `split`,
     `resolution` -- and is the best available statement of what CPC considers
     fundamental. Euthyna does not second-guess it.
  2. Every remaining rule, by ascending proof-cone size, then by name. A rule
     that depends on less is more foundational, so the smallest cone claims the
     shared base and later rules report only what they add. This is the same
     principle `cpc-loc-summary.py` uses to make its buckets disjoint.

Usage:
  rule-order.py seed   --logos PATH [--out FILE] [--force]
  rule-order.py check  --logos PATH [--order FILE]   # exit 1 on drift
  rule-order.py update --logos PATH [--order FILE]   # append new, drop gone
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from euthyna_lean import Tree, read_order  # noqa: E402

HERE = Path(__file__).resolve().parent
DEFAULT_ORDER = HERE / "rule-order.txt"
CORE_RULES = HERE / "upstream" / "core-rules.txt"

HEADER = """\
# Euthyna's coreness order over the proof rules of CPC.
#
# A total order, most core first. `rule-partition.py` walks it and gives every
# shared proof file to the first rule that reaches it, so this file decides the
# attribution and nothing else does.
#
# APPEND-ONLY. New rules are added at the end by `rule-order.py update`;
# rules that no longer exist are removed. Nothing is ever reordered -- a
# reordering would change rules' partitioned sizes without any proof changing,
# and would make snapshots taken either side of it incomparable.
#
# Seeded {seeded} from Logos {commit}:
#   positions 1-{ncore}: Logos's own core-rules.txt, in its curated order.
#   positions {rest_start}-{ntotal}: the remaining rules by ascending proof-cone
#     size, then by name -- the rule that depends on least claims the shared
#     base, so later rules report only what they add.
#
# Blank lines and lines beginning with # are ignored. One rule file stem per
# line, matching Cpc/Proofs/Rules/<name>.lean.
"""


def seeded_order(tree: Tree) -> tuple[list[str], int]:
    """The initial order, and how many of its entries came from core-rules.txt."""
    present = set(tree.rule_names())

    core: list[str] = []
    if CORE_RULES.is_file():
        by_lower = {r.lower(): r for r in present}
        for line in CORE_RULES.read_text(encoding="utf-8").splitlines():
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            stem = by_lower.get(line.lower())
            if stem is not None and stem not in core:
                core.append(stem)

    rest = sorted(present - set(core), key=lambda r: (len(tree.rule_cone(r)), r))
    return core + rest, len(core)


def cmd_seed(args: argparse.Namespace) -> int:
    out = Path(args.out or DEFAULT_ORDER)
    if out.exists() and not args.force:
        print(
            f"error: {out} already exists.\n"
            "  The order is append-only; use 'update' to take in new rules.\n"
            "  Reseeding renumbers everything and makes existing snapshots\n"
            "  incomparable. If that is really intended, pass --force and say\n"
            "  so in docs/method.md with the date.",
            file=sys.stderr,
        )
        return 1

    tree = Tree(args.logos)
    order, ncore = seeded_order(tree)
    if not order:
        print(f"error: no rules found under {args.logos}", file=sys.stderr)
        return 2

    header = HEADER.format(
        seeded=args.date or "(undated)",
        commit=args.commit or "(unknown)",
        ncore=ncore,
        rest_start=ncore + 1,
        ntotal=len(order),
    )
    out.write_text(header + "\n" + "\n".join(order) + "\n", encoding="utf-8")
    print(f"seeded {len(order)} rules ({ncore} from core-rules.txt) -> {out}")
    return 0


def drift(tree: Tree, order_path: Path) -> tuple[list[str], list[str], list[str]]:
    """(order, rules present but unordered, rules ordered but absent)."""
    order = read_order(order_path)
    present = set(tree.rule_names())
    listed = set(order)
    return order, sorted(present - listed), [r for r in order if r not in present]


def cmd_check(args: argparse.Namespace) -> int:
    order_path = Path(args.order or DEFAULT_ORDER)
    if not order_path.is_file():
        print(f"error: no order file at {order_path}; run 'seed'", file=sys.stderr)
        return 2

    tree = Tree(args.logos)
    order, new, gone = drift(tree, order_path)

    dupes = sorted({r for r in order if order.count(r) > 1})
    if dupes:
        print(f"  DUPLICATE  {len(dupes)}: {', '.join(dupes[:5])}")

    for r in new:
        print(f"  new        {r}")
    for r in gone:
        print(f"  gone       {r}")

    if not new and not gone and not dupes:
        print(f"Order is current: {len(order)} rules, all present.")
        return 0
    print(
        f"\n{len(order)} ordered, {len(new)} new, {len(gone)} gone."
        "  'rule-order.py update' to take them in.",
        file=sys.stderr,
    )
    return 1


def cmd_update(args: argparse.Namespace) -> int:
    order_path = Path(args.order or DEFAULT_ORDER)
    if not order_path.is_file():
        print(f"error: no order file at {order_path}; run 'seed'", file=sys.stderr)
        return 2

    tree = Tree(args.logos)
    order, new, gone = drift(tree, order_path)
    if not new and not gone:
        print(f"Order is current: {len(order)} rules, all present.")
        return 0

    text = order_path.read_text(encoding="utf-8")
    lines = text.splitlines()

    # Drop the gone, keeping every comment and blank line where it is.
    goneset = set(gone)
    kept = [ln for ln in lines if ln.strip() not in goneset]

    # Append the new alphabetically -- deterministic, and it makes clear they
    # were not placed by any judgement of coreness.
    while kept and not kept[-1].strip():
        kept.pop()
    if new:
        kept.append("")
        kept.append(f"# Appended {args.date or '(undated)'}"
                    f"{f' from Logos {args.commit}' if args.commit else ''}:"
                    f" {len(new)} new rule{'s' if len(new) != 1 else ''}.")
        kept.extend(sorted(new))

    order_path.write_text("\n".join(kept) + "\n", encoding="utf-8")

    for r in gone:
        print(f"  removed    {r}")
    for r in sorted(new):
        print(f"  appended   {r}")
    print(f"Order now {len(read_order(order_path))} rules.")
    return 0


def main(argv: list[str]) -> int:
    common = argparse.ArgumentParser(add_help=False)
    common.add_argument("--logos", required=True, help="the Logos checkout to read")
    common.add_argument("--order", help=f"the order file (default {DEFAULT_ORDER})")
    common.add_argument("--date", help="date to record in a header line")
    common.add_argument("--commit", help="Logos commit to record in a header line")

    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    sub = parser.add_subparsers(dest="cmd", required=True)
    p_seed = sub.add_parser("seed", parents=[common], help="write the initial order (once)")
    p_seed.add_argument("--out")
    p_seed.add_argument("--force", action="store_true")
    sub.add_parser("check", parents=[common], help="report drift; exit 1 if any")
    sub.add_parser("update", parents=[common], help="append new rules, remove departed ones")

    args = parser.parse_args(argv)
    return {"seed": cmd_seed, "check": cmd_check, "update": cmd_update}[args.cmd](args)


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
