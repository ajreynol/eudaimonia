# Making the second half falsifiable

**Goal 3.** The narrative is checkable against its evidence by a program. The
assessment — *what has this evolution done well and badly* — is not, and this
page is everything that stands in for that.

## The failure this is arranged against

The host one level up states it about its own findings register: the failure mode
of a document like that written by an agent is **a list of flattering
observations**. That register is about a family the writer belongs to. This
project's output is about a subject the writer has no stake in, which removes one
source of flattery and adds a worse one — the pull toward a *tidy* story, in
which a history has themes, the themes have lessons, and every event supports
one.

Both failures have the same shape: the document is unfalsifiable, and it reads
well. Everything below exists to make a report capable of being wrong.

## Pre-registration

**The questions are written before the corpus is pinned**, into `questions.md`,
and their digest is recorded in the run manifest.

This is the cheapest mechanism here and the one with the most effect. A question
written after the evidence is a question chosen because there is an answer to it;
a set of questions fixed in advance can go unanswered, and *"we asked this and
the evidence did not settle it"* is a finding a tidy story has no room for.

Questions may be added mid-run. Adding one changes the digest, the manifest
records that it no longer matches, and the report says so — the mechanism is not
a prohibition, it is a record of when each question was asked.

## What an assessment is

One record per claim, beside the narrative rather than inside it:

```json
{ "id": "A3", "direction": "well | badly",
  "claim": "<one sentence, about what happened>",
  "rests_on": ["E0012", "C0007"],
  "falsified_by": "<what would show this is wrong>",
  "confidence": "low | medium | high",
  "scope": "<what this does not cover>" }
```

The two fields that do the work:

**`falsified_by`** must name something a reader could go and look at. *"Evidence
to the contrary"* is not a falsifier; *"a rewrite of the same subsystem in the
following year, which would make this a phase rather than a correction"* is.
A claim nobody can imagine being wrong is not an assessment, it is a
description with an adjective, and stage 6 rejects the record if the field is
empty.

**`scope`** is where a claim about one prefix, one window or one repository stops
being about the subject as a whole. Most wrong conclusions of this kind are not
false; they are true of something smaller than the sentence suggests.

`rests_on` is checked mechanically: every id must exist. That is a weak check —
citing an event does not mean the event supports the claim — and it is worth
having anyway, because the failure it catches is the common one: a sentence that
sounds like it came from the evidence and did not.

## Negative findings are required output

**A report with nothing in the `badly` direction is a failed run, not a clean
subject.** Stage 6 enforces this and it is not a heuristic about how projects
usually are.

The family's own reporting position is that a tool publishes defects and never
assurances — that a pass says something about the checks that ran, never about
the artifact, and that a false sense of security is much harder to withdraw than
a wrong finding. A history report is a stronger version of the same hazard: it is
narrative, it is about a whole project rather than a file, and *"this evolved
well"* is exactly the kind of sentence that gets quoted later with the evidence
left behind.

If a run genuinely produces nothing negative, the honest outputs are that the
questions were wrong, or the detectors did not look where the problems are — both
of which are findings about **this tool**, and both belong in the report in place
of the missing section.

## What was dropped, and why

Every candidate event is either cited in the report or carries a reason for being
dropped, and the reasons are committed alongside the evidence.

This is the counter to the quiet version of cherry-picking, which is not
selecting evidence for a conclusion but *discarding* what does not fit while the
conclusion is forming. A reader who suspects it can read the dropped list. A
writer who knows the dropped list will be read behaves differently, which is most
of the value.

It has a second use: a candidate dropped as noise is a report on the detector
that produced it, and the catalogue's rule that a detector whose candidates are
always dropped gets deleted rather than tuned is enforced from this file.

## When the subject is ours

A run whose subject is a tree this family owns is marked `self`, and three extra
rules apply:

1. **A self-assessment with no negative findings is void**, not merely flagged.
   The general rule above says such a run failed; here it does not even get to
   report that it failed, because the likeliest explanation is the writer.
2. **Its conclusions are never cited outward.** Not as evidence that the
   ecosystem's practices work, not in a vision document, not in a README. A
   family grading itself with its own instrument produces something useful to the
   family and worthless to anybody else, and the moment it is quoted outward it
   becomes advertising.
3. **The instrument is a subject too.** This directory, and the launcher that
   carries it, are inside the ecosystem being read. A report on the ecosystem
   that does not notice its own author is a report with a hole in exactly the
   place the reader is standing.

## Calibration: can it find what a person would find?

The one property of this tool that *is* measurable, and it should be measured
before the first real run rather than after.

1. Somebody who knows a subject writes down, **before seeing any candidate
   list**, what they would call its major events. Digest recorded.
2. The detectors run.
3. Two numbers come out: how many of the person's events appear among the
   candidates, and how many candidates the person did not list.

**The first number is the one that matters.** An event a knowledgeable person
names and the catalogue misses is a hole with a name attached, and it is the only
way to find one — the detectors cannot report what they do not look for.

The second number is not precision and must not be reported as an error rate. A
candidate the person did not list may be exactly the *derived, not declared*
finding the tool exists to produce; it may equally be noise. Which one it is is
judgement, and putting it in a ratio would hide that.

**What calibration cannot do is tell us whether an assessment is any good.**
There is no ground truth for *this project handled its growth badly*, and the
only test of that half is the stretch goal — somebody who knows the subject well
learning something they did not know, and saying so. That test cannot be
self-administered and is not close.

## What a report may not say

- **A verdict on a project that did not ask for one.** For a subject outside this
  family, a finding about the *method* stays here and a finding about *them* is
  theirs, carried by a person under the ordinary reporting discipline, and asked
  for first. The charter says why.
- **Anything about a person.** No names reach the report; nothing may be
  reconstructed around the gap, and *"the project"* is never a euphemism for
  whoever was committing that month.
- **What the subject should do next.** Every claim is about what happened. The
  tense is the boundary, and a recommendation is the point at which a
  retrospective becomes advice nobody asked for.
- **That the evidence is complete.** The largest thing this tool cannot see is
  everything that happened in issue trackers and discussions. A report says so,
  every time, in the same place.

## What would end this

If calibration shows that a knowledgeable person's list is reproduced faster by
reading the log than by running the pipeline, the tool is not worth having, and
the right response is the retirement note rather than a better detector. That is
a real possible outcome for a subject the size of this ecosystem's own trees,
where the whole history is small enough for one person to hold, and it is why the
charter names it as an ending.
