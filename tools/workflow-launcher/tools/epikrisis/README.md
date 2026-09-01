# Epikrisis

A **child project of a child project**: it sits inside
[the workflow launcher](../../README.md), which sits inside Eudaimonia. Its
subject is what the launcher's subject becomes later — the launcher is about the
first hour of a tool's life, and this is about reading the whole of one
backwards and saying what happened and how it went.

Its question is not *what does this code do*. It is: **what were the events, and
what has the way this thing evolved done well and badly?**

## Why it is here rather than one level up

The host asks a question it has no instrument for. Its findings register is
described on its own front page as *what is captured across the ecosystem, what
is retyped, and what is not in the record at all* — which is a question about the
gap between what a project's history **says** happened and what its tree
**shows** happened, answered by hand, once, by reading. That gap is the central
mechanism designed here.

Its stretch goal needs the same instrument. That goal is that somebody starts a
real repository through the launcher and the result is better than what they
would have typed, *measured by what the first week of that repository needed
corrected*. Nothing in this ecosystem can currently measure that, and the shape
of the missing thing is: read a repository's history, say what happened, say what
went badly. So this is the launcher's own unmeasured claim, given a tool.

**That is an intellectual debt in one direction and nothing else.** If this
directory is deleted the launcher's stretch goal is exactly as unmeasured as it
is today, which is to say: nothing breaks, because nothing was ever measured.

## The charter

**The question.** For a tool or an ecosystem: what were the major events in its
history, and what has its evolution done well and badly — with the first
answerable from the tree and the second answerable only with evidence from the
first?

**The goals, in order.**

1. **The evidence pipeline, and the boundary in the middle of it.** Everything
   up to and including the delta between the derived and declared records is a
   program: same input, same output, byte for byte. Everything after it is
   judgement and is never written into the same file.
   [docs/design.md](docs/design.md).
2. **The detector catalogue.** What counts as a candidate event, one entry per
   detector, each with its inputs, the evidence it emits, its threshold and
   **its known failure mode** — because a detector whose failure mode is
   unwritten will be trusted exactly where it is wrong.
   [docs/events.md](docs/events.md).
3. **Making an assessment falsifiable.** A report that says a project evolved
   well is worthless unless it could have said otherwise. The pre-registered
   questions, the required negative findings, the per-assessment falsifier, and
   the mechanical checks that enforce all three.
   [docs/judgement.md](docs/judgement.md).
4. **The two subjects**, below, run only once the three above are settled.

**The stretch goal.** That a report produced this way tells somebody who knows
the subject well something they did not already know — and that they say so.
That is the only test of this kind of tool that is worth anything, it cannot be
self-administered, and it is not close.

**What is out of scope.**

- **Judging people.** The unit of analysis is the artifact. Author names do not
  leave the first stage of the pipeline, and this is enforced by the schema
  rather than promised in prose — counts and anonymous ids may travel, names may
  not. A history-of-a-project report is one careless step from a performance
  review of the people in the log, and that step is not taken here.
- **Publishing about somebody else's project without asking.** Inherited, not
  invented: see below.
- **Generating the report.** The pipeline assembles evidence and checks a report
  against it. It does not write the narrative — the split is the host's own, and
  the reasons are in [docs/design.md](docs/design.md).
- **Prediction.** What a project should do next is not this. Every claim is about
  what happened, and the tense is the boundary.
- **Grading the ecosystem outward.** A run whose subject is a tree this family
  owns is marked as a self-assessment and is held to a stricter standard, and its
  conclusions are never cited outward as evidence that the family's work is good.
- **Being fast, being general, being a product.** No users, no stability, no
  promise that any of it survives the first real run.

## The role it is asking to hold

Added 2026-09-01 by the maintainer, in an explicit instruction, which is the
decision a scope change needs. **It is asked for and not claimed** — standing in
this ecosystem is conferred by somebody choosing to rely on a tool, never by the
tool saying so, and the register that would record it is in another tree.

