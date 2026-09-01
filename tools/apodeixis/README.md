# Apodeixis

A **child project** of the Eudaimonia build framework that drives the framework
at a calculus nobody designed it around, and writes down everything that breaks.

The framework's claim is on its front page: *it generates a checker for whatever
calculus you name*. Every calculus it has generated one for so far was chosen or
written by somebody who already knew the shape it had to fit — CPC, which the
arrangement was derived from, a cut-down CPC, and two starter signatures written
here to exercise particular paths. That is a family rather than a sample, and a
claim tested against a family is untested.

So: take a real calculus that was specified elsewhere, by other people, for
another checker, with no knowledge of this framework and no interest in it, and
see where the framework stops. The target is **Alethe**.

Which is somebody else's work, and that fact governs this project rather than
decorating it.

## The gate

> **Status: not proceeding.** Nothing has been rendered, nothing has been run,
> and nothing will be until the Alethe maintainers have been asked and have
> agreed. **This project may never start, and that is an acceptable outcome** —
> it is written down here as one of the endings rather than as a risk.

Two commitments, and the first holds whatever happens with the second.

**1. Unpublished work on Alethe is its authors', and this project does not touch
it.** Not drafts, not preprints shared in confidence, not unreleased rule sets,
not work in progress in anybody's branch, not what somebody said at a workshop.
Unpublished research is the thing its authors have the sole right to develop and
to publish first, and a stress test that fed on it would be taking the most
valuable thing they have in exchange for nothing. This holds even if permission
under (2) is given and even if the material is handed over: material shared in
confidence stays theirs, is not reproduced here, is not committed, and nothing
derived from it goes anywhere without their explicit say. **The working sources
are the published specification and other published material, in the form their
authors published it.**

**2. This proceeds only in collaboration with the Alethe maintainers, with their
permission, or not at all.** Permission is asked for by a person, before any of
goals 2 to 4 begins, and what is asked for is collaboration rather than
clearance: that they know what is being done with their calculus, that they see
anything written here that describes Alethe before it goes anywhere, that they
can correct a rendering that misreads their work, and that their names and their
project's name are attached to nothing they have not agreed to. **Permission is
revocable without reason.** If it is withdrawn, this retires, and what was
written under it stops being used.

### Why permission and not merely licence

The specification is public and reading it is nobody's to authorise. That is the
argument this project deliberately does not run on.

The asymmetry is the reason. This is a stress test of *eudaimonia*: it takes
Alethe as a load, gives the Alethe ecosystem nothing, explicitly disclaims
serving it, and produces — if it produces anything — a public record of a
framework straining against somebody else's calculus. A record like that is very
easy to misread as a judgement on the calculus. The people who would carry the
cost of that misreading are the people who wrote it, and they have no stake in
the question being asked and no say in how it is phrased. **A one-sided ask is
exactly the case where being within one's rights is not the standard that
matters**, and asking is cheap.

### What exists before the gate opens

The charter, the request, and [docs/hypotheses.md](docs/hypotheses.md) —
predictions about where the *framework* is expected to strain, written from the
published specification and from what is public about the format, and containing
no Alethe material. Nothing else: no rendering, no run, no finding, no summary.

If the maintainers ask that even this much be changed or removed, it is changed
or removed.

### Who asks, and how

A person, through this repository, in the open. Not this directory and not an
agent: a child project has no correspondence channel by design, precisely so that
speculative work cannot open a conversation somebody else then has to answer.
There is no fallback path here — if the ask is not made, the project does not
start.

**And if the answer is no, the answer is no.** Not a smaller version, not the
same work with the target unnamed, not a version that avoids the word Alethe. The
retirement note gets written and this directory records that the question went
unanswered for a good reason. A stress test is not worth much, and it is
certainly not worth more than the right of the people who did the work to decide
what is done with it.

### The gate is local; the reasoning should not be

Nothing in the ecosystem's shared policy produced any of the above. That policy
has an argued position on what may be *said* about somebody else's code and
nothing on what may be *taken* from it, and this project found the gap by walking
into it.

So the reasoning has been offered upward, as a proposal, in the parent's standing
channel to the ecosystem — [`docs/discussion.md`](../../docs/discussion.md), topic
`D1`. **This directory did not raise it and could not have:** a child project has
no correspondence channel, precisely so that speculative work cannot open a
conversation somebody else has to answer. A person carried it, through the
parent, which is the only route there is.

