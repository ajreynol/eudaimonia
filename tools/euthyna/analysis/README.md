# analysis/

Two things, kept apart on purpose.

`upstream/` is Logos's own measurement scripts, vendored **byte for byte** and
never edited, pinned by `upstream/MANIFEST` to a Logos commit with a SHA-256
per file. They are better instruments than anything written from outside the
development would be, and they stay evidence about Logos only for as long as
nobody touches them. `bin/euthyna verify` re-checks the digests;
`bin/euthyna sync` re-copies and reports what moved.

`derive.py` is Euthyna's. It reads those scripts' **output** and never their
internals, and computes the metrics upstream does not: the floor, per-rule
surplus, concentration, leverage, and the proof-per-program-line price. It
emits `summary.json` into a snapshot and renders the report `bin/euthyna show`
prints.

The seam between them is the point. Upstream answers what upstream answers;
everything downstream of that is Euthyna's, and is marked as such.

See [../docs/method.md](../docs/method.md) for why it is arranged this way,
and [../docs/measures.md](../docs/measures.md) for what each measure reports.
