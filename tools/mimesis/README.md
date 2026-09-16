# Mimesis

**Where to learn how a Eunoia signature is written, and how one gets into
Logos.** A child project of the Eudaimonia build framework, in two strands:

- **Case studies** read an episode that already happened — a signature somebody
  wrote, and whatever answered back: a stated proof obligation, a generated
  checker, a producer's own checker, a test suite. Each says what was decided,
  what was got wrong, and what caught it. The supply is real history: 75 commits
  touched CPC's signature on cvc5's trunk in the twelve months to 2026-09-16.
- **Tutorials** build a signature from a calculus's rule descriptions, one
  decision at a time, with every step run and the files kept so a reader can run
  them too.

| document | strand | what it is |
| --- | --- | --- |
| [`docs/case-study.md`](docs/case-study.md) | case study | **BV abstraction.** One CPC rule from a paper's lemma schemes into a Eunoia signature, into Logos as 11,168 lines of Lean — where stating the obligation exposed it as unsound — then fixed, proved, and simplified, with the proof shrinking twenty lines for every line the signature lost |
| [`docs/tutorial.md`](docs/tutorial.md) | tutorial | **Propositional resolution.** The calculus written from three lines of prose, with the three mistakes a first draft makes and the errors they produce |
| [`examples/resolution/`](examples/resolution/README.md) | tutorial | the tutorial's worked files, and a `check.sh` that re-runs its proof tests |

## What each strand owes

**A case study names its sources precisely enough to be re-checked, and is
written so that it survives the branches it was read from.** It reads public
history and reports no defects: anything still wrong in a live tree is a finding
and leaves through the parent in a person's hands, never through an entry here.

**A tutorial ships what works.** Every claim in one is something that was run,
and anything that was not run says so — in the tutorial and in the file itself.

**Both are additive.** The Eunoia [manual][manual] is the authority on the
language, the framework's [front page](../../README.md) on what a signature must
provide, and the compiler's output on what a signature means. Where an entry
here disagrees with any of them, they are right and the disagreement is this
project's to explain.

## The ledger

What the entries accumulate into: each difficulty recorded with whose it is to
fix — **the compiler's**, **the framework's**, **the documentation's**, or
**nobody's**, a judgement about the calculus that no tool can make. Counts by
category across entries are the point; one entry is a story.

Nothing in a ledger entry is a soundness claim. Passing proof tests does not
make a calculus sound — it shows that a signature accepts and rejects the proofs
it was shown, and a freshly generated checker's soundness proofs are unfinished
by construction, as the parent's
[limitations](../../docs/limitations.md#nothing-is-proven-yet) say.

**No paper.** A reading of somebody's history is not a result. That changes if
there are enough entries for counts to mean something, at least one of them
written first-hand.

## The name

*Mimesis* (Greek **μίμησις**, "imitation") is Aristotle's word for learning by
representing — a craft picked up from worked instances before it can be stated
as a rule. Both strands are that word taken literally: the doing of somebody who
has already done it, set down in enough detail to be imitated and argued with.
If the fastest way to a new signature turns out to be opening CPC and editing
it, the name is wrong and so is the project.

The name is reserved in [ynoia's register][names], in kanon's tree, and nothing
here edits it; a reader who finds it listed as *not started* should read that as
an edit that is owed.

## An island

It reads the parent, its neighbours and the compiler's tree, and writes only
inside `tools/mimesis/`. Nothing in Eudaimonia links here, imports from here or
runs anything here — deleting this directory changes nothing else. Files a
framework run would produce are written outside the repository, never here.

## Status

**Started 2026-09-16 by the maintainer, in an explicit instruction**, and
reoriented the same day and the same way: it had led with writing one calculus
ourselves, and the main goal now is accumulating case studies, with tutorials as
the second strand. Two documents exist. A person decides whether it **graduates**
into its own repository, is **folded** into the parent, or is **retired in
place** with a note saying what was learned; going quiet is not one of those.

[names]: https://github.com/ajreynol/kanon/blob/5545d5cd20578ec890100810aa59165bb782c6e1/tools/ynoia/names.md#reserved-for-an-intended-launch
[manual]: https://github.com/cvc5/ethos/blob/main/user_manual.md
