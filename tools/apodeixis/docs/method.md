# Method

How a run is done, what is recorded, and the rules that keep a run from
measuring the wrong thing. **Goal 3.**

There is no harness here and there is not meant to be one yet. The parent's
generator is the instrument, invoked exactly as a person would invoke it, and a
wrapper around it would be one more thing that could be wrong. What this page
replaces a harness with is a protocol short enough to follow by hand and precise
enough that two runs are comparable.

## The rules

**0. No run happens before the gate opens.** The charter's
[gate](../README.md#the-gate) is a precondition of this entire page: the Alethe
maintainers are asked first, by a person, and nothing on it is done while that
ask is outstanding or after a no. Every stage below assumes permission that has
not been given. The rule is placed first because a protocol page reads as an
invitation to follow it.

The rest are about measuring the right thing once there is anything to measure.

**1. The parent is never modified to make a run succeed.** Not the templates,
not the generator, not the installer, not a flag default. The moment a run only
works against a patched parent it has stopped measuring the framework and
started measuring a patch. Where a modification is what it would take, the
modification is *described* in the ledger entry — precisely enough that somebody
could apply it — and not applied.

The corollary is the useful one: **the workaround goes in the ledger before it
goes in the signature.** A rendering bent until it compiles, with no record of
the bend, is a run that reports success and has measured nothing.

**2. Everything written stays under `tools/apodeixis/`.** The generator is
pointed at `work/` with `--out`; generated trees are untracked, and nothing
outside this directory is written, ever, including by a build.

**3. The command is a file, not a memory.** Every run records the exact command
line, the parent's commit, the compiler pin it built against, and the fragment
the signature was at. A finding whose provenance is *"it did this last week"* is
not a finding.

## A run

Four stages, and each one can produce ledger entries. Stopping at any of them is
a result, provided where it stopped is written down.

| stage | what happens | what it can show |
| --- | --- | --- |
| **render** | a fragment of the target is written as a Eunoia signature and semantics in [`../signature/`](../signature/README.md) | what could not be said at all — the entries that never reach a tool |
| **contract** | the installer checks the signature contract against the compiler's output before installing anything | the framework refusing in the open, which is its best behaviour |
| **generate** | `scripts/new-checker.sh` with `--out` into `work/`, and the profile flags the fragment claims | derived-answer disagreements, and what landed in the seam |
| **build** | `lake build` in the generated project, then its own regression suite | mis-shaped obligations, and whether a proof of a refutation checks |

A run is named by the date and the fragment, and its record lives beside its
ledger entries.

## What counts as a break

The four grades are in [hypotheses.md](hypotheses.md) — *refused*,
*mis-shaped*, *silently wrong*, *disproportionate* — and the grading is done
when the entry is written rather than at the end, because a grade assigned after
the conclusion is known is a grade assigned to support it.

Two entries that are **not** breaks, and both will be tempting:

- **A rule that is hard to render.** Alethe rules were written for a different
  checker; rendering one badly is this project's error and the framework's
  business only if it could not have been rendered well. The first hypothesis is
  always that the probe is bad.
- **A `sorry` in the generated project.** Every generated checker ships that way,
  by design and on the front page. What would be a finding is a `sorry` whose
  *statement* is wrong — an obligation that could not be discharged even in
  principle — and that is a *mis-shaped*, recorded as such.

## The fragment discipline

Fragments are chosen for what they stress, never for coverage, and the order is
cheapest-load-first: enough of the propositional core to make a refutation
expressible at all, then one fragment per hypothesis in
[hypotheses.md](hypotheses.md), starting with the ones that need no new machinery
and ending with contexts.

What is skipped is written down when it is skipped. An unlisted omission is the
one way this project can produce a misleading result while every individual
entry in it is true.

## What a green run means

That the checks passed. A generated checker ships compiling and unproven; the
fragments are chosen adversarially rather than representatively; and the
translation, the parser and every rule's proof are outside what a successful
build establishes.

Nothing here is evidence that Alethe proofs can be checked soundly by anything,
and no summary of a run may be written in a way that could be read as saying so.