**The audit of how this repository and its ecosystem have evolved:** what
happened, in what order, and what the way they changed did well and badly —
answered from the trees, with every claim resting on evidence a reader can
re-derive.

The precedent is one level up and one subject over: a sibling child project
holds the audit of what a proof development is *made of*, statically. This is
the same shape asked of a trajectory rather than an artifact.

**Not this role**, and the exclusions are the part that makes it safe to grant:

- **Deciding whether the evolution was good.** That is contestable, nobody has
  the authority to settle it, and it may never acquire a checker. What this
  produces is evidence and an argument answerable to it.
- **Grading any tree that has not agreed to be read.** The constraint above
  governs; a run on somebody else's subject is internal by default.
- **Anything about people.** Enforced by the schema, not by discipline.
- **Speaking for its parents.** Its conclusions are not eudaimonia's positions
  and never leave by machine.
- **Auditing itself into significance.** Every run whose subject includes this
  family is marked a self-assessment, a self-assessment with no negative
  findings is void, and its conclusions are never cited outward — not as
  evidence that these practices work, not in a vision document, not in a README.

**What it has actually done, so that the ask is not read as more than it is:**
one run, on a self-assessment, whose report retracted two of its eight questions
because the evidence did not support them, and which found four defects in the
tool that produced it. That is the whole record.

## The guardrail on the role: ambitious in functionality, unambitious in implementation

A granted role is a licence to grow, so the limit is attached to the request
rather than left for later. **The ambition goes into the questions and the
evidence. It does not go into the machinery.**

### Why this particular guardrail, and not a general plea for simplicity

Because there is a specific way an analysis tool goes wrong, and it does not
look like sprawl. **Implementation ambition in a tool like this takes the form
of absorbing judgement into code, where nobody can see it.** A cleverer detector
is one that has swallowed a decision somebody should have been able to argue
with. Four instances from this project's own first week:

- a matcher joined 105 claims to 123 events and produced **982 matches**. A
  smarter matcher would have produced a plausible number and hidden the fact
  that its window was wider than four of the five subjects' entire histories;
- a classifier filed a 750-line program as neither code nor prose. A cleverer
  classifier would have guessed right and been unfalsifiable;
- reading commit messages to decide what happened is refused outright, and is
  the single most tempting improvement available;
- a threshold edited after the events exist sets a flag on the run, because a
  threshold fitted to the answer is a judgement that has moved into a constant.

In every case the *dumber* implementation is the one whose errors were visible.
That is the whole argument.

### What is held small, counted

`epikrisis budget` counts it, exits non-zero over any limit, and the selftest
proves that check can fail:

| | limit | why |
| --- | --- | --- |
| the tool | **1,500 lines** | a reader must be able to check the whole of it in an hour. A tool whose findings can only be trusted is not evidence |
| prose about the tool | **no more than the tool** | the account may not outgrow the thing it accounts for. Counted over `docs/` and this file |
| third-party imports | **zero** | stdlib only: no install, no version skew, no supply chain |
| network imports | **zero** | the corpus is on disk. Nothing here fetches, and nothing here can be pointed at a service |
| subprocess call sites | **two**, both git wrappers | **the derivation path may run `git` and nothing else.** This is the limit that matters: it is what makes it structurally impossible for a model, a service or any other program to enter stages 1–4 |

**On breach, the first move is not to raise a limit.** It is to delete a
detector whose candidates are always dropped, or to move a judgement out of the
code and into the report where a reader can disagree with it. Raising a number
is a person's decision and is recorded as one.

### And the other half, which is not negotiable either

*Unambitious in implementation* must not become an excuse to ask a smaller
question. So, held large:

- **The question stays whole.** What happened, in what order, and what the way
  it changed did well and badly — over a whole ecosystem, across repositories,
  over its entire history. Nothing is narrowed to fit the machinery.
- **It may be pointed at any subject a person names**, at any scale, including
  ones far larger than anything it has run on.
- **It may say hard things**, including about the family that carries it, and
  the arrangement that a self-assessment is void without negative findings
  exists to make that likelier rather than safer.
