# data/

`snapshots/<date>-<logos-commit>[-dirty][-tag]/` — one directory per run of
`bin/euthyna measure`, holding every measure's raw output verbatim plus
`meta.json` (what was measured), `measures.tsv` (what ran), and `summary.json`
(the derived analysis).

These are kept in git, at about 120 KB each. A single snapshot says what the
proof is like; a series says what it is doing, which is the more useful thing
and cannot be reconstructed after the fact.

A `-dirty` suffix means the Logos checkout had uncommitted changes when it was
measured, so that snapshot is not exactly reproducible. It is still worth
keeping, and the name says so.
