# analysis/

Two things, kept apart on purpose.

`upstream/` is Logos's own measurement scripts, vendored **byte for byte** and
never edited, pinned by `upstream/MANIFEST` to a Logos commit with a SHA-256
per file. They are better instruments than anything written from outside the
development would be, and they stay evidence about Logos only for as long as
nobody touches them. `bin/euthyna verify` re-checks the digests;
`bin/euthyna sync` re-copies and reports what moved.

Everything else here is Euthyna's:

| file | what it does |
| ---- | ------------ |
| `euthyna_lean.py` | the shared primitives — Lean-aware line count, module import graph, definition call graph, and the bucket attribution that identifies the rule-proof layer |
| `rule-order.py` | seeds, checks and updates `rule-order.txt`, the append-only coreness order |
| `rule-order.txt` | that order: 591 rules, most core first. The partition is a function of it |
| `rule-partition.py` | the partitioned per-rule proof and rule sizes, reconciled against the layer or the run fails |
| `plot-rules.py` | the scatter those two columns are the axes of, as a standalone HTML page |
| `derive.py` | the metrics over everything's output: floor, surplus, concentration, leverage, price, and the partition's own statistics |

`derive.py` and `plot-rules.py` read the vendored scripts' **output** and never
their internals. `euthyna_lean.py` is the exception and is documented as one:
it restates upstream's line count and bucket attribution because a partition
cannot be derived from a printed report. What keeps that honest is arithmetic
— the partition must sum to the layer total `cpc-loc-summary.py` computes
independently, and `rule-partition.py` exits non-zero when it does not.

The seam is the point. Upstream answers what upstream answers; everything
downstream of that is Euthyna's, and is marked as such.

See [../docs/method.md](../docs/method.md) for why it is arranged this way,
and [../docs/measures.md](../docs/measures.md) for what each measure reports.