- **Refusing to answer is allowed; shrinking the question is not.** *This tool
  cannot establish that* is a result. *This tool answers a smaller question
  instead* is a failure, and the second is what a budget tempts you toward.

The test, in one line: **if this became twice as useful, the code should not get
much bigger** — the detector catalogue would get better failure modes and the
questions would get sharper. If usefulness and size move together, judgement is
being absorbed and the guardrail has already failed.

## Receiving an epoch

Global announcements reach the ecosystem from whoever holds its chief executive
role — **currently anoieu**, and the role rather than the tree is what this is
keyed to, since the shared machinery may move. An **epoch announcement** marks
a boundary in the ecosystem's life, and that makes it directly this project's
business for a reason that is not deference:

**An epoch is the window this tool does not otherwise have.** Everything here is
reported per month, and a month is an arbitrary unit borrowed from the calendar
— it has no relationship to anything the ecosystem did. An epoch boundary is a
unit the subject itself declares, which turns *what happened between these two
points* from a choice this tool makes into a fact it reads. That is a better
instrument, and it is free.

**What this needs an announcement to carry**, stated now because it is far
cheaper to say before the first one exists than after:

| | why |
| --- | --- |
| a stable **identifier** | so two runs can name the same epoch and be compared |
| a **start**, as a commit or a date | so a window has an edge a program can find |
| **where it is recorded, as data** | the detectors here read status transitions out of an inventory file's own history. If an epoch is recorded that way it is readable on the day it lands; if it is recorded in prose, nothing here can see it and the audit reverts to months |
| what it **declares** | an epoch that names nothing changed is a date, and this tool would have nothing to report about it |

The last two are the ask carried upstream, and they are the same ask a topic
from this repository already makes about the ecosystem's other status
vocabularies. Raising it before the format exists is the cheap moment.

**Until an announcement arrives, nothing here waits on it.** A tool that cannot
work without a thing that does not exist yet has made itself somebody's
dependency, and this one is deliberately not that: it reports per month today,
and gains a better window when there is one.

## The two initial subjects

Chosen because they are as different as two histories can be while both being
readable, and a detector set that works on one and fails on the other has told us
which of the two it was actually written for.

| | **cvc5** | **the Eunoia ecosystem** |
| --- | --- | --- |
| shape | one repository, long, many hands | several repositories, young, few hands |
| derived record | rich — the thing the detectors were designed for | thin: too few commits for anything statistical |
| declared record | conventional — releases, notes | unusually dense: dated correspondence, decided proposals, a register of names, roadmaps with checkboxes, retirement notes |
| what it tests | whether the detectors find events at all in a real history | whether the delta between what a tree says about itself and what it shows is computable |
| what it constrains | somebody else's project. See below | our own. Self-assessment rules apply in full |

The ecosystem case needs machinery the single-repository case does not: events
that live in no repository's log — a repository being created, a name being
taken, a role moving, a child project retired. The design carries both and
[docs/design.md](docs/design.md) says where they diverge.

**Nothing has been run.** No corpus is staged, no detector is written, no events
are cached, and no report exists. What is here is the design.

## The constraint it inherits

cvc5 is somebody else's work, and a public account of what a project's evolution
did badly is the kind of thing its authors did not ask for and cannot answer.
That is not a new problem and this project does not get to solve it from scratch:
the position is the one the family has just had to work out — that published is
not the same as available, that unpublished work is its authors' alone, and that
the trigger for asking is **who carries the cost if the output is misread**
rather than whether the reading was permitted.

Concretely, and these bind before the first run:

- **Unpublished material is out**, absolutely: no private branches, no drafts, no
  anything shared in confidence. Public history in the form its authors published
  it, and nothing else.
- **A run on somebody else's subject is internal by default.** Nothing about
  cvc5 leaves this directory without going through the ordinary reporting
  discipline and, per the position above, without asking. There is no route by
  which an assessment of another project's evolution becomes a public artifact on
  this project's own initiative.
- **The report may not be a verdict on a project that did not ask for one.** A
  finding about *this method* — that a detector missed something, that a delta
  class was empty — is this project's to keep. A finding about *them* is theirs.

