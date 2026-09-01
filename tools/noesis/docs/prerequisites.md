# What this rests on

The three things [`P3`][p3] named as prerequisites for the noesis entry, what
state each is in, and — the part that changed when a person set a concrete goal —
which of them this project **waits on** and which it merely **wants**.

**They were asked as a different question.** The audit's three rows were about
whether the ecosystem should spend a repository and a shared name on this entry;
under that question, three unowned prerequisites are a reason to say *not yet*.
Under the question a started child project asks — *what is this work resting on,
and what would make it wrong* — the same three rows are a trusted-base ledger,
and one of them is now much sharper than the other two.

**Nothing on this page is an assignment.** Each row names a tree that owns a
question by role, not a person who agreed to answer it. A row that has not moved
is a fact about the ecosystem, not a complaint about anybody, and this project
proceeds around all three.

## The state, as of 2026-09-01

| # | what | tree | this project |
| --- | --- | --- | --- |
| 1 | validate the Eunoia embedding against the implementation — the 1,215 lines that are a semantics of Eunoia nothing has compared with the C++ | **ethos**, by role: the implementation every other reading is compared to | **rests on it, and does not wait for it.** Item 1 of the trusted base |
| 2 | answer open question 7 against more than one calculus | **eudaimonia**, by role: the shape and never the content | **is this**, and it is goal 1 |
| 3 | an account of `.eos` that does not depend on the compiler | **sapheneia**, if its charter is ever extended | **wants it, and is partly it.** See below |

And the thing that is not a prerequisite but was the audit's reason for saying a
charter could not yet be written: the undecided fork with `iogos`. That is
answered in [the charter](../README.md) rather than here — the short form is that
the fork is about which artifact is *authoritative*, and this project refuses
authority, so it does not turn on the answer.

## Row 1 — the semantics, unvalidated. The one that matters

This is the row with real consequences for a project that intends to prove
things, and it should be read before anything on this page's optimistic side.

Eunoia is written down twice in the compiler's tree: as C++, and as 1,215 lines
of Eunoia that every downstream artifact is already generated against. **The two
have never been compared.** So the entry's blocker was never *write a semantics*
— it is *validate the one that exists*, which is cheaper and is somebody else's.

What it means here is exact and worth stating flatly: **every theorem this
project proves is a theorem about a reading of Eunoia that nobody has checked.**
A proved pass is proved against definitions that may not describe the language
the checker actually implements. That does not make the work worthless — a
compiler correct against a stated semantics is strictly better than one correct
against nothing, and the statement is the thing that makes the gap visible at all
— but it does mean *verified* is a claim with a named hole in it, and the hole is
the first line of the trusted base in [passes.md](passes.md).

The compiler's tree has moved this further than the entry assumed. A relation
that would validate the embedding runs today with no new tooling, and has been
measured once: over that tree's own corpus, 68 signatures agree, none disagree,
and nine cannot be processed at all. Two qualifications, both that document's own
rather than this page's objections:

- the measurement was made **by the tree whose compiler this would be a second
  implementation of**, and it says so about itself;
- **a differential is not a validation.** Two readings agreeing on a corpus is
  evidence about that corpus. The nine refusals are where the interesting part of
  the answer is, and four of them are one construct.

*What would move it:* that differential run as a gate rather than by hand, over
the whole corpus, with refusals reported as a coverage number. It is item 2 of
that tree's own ordered list and is entirely theirs.

## Row 2 — the line, which is now goal 1

No longer a prerequisite in the sense of *something that must happen elsewhere
first*: it is this project's own first goal, because what a compiler is allowed
to vary is exactly what a signature contributes, and a compiler written before
the line is drawn hardcodes CPC's answer.

The argument and the three answers this repository already holds are in
[question-7.md](question-7.md). The part that is not yet done is the second
calculus, which is [`tools/apodeixis`](../../apodeixis/README.md), and until it
has run, anything said about the line is a description of CPC.

## Row 3 — an account of `.eos` that is not a compiler

`.eos` has exactly one description today: the program that reads it. That is the
situation Eunoia itself was in one language over, and sapheneia excluded `.eos`
on purpose, to avoid doubling its scope before its first goal lands. A charter is
what a person agreed to, so extending it is that person's decision and this page
does not ask for it.

The relationship to goal 4 is worth being careful about, because it is easy to
overclaim in both directions. **This project will produce Lean definitions of
`.eos`, which is a second description, and that does not discharge row 3.** A
definition written to make a compiler's theorem stateable is shaped by that
purpose: it will cover what the Lean backend needs, in the form the theorem
wants, and it will be a poor account of the language for anybody who wants to
know what `.eos` *is*. Those are different artifacts with different audiences,
and the honest claim is that one is evidence for the other and not a substitute.

*What would move it:* its owner deciding, after their goal 1, that the second
language is worth the scope. Nothing here waits on that.

## What this page is not

- **Not a schedule.** Nothing above is close, and the audit that named these rows
  said so.
- **Not a claim on anybody's time.** Rows 1 and 3 are named because a reader has
  to know what is missing, not because this project is waiting on them.
- **Not a channel.** Nothing here leaves the island by machine. If something on
  this page is worth saying to the tree that owns a row, a person carries it
  through this repository's ordinary reporting discipline, with an id and a
  state, exactly like any other finding.

[p3]: https://github.com/ajreynol/anoieu/blob/main/tools/ynoia/proposals.md
