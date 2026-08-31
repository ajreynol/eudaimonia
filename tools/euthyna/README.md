# Euthyna

A research project about the proof in [Logos](https://github.com/cvc5/logos):
what it is made of, where its weight sits, and what would have to change for it
to cover more than one calculus.

Euthyna is not a tool. Nothing here is built, installed, or shipped. It
measures a Logos checkout it does not own and writes down what it found.

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

## An island

Euthyna lives in this repository and is connected to nothing in it.

- Nothing in Eudaimonia links here, imports from here, or runs anything here.
  No document outside this directory mentions Euthyna, and none should start.
- Euthyna reads a Logos checkout elsewhere on disk. It writes only inside
  `tools/euthyna/`, and never to the checkout it measures.
- It is not part of any build, any CI job, or any generated checker.

It sits here because the questions it asks are the ones this repository was
built out of, and because a finding worth having is worth having near the work
it bears on. It is not here because anything depends on it. If Euthyna were
deleted tomorrow, nothing in Eudaimonia would notice.

The one direction the connection does run is in what is learned. Eudaimonia
generalizes a checker away from its calculus; how far that can go is a
question about how much of Logos's proof is *about CPC* and how much is about
proof-checking as such. Euthyna is trying to answer that question with numbers.
That is an intellectual debt, not a technical one, and it is repaid in prose.

## What it does

The measuring is not Euthyna's invention. Logos already carries scripts that
count its own proof — rule status, lines by layer, per-rule cost, structural
invariants — and those are better evidence about Logos than anything written
from outside it would be. They are vendored here unedited, under
[`analysis/upstream/`](analysis/upstream/), pinned to a Logos commit and
checksummed.

What Euthyna adds is on top of them: a harness that runs all of them together
against one Logos revision and keeps the result
([`bin/euthyna`](bin/euthyna)), and a derivation that reads those results and
asks what they say about the *shape* of the proof
([`analysis/derive.py`](analysis/derive.py)) — how much of every rule's proof
is a fixed cost paid once, how much is the rule's own, how concentrated that
cost is, and what one line of checker costs in lines of proof.

## Layout

| path | what it holds |
| ---- | ------------- |
| `bin/euthyna` | the harness: stage a Logos checkout, run every measure, write a snapshot |
| `euthyna.conf` | where Logos is, where snapshots go |
| `analysis/upstream/` | Logos's own measurement scripts, vendored verbatim, with `MANIFEST` |
| `analysis/derive.py` | Euthyna's derived metrics, over those scripts' output |
| `data/snapshots/` | one directory per measurement run, kept in git |
| `docs/` | what is measured, how, what it showed, and where it goes next |

## Running it

```
tools/euthyna/bin/euthyna measure --logos ~/logos
```

Fifteen seconds, no build required, no write to the checkout. It stages a copy
of the Logos tree, runs the eight measures, writes
`data/snapshots/<date>-<commit>/`, and prints the report.

```
tools/euthyna/bin/euthyna measures      # the catalogue: what runs, what it needs
tools/euthyna/bin/euthyna show          # re-print the newest snapshot's report
tools/euthyna/bin/euthyna verify        # vendored scripts vs. MANIFEST
tools/euthyna/bin/euthyna sync          # re-vendor from a Logos checkout
```

## Where to read next

- [docs/method.md](docs/method.md) — what measuring a proof means here, and
  what these numbers are and are not evidence of.
- [docs/measures.md](docs/measures.md) — the catalogue: every measure, its
  unit, and the derived metrics built on it.
- [docs/baseline.md](docs/baseline.md) — the first measurement, and what it
  says.
- [docs/roadmap.md](docs/roadmap.md) — the analyses and visualizations this is
  being built toward.
