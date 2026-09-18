# data/

`snapshots/<date>-<logos-commit>[-dirty][-tag]/` — one directory per run of
`bin/euthyna measure`, holding every measure's raw output verbatim plus
`meta.json` (what was measured), `measures.tsv` (what ran), and `summary.json`
(the derived analysis).

These are kept in git, at about 150 KB each — everything but the scatter, which `euthyna plot` regenerates. A single snapshot says what the
proof is like; a series says what it is doing, which is the more useful thing
and cannot be reconstructed after the fact.

A `-dirty` suffix means the Logos checkout had uncommitted changes when it was
measured, so that snapshot is not exactly reproducible. It is still worth
keeping, and the name says so.

`bin/euthyna site` renders every saved snapshot for the
[public reports](https://ajreynol.github.io/eudaimonia/). The site includes dated
links and copies of `rule-partition.csv`, `meta.json`, and `summary.json`;
readers can download the measurements behind a figure. Generated HTML stays
out of git and is rebuilt by the Reports workflow. See
[the publishing guide](../docs/publishing.md).