It is worth saying which way this cuts: the constraint is not a formality here.
The most interesting subject available is somebody else's, the analysis is cheap,
and the output would be publishable and would get read. Every part of that is the
reason to write the rule down before the first run rather than after it.

The general position is open with the ecosystem as topic `D1` in the parent's
correspondence, and this directory did not raise it and cannot: it is two levels
inside a repository, and everything it wants to say travels by a person, up
through the launcher, up through Eudaimonia, and out. Two hops rather than one is
a feature — speculative work should find correspondence expensive — and a risk,
because a finding can die in the chain and nobody would notice. Recorded here so
that if one does, it was predicted.

## The name

*Epikrisis* (Greek **ἐπίκρισις**, from ἐπικρίνειν "to judge upon, to determine")
is judgement passed over something already complete. Medicine took it and gave it
the exact shape this project wants: an *epicrisis* is the summary written at the
close of a case — the course of events set down in order, followed by an
assessment of how the case was handled. Two parts, the second resting on the
first, and the whole of it retrospective.

That is the argument for the name and it is the argument somebody should attack.
The obvious objection is that a project is not a patient, is not finished, and
has no attending physician to be judged — and the strongest form of it is that
the medical word carries an authority this tool has not got. The reply is that
the *structure* is what is borrowed, not the standing: events first, assessment
second, assessment answerable to events. If the name ever starts doing work the
tool cannot back, it is the wrong name.

It is deliberately not **historia** — the account of what happened — because a
name that needs no explanation is not following the ecosystem's convention, and
because the account is only half of this. It is deliberately distinct from
**euthyna**, the audit at end of term, which is taken and is a sibling one level
up: that one asks what an artifact is *made of*, statically. This one asks what a
trajectory *did*. Adjacent, and not the same question.

The register of names is anoieu's and `epikrisis` is not in it. Adding a line is
a person's edit in somebody else's tree; nothing here makes it, and until
somebody does, the name is used here and claimed nowhere.

## An island, two levels down

Nothing in the launcher links here, imports from here, or runs anything here, and
nothing in Eudaimonia does either. This directory is on no build path, in no CI
job, in no generated document, and deleting it changes nothing anywhere —
deleting it is the test, and it has to pass against **both** ancestors.

It reads whatever it likes: checkouts staged elsewhere on disk, this family's
own trees, published history. It writes only inside itself.

**The policy checker cannot see this level.** It enumerates child projects one
directory deep, so the charter rules it enforces — a stated boundary, an
explained name, an island or a recorded exception — are not enforced here. This
README is written to satisfy them anyway, and that is the whole of the guarantee:
if it drifts, no program will say so.

**The count is a measurement, and it is not flattering.** Eudaimonia now carries
four speculative directories and this is the fifth thing under `tools/`, against
one framework that actually ships. The ecosystem has a name for what that looks
like from outside — a tree becoming a speculation warehouse — and it was raised
as a reason to refuse a child project elsewhere, not as a compliment. Nothing
here disputes it. The honest response is that the count is visible, that each of
the five states an ending, and that the ending most of them should reach is
retirement rather than graduation.

## How it ends

Three endings and a person picks: it **graduates**, which for this would mean
somebody outside the family wanted to run it on a subject of their own; it is
**folded** into the launcher, meaning the delta machinery becomes how that
project's findings register is maintained and the rest is dropped; or it is
**retired in place**, with a line here saying what the design got wrong, which is
the ending to expect.

A fourth, specific to this one: **retired at the first real run**, because the
detectors found nothing a person reading the log would not have found faster.
That is a live possibility, it is what the calibration step in
[docs/judgement.md](docs/judgement.md) exists to detect early, and it would be a
result rather than a failure.

Going quiet is not one of them.

*Started 2026-09-01 by the maintainer, in an explicit instruction. Nothing has
been run and nothing has been cached, deliberately: the design is the
deliverable, and evidence gathered before the boundary in it is agreed would be
evidence nobody could check.*