If the ecosystem settles on something stricter, this project adopts it. If it
settles on something weaker, or declines to settle at all, the gate above stands
anyway — a project may bind itself more tightly than its policy requires, and
this one does.

## The charter

**The question.** Does the framework generalize to a calculus it was not shaped
around — and, much more usefully, *where exactly does it stop*? The interesting
output is not a verdict but a boundary: the list of things that had to be bent,
what each bend cost, and which of them are the framework's to fix rather than
the calculus's to accept.

**The goals, in order.** Every one of them is behind [the gate](#the-gate) and
none begins before permission — which makes the list below a description of what
would be done rather than of what is being done.

1. Keep the **ledger of breaks** — everything the framework refused, mis-shaped,
   accepted while meaning something else, or made expensive out of proportion to
   what was being asked. Ordered by what it would cost to fix, and honest about
   the entries that are the target's fault rather than the framework's.
   [findings/README.md](findings/README.md).
2. Grow a **Eunoia rendering of an Alethe fragment** — signature and semantics —
   fragment by fragment, each addition chosen for what it stresses rather than
   for coverage. [signature/README.md](signature/README.md) is where it goes and
   what governs what goes in next.
3. **Run the generator over it** and record what came back: the profile's
   answers, any disagreement between what was declared and what the compiled
   output settles, and where the calculus-specific seam actually fell.
   [docs/method.md](docs/method.md).
4. Hand goal 3's result to open question 7. *"Where is the line between the
   invariant core and what a signature contributes"* is this repository's own
   blocker, and it is currently answered from one calculus and its relatives.
   This is the second one. [`tools/noesis`](../noesis/docs/question-7.md) is
   what wants it, and the three questions it is watching for are stated there
   rather than restated here.

**The stretch goal.** A generated checker that builds, and checks a hand-carried
proof of a real Alethe refutation end to end — accompanied by the ledger of
everything that had to be bent to get there, which is the part with the
information in it. Reaching this is not the measure of success and failing to
reach it is not failure: a stress test that stops early because the framework
stopped is a result, provided the stopping point is written down precisely.

**What is out of scope.**

- **Anything unpublished.** Stated above as a commitment rather than a
  preference, and it is the one boundary here that no permission relaxes: work
  its authors have not published is theirs to develop and to publish first.
- **Proceeding without the maintainers.** Also above. There is no version of this
  project that runs while the ask is outstanding, and none that runs after a no.
- **Serving the Alethe ecosystem.** This is stated at length below because it is
  the boundary most likely to be misread. Nothing here is an Alethe checker,
  nothing here is offered to Alethe's users or its tools, and no claim about
  Alethe is a deliverable of this project. That it gives them nothing is exactly
  why it has to ask them first.
- **The Alethe file format.** A generated checker accepts Ethos s-expression
  proofs, and the framework says so as a fixed point rather than a limitation.
  Reading `.alethe` files is a different front end and this project does not
  write one; the target is Alethe's **calculus**, not its concrete syntax.
- **Coverage.** Alethe's rule set is large and a rendering of all of it is a
  year of somebody's life for no information after the first tenth. Fragments
  are chosen for what they stress and the ledger records what was skipped and
  why — a skipped rule is data, an unlisted skipped rule is a hole.
- **Proving anything.** A generated checker ships compiling, not proven, and
  every rule arrives with `sorry`. Discharging obligations about Alethe's rules
  is not what this is for and would not answer the question it asks.
- **Fixing the framework.** A break is a ledger entry. Changes to the parent —
  to the templates, the generator, the contract or the profile — are a person's
  decision made outside this directory, on evidence some of which may come from
  here.
- **Judging Alethe, veriT or carcara.** Where a rendering is awkward, the honest
  first hypothesis is that the rendering is bad, the second that the framework is
  narrow, and only then that the calculus is. This project has no standing to
  reach the third and its ledger says so entry by entry.

## The name

*Apodeixis* (Greek **ἀπόδειξις**, from ἀποδεικνύναι "to show forth, to
demonstrate") is Aristotle's word in the *Posterior Analytics* for demonstration
proper: the deduction that produces knowledge rather than mere assent, proceeding
from principles that cannot themselves be demonstrated. It is the word for the
thing a proof calculus *is*, which makes it a reasonable name for a project whose
subject is a calculus somebody else specified — and it is the right one here for
a second reason available in English rather than Greek: a demonstration is also
what you subject a machine to when you want to find out what it does under load.

The etymology has a seam with its sibling worth admitting rather than polishing.
[`tools/noesis`](../noesis/README.md) is νόησις, the grasp of the principles a
demonstration starts from, and ἀπόδειξις is what proceeds from them; in
Aristotle the two are that pair exactly. That reads as a designed relationship
and it was not one — the names were reserved and chosen for separate reasons,
and the fit was noticed afterwards. It is recorded because a name whose story
improves after the fact is worth flagging as such.

**A collision, since resolved.** `Apodeixis` was this repository's placeholder
checker name in its usage examples — on the front page, in
[`docs/generated-checker.md`](../../docs/generated-checker.md) and in
`scripts/new-checker.sh` — which predated this directory and pointed at nothing.
It was a reader trap all the same: the front page appearing to name a child
project is exactly the arrangement a child project is supposed to avoid, and the
name of the trap is that the parent's own credibility gets lent to speculative
work by accident. The placeholder is now `Demo`, which the same documents
already used elsewhere and which nobody can mistake for a project. The parent
names nothing here.

**The register.** The ecosystem's names live in
[anoieu's register][names] and `apodeixis` is not in it: it is neither taken nor
reserved there. Adding a line to that file is a person's edit in somebody else's
tree, and this directory does not make it. Until somebody does, the name is used
here and claimed nowhere.

## Why Alethe, and what this project is not doing with it

**Alethe** is the proof format and calculus of veriT, produced by cvc5 as well
and checked independently by carcara. It is specified in a document its authors
maintain, which is the property that matters here: the target is written down by
people with no stake in this framework, so it cannot quietly bend to fit.

It is the right load for three reasons.

1. **It is genuinely foreign, and foreign in the interesting direction.** Its
   steps conclude *clauses* rather than formulas; it has a first-class notion of
   reasoning under a context; several of its rules are deliberate holes checked
   by an external procedure. Each of those meets one of the framework's stated
   fixed points head on, and none of them is exotic — this is what a mainstream
   proof format looks like when it was not designed around a Lean development.
2. **The distance is in the calculus, not in the file.** Eunoia's proof commands
   already follow Alethe's syntax closely — the manual says so — so the two are
   near where the framework claims not to care, and far where it claims to be
   general. That is the cleanest available separation of the two variables.
3. **Somebody has already named the direction, and this is not that.** The
   compiler's own tree lists *Alethe to Eunoia* among its future directions. If
   that work happens it will be done by people who want the result, to a standard
   this project is not held to. **This project is not it, does not prepare it,
   and must not be cited as progress on it.**

### Not serving the Alethe ecosystem

The load is Alethe. The subject is eudaimonia. Concretely:

- Nothing here is offered to, announced to, or built for the people who use
  Alethe, veriT, cvc5 or carcara. The reporting discipline that would apply if it
  were — publishing where the owner will read it, arguing where they can disagree,
  tracking until resolved — is a discipline this project deliberately does not
  enter, because it has nothing to report to them.
- No rendering here is a claim about what an Alethe rule means. A rendering is a
  probe. Where one is wrong about Alethe, that is a defect in the probe and
  costs the ledger an entry; it is not a finding against Alethe's specification
  and will not be published as one.
- No output here is evidence that Alethe proofs can be checked by anything. A
  generated checker ships unproven, the fragments are chosen adversarially rather
  than representatively, and a green run means the checks passed.
- If something here does turn out to be useful to that ecosystem, carrying it
  there is a person's decision and a different piece of work, done under their
  standards and not under a stress test's.

The reason for stating this so flatly is that the alternative reading is
attractive and would be borrowed credibility in both directions at once — the
framework's, for a claim about Alethe it has not earned, and Alethe's, for a
demonstration whose real subject is a template.

**None of that means no relationship.** *Not serving* is about what flows out —
no findings, no claims, no artifact anybody there is asked to care about. [The
gate](#the-gate) is about what flows in, and it is the opposite posture: the
maintainers are asked first, see anything written here that describes their work,
and can stop it. The two are consistent and the combination is the point — take
nothing without asking, and hand back nothing that would need answering.

## An island

Nothing in Eudaimonia links here, imports from here, or runs anything here. This
directory is not on any build path, not in any CI job, not in any generated
document, and nothing anywhere breaks if it is deleted — deleting it is the test.

It reads whatever it likes and it **runs** the parent's generator, which is
reading in the sense that matters: the generator is invoked exactly as a user
would invoke it, with `--out` pointing inside this directory, and it is never
modified, patched or special-cased to make a run succeed. A run that only works
against a modified parent has stopped measuring anything, so the ledger records
the modification instead of applying it. Everything written stays under
`tools/apodeixis/`; generated output lands in `work/`, which is untracked.

**It has no responsibilities.** Nothing depends on it, it owes nobody an
artifact, and it has no correspondence channel — a child project is addressed
through the repository that carries it.

[`tools/noesis`](../noesis/README.md) is the other island. Its goal 1 wants
what goal 3 here produces, and that is an intellectual debt in one direction and
nothing more: neither imports from the other, and if either is retired the other
loses a data point and keeps working.

## The ledger, and the fact that the subject is the parent

The repository policy is that nothing leaves an island by machine: a research
project accumulates candidate feedback inside its own directory, and a person
decides when and whether any of it is carried anywhere.

The usual shape of that is a finding about a third party's file, carried through
the reporting workflow with an id and a state. **This project's subject is the
repository that carries it**, so there is no third party and no workflow — the
destination of a confirmed break is `TODO.md` or
[`docs/limitations.md`](../../docs/limitations.md), one directory up, and the
step between the ledger and there is still a person. That makes the discipline
easier to skip rather than less necessary: a stress test whose findings edit its
own parent has stopped being a stress test and become a development branch, which
the policy says is served better by an actual branch.

## What it inherits, and from where

| inherited | from | what it establishes |
| --- | --- | --- |
| the six fixed points a generated checker has — Eunoia rules, Ethos proofs, SMT-LIB model semantics, an untyped deep embedding, one question, an unverified parser | [`README.md`](../../README.md), *The proof format is fixed* | the surface this project is loading, stated by the framework itself |
| the signature contract, and which part of it is conditional | [`README.md`](../../README.md) | what a rendering must satisfy before anything else is worth trying |
| the calculus profile, and which questions are *declared* rather than *derived* | [`docs/generated-checker.md`](../../docs/generated-checker.md) | the framework's own list of what it does not verify about a calculus — the first place to look for a break |
| a second calculus exposed three bugs CPC could not, all invisible while CPC was the only test | [`TODO.md`](../../TODO.md), §4f | the warrant: a *tame* second calculus already paid for itself, and this is the first untamed one |
| a generated checker ships compiling, not proven, and what its two stub files do | [`docs/limitations.md`](../../docs/limitations.md) | what a successful run does and does not mean |
| Eunoia's proof commands follow Alethe's syntax closely | ethos, [`user_manual.md`][manual] | the format/calculus separation this project depends on |

## How it ends

Three endings, and a person picks: it **graduates** into its own repository —
which would mean it had stopped being a stress test and become an Alethe project,
and would want a charter this one explicitly refuses; it is **folded** into the
parent — the fragments become another entry beside `examples/`, and the ledger
becomes rows in `TODO.md` and `docs/limitations.md`, which is the likeliest good
outcome; or it is **retired in place**, with a line here saying what the load
showed and why it stopped.

And a fourth, which is the likeliest of all and is an ending rather than a
failure: **retired unstarted**, because permission was not given or was never
asked for. A project that stops at its own gate has produced one thing — a
written account of why somebody else's work was not taken — and that is a
smaller result than a stress test and a better one than a stress test run
without asking.

Going quiet is not one of them, and neither is waiting indefinitely on an ask
nobody made.

*Started 2026-09-01 by the maintainer, in an explicit instruction, and gated the
same day. Nothing here has been delivered yet, so nothing above is an exception
the policy would ask this project to name, and the island is stated as fact
rather than as intention.*

[names]: https://github.com/ajreynol/anoieu/blob/main/tools/ynoia/names.md
[manual]: https://github.com/cvc5/ethos/blob/main/user_manual.md
