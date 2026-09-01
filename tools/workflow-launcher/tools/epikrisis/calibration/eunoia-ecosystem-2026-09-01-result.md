# Calibration result — eunoia-ecosystem, 2026-09-01

Scored against [the prior](eunoia-ecosystem-2026-09-01.md), which was written
before the detectors ran. **Recall is the number that matters**; the count of
candidates the prior did not list is reported but is not an error rate, for the
reason [`../docs/judgement.md`](../docs/judgement.md) gives.

## Recall: 5 of 6, with one instructive miss

| # | prior | found | evidence |
| --- | --- | --- | --- |
| 1 | logos comes first and is the only long-running artifact | **yes** | `repo-added` logos 2026-03-03; the next source is 179 days later |
| 2 | a burst at the end of August, four repositories within days | **yes** | `repo-added` anoieu and eudaimonia 2026-08-29, dokimasia 08-30, koine 08-31 |
| 3 | a governance cluster inside the burst, written in one tree | **yes**, and sharper than the prior | all 28 `governance` candidates are in one source |
| 4 | CI early in each new tree, one job running another repository's checker | **yes**, and sharper than the prior | the two newest sources' *first* CI file is the other repository's check — `policy.yml` and `anoieu.yml` |
| 5 | child projects being started inside two of the trees | **missed by the detector meant to find it** | see below |
| 6 | quiet stretches in logos and nowhere else | **yes** | both `quiet` candidates are logos; none elsewhere |

Two of the hits came back more specific than the prior was, which is the outcome
this step exists to find: the prior said governance was *written in one tree and
adopted by the others*, and the evidence says the adopting trees' first act of
self-checking **is** the other tree's checker. That is a stronger statement than
the one being tested, and it is the sort of thing a person summarising by hand
would have had to already know.

## The miss, and its cause

The prior expected child projects to appear as events. `birth` did not report
one, and the cause is a declared threshold rather than a bug: `prefix_depth` is
1, so every child project inside a `tools/` directory collapses into the single
prefix `tools`. The detector saw one birth where the prior expected several.

It is *partly* visible by accident — 15 candidates carry a `tools/…` path,
because the `governance` detector records full file paths rather than prefixes.
So the information is in the evidence and the detector designed to surface it did
not surface it, which is the worst of the three possible outcomes: a reader
would have to notice it in another detector's output.

**This is a hole with a name**, which is what calibration is for, and the fix is
a threshold rather than a new detector. It is deliberately not applied to this
run: changing a threshold after the events exist is exactly what the manifest
flag records, and a calibration result obtained by retuning until the prior was
matched would be worthless.

## One prior expectation that was wrong in the useful direction

The prior listed *the fuzzer being folded back into its parent* under **what the
detectors will miss**, on the grounds that it is a decision recorded in prose.
The tree shows it: a prefix appears alongside the analyzer's own. So the *event*
was derivable and only the *decision* was not — a finer distinction than the
prior drew, and one worth carrying into the next prior.

## Contamination, restated

The calibrator had read these trees the same day, for other reasons. Recall of
5 of 6 is therefore an optimistic number and should not be quoted as the tool's
performance. A clean calibration needs somebody who knows a subject and has not
just finished reading it.
