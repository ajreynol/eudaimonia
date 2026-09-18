# Publishing and sharing reports

The public entry point is **<https://ajreynol.github.io/eudaimonia/>**.
Euthyna's reports are a static website built from the measurements kept in
this repository. Readers need a browser; they do not need a checkout, Python,
Lean, or Logos.

## Which link to share

| Link | Use it for |
| --- | --- |
| [Report index](https://ajreynol.github.io/eudaimonia/) | Introducing the reports and browsing the saved measurements. |
| [Latest rule scatter](https://ajreynol.github.io/eudaimonia/euthyna/) | Following the newest saved measurement. This URL stays the same as new snapshots arrive. |
| `https://ajreynol.github.io/eudaimonia/euthyna/snapshots/<snapshot-id>/` | Citing a particular measurement. Every report's **Copy snapshot link** button copies this dated URL. |

For example, the September 2 measurement is at
[2026-09-02-7ff136bb6174-dirty](https://ajreynol.github.io/eudaimonia/euthyna/snapshots/2026-09-02-7ff136bb6174-dirty/).
The dated URL retains that snapshot's measurements; the renderer can improve
over time. A snapshot marked `dirty` includes uncommitted Logos changes, so its
commit alone is insufficient to reproduce the measured source.

Use **Download SVG** for a standalone figure suitable for slides or documents.
Use **Download CSV** for the plotted numbers. Each dated directory also serves
`meta.json` and `summary.json` alongside the report. The chart's method link
explains how shared code is partitioned and why LOC is not a measure of effort.

## Build and preview locally

From the repository root:

```bash
tools/euthyna/bin/euthyna site
python3 -m http.server 8000 --directory tools/euthyna/site
```

Open <http://localhost:8000/>. The site also works by opening
`tools/euthyna/site/index.html` directly. Copy-link buttons always refer to the
public snapshot URL, even in a local preview.

The builder uses only Python's standard library and the saved snapshots.
It never reads the current Logos checkout or contacts a network service.
It requires `rule-partition.csv`, `meta.json`, and `summary.json` for every
snapshot and fails on an incomplete snapshot instead of silently omitting it.
The latest report is selected by the measurement's `started` timestamp.

For another hosting location:

```bash
tools/euthyna/bin/euthyna site --out /tmp/euthyna-site --base-url https://example.org/reports
```

Upload that output directory to the specified URL. Navigation and downloads
use relative links; canonical and copied links use `--base-url`. The output
must be separate from the snapshot inputs.

## GitHub Pages deployment

The repository's [Reports workflow](../../../.github/workflows/reports.yml)
builds and tests the website on relevant pull requests. On `main`, it deploys
the generated site to GitHub Pages. The workflow can also be run manually.
It uses GitHub's [custom Pages workflow](https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages)
with a build artifact and a separate deployment job; it does not need a
`gh-pages` branch or generated HTML committed to git.

One-time repository setup: in **Settings → Pages → Build and deployment**,
set **Source** to **GitHub Actions**. Then push the workflow and report sources
to `main` (or run **Actions → Reports → Run workflow** if they are already there).
The URLs above become available after the first successful deployment.

To publish a new measurement:

1. Run `tools/euthyna/bin/euthyna measure --logos /path/to/logos`.
2. Run `tools/euthyna/bin/euthyna site` and inspect the report locally.
3. Commit the new snapshot's data and push it to `main`.
4. Check the **Reports** workflow's deployment result, then share the dated link.

The report index and latest page update automatically; older snapshot links
remain available as long as their saved inputs remain in the repository.
Keep snapshots that have been shared. The root README and documentation index
advertise the public report site.
