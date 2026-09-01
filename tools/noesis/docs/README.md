# Documentation

Every document in this child project, and what each one is for. The charter,
[`../README.md`](../README.md), is the entry point and everything here assumes it
has been read — in particular what the goal is (a Eunoia compiler in Lean, with a
per-pass claim about what is proved, validated or merely checked) and what it
refuses (authority over what a `.eos` file means, which stays with the compiler
that exists).

| document | what it is for |
| --- | --- |
| [`question-7.md`](question-7.md) | Where the invariant core stops and a signature begins, read from this tree's evidence — the three partial answers this repository already holds, the different line the compiler's tree draws under the same name, and why a compiler written before this is settled will hardcode one calculus. Goal 1. |
| [`passes.md`](passes.md) | The pass ledger: every pass of the compiler, noesis's counterpart, the strength that counterpart can carry — proved, validated per run, or checked — and what remains in the trusted base when all of it works. Goal 2. |
| [`prerequisites.md`](prerequisites.md) | What this work rests on: the audit's three prerequisites re-read as a trusted-base ledger, which one this project waits on and which it merely wants. |

The documents the charter promises and that do not exist yet, each waiting on
something specific rather than on a schedule:

- **the probe** (goal 3) — `linear_patterns` in Lean with its theorem. The first
  thing here that is code, and the first that can fail informatively;
- **the preservation statements** (goal 4), one per pass, which are not writable
  before [`question-7.md`](question-7.md) has a second calculus in it, because a
  statement written against one calculus is a statement about that calculus;
- **the compiler and its theorem** (goal 5).

None of these absences is a gap to be filled on a schedule. A document written
before its evidence is worth less than the space where it would go.
