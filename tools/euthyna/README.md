# Euthyna

A research project about the proof in [Logos](https://github.com/cvc5/logos):
what it is made of, where its weight sits, and what would have to change for it
to cover more than one calculus.

**[Public reports](https://ajreynol.github.io/eudaimonia/)** ·
**[Latest rule scatter](https://ajreynol.github.io/eudaimonia/euthyna/)**

Euthyna measures a Logos checkout it does not own and publishes the results as
interactive reports. Each report has a dated link, downloadable data, and an
SVG export. Use **Copy snapshot link** to share a particular measurement.
The [publishing guide](docs/publishing.md) explains the URLs and deployment.

## The name

*Euthyna* (Greek εὔθυνα, from εὐθύνω "to straighten, to set right, to call to
account", from εὐθύς "straight") is the audit every Athenian official submitted
to on leaving office. It was not an accusation and not a formality: the holder
of an office had to render, in public, an account of what had been done with
it, and that account was open to anyone's question.

The account rendered was a λόγος. Logos is named for the account one gives of
a thing; Euthyna is named for the audit that account is submitted to. That is
the whole of the relationship, and it is the right one — the audit does not
correct the account, it asks it what it is made of.

## Relationship to Eudaimonia

Euthyna lives in this repository and shares its public report site.

**Not an island.** On 2026-09-18 the maintainer asked for the reports to be
advertised and easy to share externally. This replaces the earlier isolation
policy: the parent links here and a dedicated workflow publishes the reports.
For compatibility with the parent's pinned policy checker, the declaration is
also recorded in its required format:

```text
rule 10: advertised by the parent; built and published by dedicated report CI.
```

- Eudaimonia's README and documentation index link to the reports so readers
  can find them. A dedicated workflow builds and publishes the site.
- Euthyna reads a Logos checkout elsewhere on disk. It writes only inside
  `tools/euthyna/`, and never to the checkout it measures.
- It is independent of the checker build and its CI. Publishing reads saved
  measurements; it does not build or modify Logos or a generated checker.

It sits here because the questions it asks are the ones this repository was
built out of, and because a finding worth having is worth having near the work
it bears on. It is not here because anything depends on it. If Euthyna were
deleted tomorrow, nothing in Eudaimonia would notice.

The research connection is in what is learned. Eudaimonia
generalizes a checker away from its calculus; how far that can go is a
question about how much of Logos's proof is *about CPC* and how much is about
proof-checking as such. Euthyna is trying to answer that question with numbers.
That is an intellectual debt, not a technical one, and it is repaid in prose.

**Publishing stance.** **No paper on its own, and that is the intended
outcome.** What this establishes — what the generated development is made of and
where its weight sits — is a section a paper about Logos and the compiler needs
and cannot write about itself. Split out, both halves are weaker: theirs
unmeasured, and this one a set of numbers about a development the reader has not
been shown. An audit of somebody else's proof is the measurement that makes
their claim credible, which is a compliment to it rather than a dismissal of it.
The interactive reports are published on the website; that is separate from
whether this work warrants a standalone paper.

## What it does

The measuring is not Euthyna's invention. Logos already carries scripts that
count its own proof — rule status, lines by layer, per-rule cost, structural
invariants — and those are better evidence about Logos than anything written
from outside it would be. The whole of its `scripts/` directory is snapshotted
here unedited, under [`measurement/upstream/`](measurement/upstream/), pinned to a
Logos commit and checksummed. Which of them measure a proof is a judgement that
will change; which of them existed at a commit is a fact, and the fact is what
is kept.

What Euthyna adds sits on top of them:

- a harness that runs the measuring ones together against one Logos revision
  and keeps the result ([`scripts/euthyna`](scripts/euthyna));
- a **partition** of the rule-proof layer across the rules
  ([`measurement/rule-partition.py`](measurement/rule-partition.py)). Upstream reports
  each rule's transitive *reach*, which double-counts everything shared and sums
  to twenty times the layer it measures. This gives every shared file to the
  most core rule that uses it, so the columns are disjoint and sum to the layer
  exactly — and the run fails if they do not;
- the **coreness order** that partition is a function of
  ([`measurement/rule-order.txt`](measurement/rule-order.txt)), maintained here and
  append-only, so two snapshots stay comparable;
- the **scatter** those two axes exist for
  ([`report_site/plot-rules.py`](report_site/plot-rules.py)): proof size against rule
  size, one point per rule, which is where "short but hard to prove" and "large
  but easy to prove" become visible as places on a chart;
- and a derivation over all of it ([`measurement/derive.py`](measurement/derive.py))
  — the fixed cost every rule pays, how concentrated the variable cost is, and
  what a line of rule costs in lines of proof.

## Layout

| path | what it holds |
| ---- | ------------- |
| `scripts/euthyna` | shared command launcher for measurement and reports |
| [`measurement/`](measurement/README.md) | measurement implementation, vendored instruments and saved evidence; `measurement/euthyna` runs the harness |
| [`report_site/`](report_site/README.md) | site builder and chart renderer, reading saved evidence |
| `euthyna.conf` | where Logos is, where snapshots go |
| `measurement/upstream/` | the whole of Logos's `scripts/`, snapshotted verbatim, with `MANIFEST` |
| `measurement/rule-order.txt` | the coreness order over the rules — append-only, maintained here |
| `measurement/rule-partition.py` | the partitioned per-rule proof and rule sizes |
| `report_site/plot-rules.py` | the scatter, as a standalone HTML page |
| `report_site/build-site.py` | the public report index, latest page, dated reports, and data downloads |
| `measurement/derive.py` | Euthyna's derived metrics, over those scripts' output |
| `measurement/euthyna_lean.py` | the Lean line count, import graph and bucket attribution the three share |
| `measurement/data/snapshots/` | one directory per measurement run, kept in git |
| `scratch/site/` | generated website, ignored locally and deployed by GitHub Actions |
| `scratch/plots/` | regenerated standalone plots, ignored by git |
| `tests/` | report data, link and output-location checks |
| `docs/` | what is measured, how, what it showed, and where it goes next |

## Running it

```
tools/euthyna/scripts/euthyna measure --logos ~/logos
```

Fifteen seconds, no build required, no write to the checkout. It stages a copy
of the Logos tree, runs the nine measures, writes
`measurement/data/snapshots/<date>-<commit>/`, draws the scatter, and prints the report.

```
tools/euthyna/scripts/euthyna measures      # the catalogue: what runs, what it needs
tools/euthyna/scripts/euthyna show          # re-print the newest snapshot's report
tools/euthyna/scripts/euthyna plot          # redraw the newest snapshot's scatter
tools/euthyna/scripts/euthyna site          # build the full shareable website
tools/euthyna/scripts/euthyna rules check   # is the coreness order current?
tools/euthyna/scripts/euthyna rules update  # append new rules, drop departed ones
tools/euthyna/scripts/euthyna verify        # vendored scripts vs. MANIFEST
tools/euthyna/scripts/euthyna sync          # re-snapshot from a Logos checkout
```

The run writes the scatter to `scratch/plots/<snapshot-id>/rules.html` and tells
you where. Renderings are separate from the saved measurements and ignored by
git; `euthyna plot` regenerates them from a snapshot's `rule-partition.csv`.

For sharing, use the website. `euthyna site` builds it locally at
`tools/euthyna/scratch/site/index.html` from every saved snapshot, without a Logos
checkout or extra Python packages. The Reports workflow builds and deploys
the same site when report sources or snapshots are pushed to `main`.
See [publishing.md](docs/publishing.md) for first-time Pages setup and previewing.

## Where to read next

- [docs/publishing.md](docs/publishing.md) — public links, local preview, and deployment.
- [docs/method.md](docs/method.md) — what measuring a proof means here, and
  what these numbers are and are not evidence of.
- [docs/measures.md](docs/measures.md) — the catalogue: every measure, its
  unit, and the derived metrics built on it.
- [docs/partition.md](docs/partition.md) — how the partition works, why the
  order is append-only, and how to read a point on the scatter.
- [docs/baseline.md](docs/baseline.md) — the first measurement, and what it
  says.
- [docs/roadmap.md](docs/roadmap.md) — the analyses and visualizations this is
  being built toward.
