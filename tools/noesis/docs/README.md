# Documentation

Every document in this child project, and what each one is for. The charter,
[`../README.md`](../README.md), is the entry point and everything here assumes
it has been read — in particular that this directory is **not** the noesis entry
being built, but the one prerequisite of it that eudaimonia owns.

| document | what it is for |
| --- | --- |
| [`prerequisites.md`](prerequisites.md) | The readiness ledger: the three prerequisites the audit names, who owns each, what state it is in, and what would move it. Goal 1. |
| [`question-7.md`](question-7.md) | Open question 7 read from this tree's evidence: the three partial answers this repository already holds, what they agree on, and the part that one calculus cannot settle. Goal 2. |

Two documents the charter promises and that do not exist yet:

- **the preservation statement** (goal 3), which is the semantics stage stated
  precisely enough that its unwritable parts become visible. It is deliberately
  not started before [`question-7.md`](question-7.md) has a second calculus in
  it, because a statement written against one calculus would be a statement
  about that calculus;
- **the readiness probe** (the stretch goal), which is one fragment of `.eos`
  defined in Lean beside the statement relating it to what the compiler emits.
  Nothing about it is scheduled and it may never be written.

Neither absence is a gap to be filled on a schedule. A document that does not
exist is more honest than one written before its evidence.
