# The readiness ledger

The three things [`P3`][p3] says have to be true before the question *where does
noesis live* is worth asking again, what state each is in, and who would move
it. **Goal 1.**

It is kept here for one reason: three prerequisites in three trees is an
arrangement with no owner, and the named failure mode is that all three stay one
person's afternoon away forever. A ledger does not fix that. What it does is
make the claim *nothing has moved* checkable by somebody who does not already
believe it.

**Nothing on this page is an assignment.** Each row names a tree that owns the
question by role, not a person who agreed to answer it. A row that has not moved
is a fact about the ecosystem and not a complaint about anybody.

## The state, as of 2026-09-01

| # | what | tree | role | state |
| --- | --- | --- | --- | --- |
| 1 | validate the Eunoia embedding against the implementation — the desugaring and native-embedding signatures that are a semantics of Eunoia nothing has compared with the C++ | **ethos** | `R10`, the implementation every other reading of the language is compared to | **open, and moved.** A differential measurement exists and the tree that made it calls it the part of its own argument to attack first |
| 2 | answer open question 7 against more than one calculus | **eudaimonia** | `R14`, the shape and never the content | **open, and this directory.** One calculus has been measured; the second is [`tools/apodeixis`](../../apodeixis/README.md) and has not run |
| 3 | an account of `.eos` that does not depend on the compiler | **sapheneia**, if its charter is extended | `R20`, a second reading of a language whose only description is a manual for a program | **not started, and not askable yet.** `.eos` is deliberately excluded from that charter — *"folding it in would double the scope before the first goal is met"* |

And the thing that is not a prerequisite but gates the verdict:

| | what | state |
| --- | --- | --- |
| **the fork** | noesis and `iogos` pull opposite ways on whether the authoritative semantics lives inside a prover or outside every prover | **open**, and `P3`'s verdict changes to *welcome* when it is decided in noesis's favour, because until then a charter cannot be written |

## Row 1 — the embedding, against the implementation

The claim in the entry was that this is untouched. The compiler's own tree
argues otherwise in [`docs/noesis-readiness.md`][ready], and the argument has a
measurement in it rather than only prose: a desugaring differential run over
that tree's test corpus, reported as agreements, disagreements and refusals.

Two things keep this row open anyway, and both are the document's own
qualifications rather than this page's objections:

- the measurement was made **by the tree whose compiler noesis would replace**,
  and that document says so about itself in as many words;
- **a differential is not a validation.** Two readings agreeing on a corpus is
  evidence that they agree on that corpus. The prerequisite asks for the
  embedding to be laid against the implementation, and the refusals — the cases
  where one side declines to answer — are where the interesting part of the
  answer is.

*What would move it:* the differential run as a gate rather than by hand, over
the whole corpus, with the refusals reported as a coverage number. That is item
2 of that document's own ordered list and it is entirely that tree's to do.

## Row 2 — open question 7, against more than one calculus

This is the row this directory exists for, so it is the shortest here and the
longest in [question-7.md](question-7.md).

The short version: this repository already holds three partial answers, written
at different times for different purposes — a **measurement** (the core proof
depends on the signature through two operators), a **contract** (what a
signature must provide for the statement to mean anything), and a **profile**
(which facts about a calculus the compiled output can settle by itself). All
three were derived from one calculus and its cut-down variant, which is a family
rather than a sample.

*What would move it:* a calculus nobody designed the framework around. That is
`tools/apodeixis`, and until it has run, anything this page says about the line
is a description of CPC.

## Row 3 — an account of `.eos` that is not a compiler

The cheapest move available anywhere in this ecosystem, and it is not this
project's to make, and not eudaimonia's either.

`.eos` today has exactly one description: the program that reads it. That is the
same situation Eunoia itself was in before sapheneia, one language over — and
sapheneia excluded it on purpose, to avoid doubling its scope before its first
goal lands. A charter is what a person agreed to, so extending it is that
person's decision.

`P3`'s sharpest observation is that this, and not placement, is the live
question: *whether sapheneia's charter extends to `.eos` once its goal 1 lands*.
This page records that it is open and does not ask for it.

*What would move it:* its owner deciding, after their goal 1, that the second
language is worth the scope. Nothing here waits on it — goals 2 and 3 are about
what a semantics **must say** for a generated checker's theorem to hold, which
is a smaller question than what `.eos` means in general, and is answerable from
this tree's evidence alone.

## What this ledger is not

- **Not a schedule.** Neither of `P3`'s thresholds is close, and it says so.
- **Not a claim on anybody's time.** Rows 1 and 3 are named because a reader has
  to know what is missing, not because this project is waiting on them.
- **Not a channel.** Nothing on this page leaves the island by machine. If
  something here is worth saying to the tree that owns a row, a person carries
  it through this repository's ordinary reporting discipline, with an id and a
  state, exactly like any other finding.

[p3]: https://github.com/ajreynol/anoieu/blob/main/tools/ynoia/proposals.md
[ready]: https://github.com/cvc5/ethos/blob/main/docs/noesis-readiness.md
