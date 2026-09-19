# Report site

Builds static reports from saved measurement snapshots, without running Logos
or the measurement tools. Only Python's standard library is required.

From Euthyna's directory:

```bash
scripts/euthyna site
scripts/euthyna plot
```

`build-site.py` builds the complete site; `plot-rules.py` renders a single
scatter. The shared launcher reads `euthyna.conf`. The builder also accepts
`--snapshots`, `--out` and `--base-url` directly.

Inputs default to `measurement/data/snapshots/`. Generated pages default to
`scratch/site/`, and standalone plots to `scratch/plots/<snapshot-id>/rules.html`.
Both are ignored by git and regenerated from the saved measurements. Tests
live in `tests/test_site.py`.

See the [publishing guide](../docs/publishing.md) for public URLs, previewing
and deployment, and [measurement](../measurement/README.md) for the producer
of the inputs.
