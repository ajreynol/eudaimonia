# Noesis

A **child project** of the Eudaimonia build framework about the line between
the part of a verified checker that is true of every calculus and the part a
signature contributes — and about whether what this repository knows about that
line is enough to state a semantics in Lean rather than compile one into Lean.

It is started under the placement [ynoia's `P3`][p3] recommended and at the
verdict that audit returned, which was **not yet**. Both halves of that matter,
so they are stated before anything else.

*The entry.* `noesis` is a name the ecosystem reserved for *the `.eos`
semantics written as Lean definitions over the SMT-LIB model logos already
carries, the compiler as a Lean metaprogram over those definitions, and a
theorem relating what it emits to what they say*. That thing does not exist, has
been written zero times, and is not what this directory is building.

*The audit.* `P3` asked where it would live if it were started, refused `ethos`
and `anoieu`, and said **eudaimonia, if it must start now** — because the
blocker the entry names *is* this repository's own blocker, because `euthyna`
is the child-project precedent, and because eudaimonia is one of the two trees
that would have to absorb the result. It also listed three prerequisites in
three trees, and exactly one of them is eudaimonia's:

> Answer open question 7 against more than one calculus — **eudaimonia** —
> `R14` is "the subject here is the shape, never the content", and it is the
> only tool that has run the compiler over more than one calculus.

**This directory is that prerequisite, worked from this side.** It is not the
Lean development, it does not wait for the fork with `iogos` to be decided, and
nothing it produces is spent if the fork goes the other way — which is the whole
reason it is worth doing while the verdict is still *not yet*.

## The charter

**The question.** Where does the invariant core stop and the signature begin —
and is the answer this repository has stateable as a definition rather than as
a template?

Eudaimonia is the only tree that has generated the same checker for more than
one calculus, so it is the only one that can see which of its own lines moved
and which did not. That measurement is a fact about the shape of a verified
checker. Open question 7 asks for it in general; `R14` says the shape is this
repository's subject; and a Lean definition of what a signature *means* cannot
be written until somebody says what a signature is allowed to change.

**The goals, in order.**

1. Keep the **readiness ledger**: the three prerequisites `P3` names, who owns
   each, what state each is in, and what would move it — kept current against
   the trees that own them rather than against this one's hopes.
   [docs/prerequisites.md](docs/prerequisites.md).
2. Answer open question 7 **from this tree's evidence**: the signature contract,
   the calculus profile and the invariant-core measurement are three partial
   answers this repository already has, written for other purposes and never
   read together as one. Read them together, say what they agree on, and name
   the part still unanswered. [docs/question-7.md](docs/question-7.md).
3. Write the **preservation statement** for the semantics stage in this
   repository's own terms: what a definition of a `.eos` file would have to say
   for a generated checker's theorem to be about the right formula. Zero code,
   and its most useful output is the statements that turn out not to be writable
   yet.
4. Keep both current against a **second calculus**. A line drawn from CPC alone
   is a description of CPC. `tools/apodeixis` is where the second one comes
   from, and goal 2 is not answered until it has run.

**The stretch goal.** One fragment of `.eos` defined in Lean over the SMT-LIB
model a generated checker already carries, beside the statement relating it to
what `ethos-eoc` emits for the same fragment — not to replace the compiler, but
to find out whether the embedding is good enough to state a compiler theorem in.
That is the readiness probe, and nobody knows the answer.

**What is out of scope.**

- **Building noesis.** No Lean semantics of the language, no compiler as a
  metaprogram, no theorem relating them. The entry's verdict is *not yet* and
  this project does not overturn it; if it is overturned that is a person's
  decision, taken elsewhere, on evidence some of which may come from here.
- **Deciding the fork with `iogos`.** Where the authoritative semantics lives —
  inside a prover or outside every prover — is the most consequential open
  question the entry sits under, and nothing here is evidence about it. Work
  that is useful whichever way the fork goes is the only work this project does.
- **Taking the name.** `noesis` is reserved in [anoieu's register][names] and
  reserved is not taken. A register entry says where a name lives and is edited
  by a person, in somebody else's tree; this directory does not make that edit
  and does not claim to have made it. See *The name* below.
- **The other two prerequisites.** Validating the Eunoia embedding against
  ethos's `src/` is `R10`'s and is being worked from that side; an account of
  `.eos` that does not depend on the compiler is sapheneia's if its charter is
  ever extended, which is its owner's decision and not this project's to ask for.
- **Replacing anything.** `ethos-eoc` keeps `R12` and `R13`. See below.
- **Reporting defects.** If reading this repository's own proof turns up
  something wrong in it, that is a line in `TODO.md` or `docs/limitations.md`
  put there by a person, not an output of this directory.

## The name

*Noesis* (Greek **νόησις**, from νοεῖν "to perceive, to understand", from νοῦς
"mind") is Aristotle's word for the act by which the mind grasps a first
principle directly — the knowing that demonstration proceeds *from* and cannot
itself supply. It was reserved for this entry because the proposal is that the
semantics be something a reader **understands** by reading a definition, rather
than something a program produces and nobody reads: today the answer to *what
does this signature's semantics say* is obtained by running the compiler.

The etymology is the ecosystem's and not this project's — the name was coined
in [`why-eunoia.md`][why] before there was anything to attach it to, and the
register carries it under *reserved, and free to take*. **This directory has not
taken it.** A name is claimed when a person adds a line to the register saying
where it lives, that file is in anoieu's tree, and nothing here edits it. What
is owed, if this is to keep the name, is one line there — and a reader who finds
`noesis` reserved rather than started should read that as the register being
correct, not stale.

If the entry is eventually built somewhere else, this directory keeps the
question and loses the name, and that is the right outcome rather than a loss.

## An island

Nothing in Eudaimonia links here, imports from here, or runs anything here.
This directory is not on any build path, not in any CI job, not in any generated
document, and nothing anywhere breaks if it is deleted — deleting it is the
test. It reads whatever it likes: this repository's templates and proofs, a
Logos checkout, the compiler's own tree, the manuals. It writes only inside
itself.

**It has no responsibilities.** Nothing depends on it, it owes nobody an
artifact, and it has no correspondence channel — a child project is addressed
through the repository that carries it. It answers no questions on eudaimonia's
behalf and its conclusions are not eudaimonia's positions.

Its sibling [`tools/apodeixis`](../apodeixis/README.md) is the other island, and
the two are islands from each other as well: goal 2 wants the second calculus
that project produces, and if that project is retired tomorrow this one loses a
data point and nothing else. Neither imports from the other.

## It is additive, never authoritative

**What a `.eos` file means is `ethos-eoc`'s answer, and stays `ethos-eoc`'s
answer.** The compiler and the semantics sets it ships hold that role; a second
reading written here governs nothing, and a reader who found the two disagreeing
should read the compiler as correct and the disagreement as this project's
finding to explain.

That is not a claim the compiler is presumed right. The point of a second
description is that two independent readings of the same artifact disagree
exactly where the artifact is unclear, and those places are the deliverable. But
a disagreement resolved by *asserting* this side would be this project
overstepping, and a disagreement resolved every time in the compiler's favour
would mean this had stopped being a second reading and become a paraphrase.
Both failures are worth watching for.

## What it inherits, and from where

Every claim this project starts from was established somewhere else, and the
pointer is the point — a reader has to be able to tell what was measured from
what was reasoned.

| inherited | from | what it establishes |
| --- | --- | --- |
| the core proof depends on the signature through exactly **two** operators, `and` and `imp` — it was four | [`TODO.md`](../../TODO.md), *Extract the invariant core* | the sharpest existing measurement of where the line falls, over one calculus |
| the **signature contract**: `and`, `and` sent to `SmtTerm.and`, the Bool literals, and the conditional nil | [`README.md`](../../README.md) | the same line stated as a requirement rather than a measurement, and the two were written independently |
| the **calculus profile**, and which of its questions are *derived* rather than *declared* | [`README.md`](../../README.md), [`docs/generated-checker.md`](../../docs/generated-checker.md) | which facts about a calculus the compiled output can settle, which is a lower bound on what a definition would have to fix |
| a second calculus exposed three bugs CPC could not | [`TODO.md`](../../TODO.md), §4f | that one calculus is not enough evidence about the shape — the argument for goal 4 |
| the readiness argument from the compiler's side, and its ordered preparation list | ethos, [`docs/noesis-readiness.md`][ready] | items 1 and 5 there are goals 3 and the stretch here, asked from this end |
| the placement, the verdict and the three prerequisites | ynoia, [`proposals.md`][p3] | why this directory exists and what it is not |

The readiness document is the one to treat carefully: it was drafted from the
tree whose compiler noesis would replace, it says so about itself, and the part
of it that is checkable by running something is its §2 measurement rather than
its argument.

## How it ends

Three endings, and a person picks: it **graduates** into its own repository —
which for this entry means the Lean definitions became something logos and
eudaimonia would fetch rather than read, and the register entry changes to say
so; it is **folded** into the parent — the answer to open question 7 becomes
part of what the template documents about itself, and the rest is dropped; or it
is **retired in place**, with a line here saying what was learned and why it
stopped.

Going quiet is not one of them. If this directory has not moved and nobody is
standing behind it, the honest form of that is a retirement note.

*Started 2026-09-01 by the maintainer, in an explicit instruction. Nothing here
has been delivered yet, so nothing above is an exception the policy would ask
this project to name, and the island is stated as fact rather than as
intention.*

[p3]: https://github.com/ajreynol/anoieu/blob/main/tools/ynoia/proposals.md
[names]: https://github.com/ajreynol/anoieu/blob/main/tools/ynoia/names.md
[why]: https://github.com/ajreynol/anoieu/blob/main/tools/ynoia/why-eunoia.md
[ready]: https://github.com/cvc5/ethos/blob/main/docs/noesis-readiness.md
