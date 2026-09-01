# Noesis

A **child project** of the Eudaimonia build framework whose goal is a concrete
one: **a verified Eunoia compiler, written in Lean.**

Today the answer to *what does this signature's semantics say* is obtained by
running a program — 5,430 lines of C++ and 2,026 of Python — and reading what
comes out. Nothing states what that program is supposed to preserve, so nothing
can be wrong about it. The proposal is that the meaning of a signature be a
**definition somebody reads**, that the compiler be a **Lean program over those
definitions**, and that the relation between them be a **theorem** rather than a
convention.

That is the `noesis` entry as the ecosystem reserved it. What this charter adds
is that it is being built, and what it is being built *as*.

## The charter

**The question.** Can the meaning of a Eunoia signature be a definition rather
than a program's output — and can the program that turns one into a Lean
development be verified against that definition?

**The artifact.** A compiler, in Lean: input a signature and its semantics as
abstract syntax, output the Lean development a generated checker is built from,
and beside every pass a claim about that pass at the strongest of three
strengths it can carry — **proved**, **validated per run**, or **checked**. The
ledger of which pass holds which, and why, is as much the deliverable as the
code: a compiler that is honest about the parts it cannot prove is worth more
than one whose "verified" is a single word covering a mixture.

The compiler tree's own arithmetic places this. *"A verified Eunoia compiler"*
is three projects — verifying `ethos` (10,278 lines, CompCert scale), verifying
`ethos-eoc` (5,430 C++ plus 2,026 Python, CompCert scale), and making the output
self-certifying per run (an increment). **This is the second, taking the third as
its method wherever the second is out of reach**, and the pass-by-pass
decomposition that makes that possible is not this project's invention either.
[docs/passes.md](docs/passes.md) is where the borrowing is made explicit.

**The goals, in order.**

1. **Keep the line current.** What a compiler is allowed to vary *is* what a
   signature contributes, so a compiler written before that line is drawn will
   hardcode CPC's answer and nobody will notice until the second calculus.
   [docs/question-7.md](docs/question-7.md), and the second calculus it needs is
   [`tools/apodeixis`](../apodeixis/README.md).
2. **The pass ledger.** Every pass of the compiler, what noesis's counterpart is,
   which of the three strengths it can hold and what the argument for that is —
   before any of it is written. [docs/passes.md](docs/passes.md). No code, and
   nothing after it is well-posed without it.
3. **The probe: `linear_patterns`, in Lean, proved.** 176 lines, a crisp spec —
   the linearized program is extensionally equal to the original — and statable
   over the term embedding that already exists. It is first among the passes for
   one reason: it answers whether the embedding is good enough to state compiler
   theorems in *at all*, which nobody knows. A negative result here is a real
   result and reshapes everything below it.
4. **The semantics as definitions, and what each pass must preserve.** Enough of
   `.eos` defined in Lean over the SMT-LIB model a generated checker already
   carries to say what the backend is obliged to keep — one preservation
   statement per pass, written before the pass. Its most useful output is the
   statements that turn out not to be writable yet.
5. **The compiler, and its theorem.** The Lean backend over abstract syntax, one
   fragment end to end before any breadth, each pass at the strongest strength it
   can hold, and the aggregate reported as what it is rather than as what the
   word "verified" suggests.

**The stretch goal.** A checker in this repository built from noesis's output
instead of the compiler's, and the two compared. That is the point at which the
Lean definitions become something this repository would **fetch rather than
read** — which is exactly the threshold the audit named for this entry ceasing
to be a child project, so reaching it is also the instruction to leave.

**What is out of scope.**

- **The verification-condition backend.** `ethos-eoc` also emits the SMT-LIB and
  SyGuS verification conditions, and the entry's own account concedes noesis does
  not replace that. It stays where it is. The target here is the Lean
  development, and a run that needs the other backend calls the existing one.
- **Verifying `ethos`.** The proof checker itself is the first of the three
  projects above and is not this one. Nothing here says anything about it.
- **Concrete syntax.** The theorem is over abstract syntax; getting there from
  the text of a `.eo` file is a parser, and a parser stays in the trusted base —
  deliberately, and for the same reason a generated checker keeps one there.
  Closing that is somebody's later project and is not smuggled into this one's
  claims.
- **Replacing `ethos-eoc`.** What a `.eos` file means is that compiler's answer
  and stays that compiler's answer while this exists. See below — it is the
  section that keeps this project from having to win the fork.
- **Deciding the fork with `iogos`.** Where the *authoritative* semantics lives —
  inside a prover or outside every prover — is undecided, and building an
  artifact is not deciding it, because the fork is about authority and this
  project refuses the authority. The design constraint that keeps that honest is
  stated below and is a real constraint on the code.
- **Being a production tool.** Not fast, not ergonomic, no stability promise, no
  users. A compiler nobody has to depend on can be rewritten when its theorem
  turns out to want a different shape, and it will.
- **Validating the Eunoia embedding against the implementation.** That is the
  compiler tree's, by role, and it is the one input here that this project cannot
  supply for itself. [docs/prerequisites.md](docs/prerequisites.md) says what
  turns on it.
- **Reporting defects, and taking the name.** Findings leave through this
  repository's ordinary discipline, carried by a person. The name is reserved in
  anoieu's register and the entry that would say it is taken is a person's edit
  in somebody else's tree; nothing here makes it.

## What "verified" is claiming

The word does real damage when it covers a mixture, so the three strengths are
fixed in advance and every pass gets exactly one:

| strength | what it means | what remains trusted |
| --- | --- | --- |
| **proved** | a theorem in Lean relates the pass's output to its input under the definitions | the definitions, and that they say what Eunoia means |
| **validated per run** | the pass emits evidence that *this* output means what *this* input meant, and the evidence is checked | the checker of the evidence, which is small and is itself Lean |
| **checked** | no theorem and no per-run evidence: a structural property is tested — a round trip, two backends agreeing | the pass, entirely. The test says when it is wrong, never that it is right |

A pass at **checked** is in the trusted base and the ledger says so in those
words. The aggregate claim a finished noesis could make is therefore never *the
compiler is correct*; it is *these passes are proved, these validate themselves
per run, and these are trusted, and here is the boundary between them* — which is
a claim somebody can act on, and the other kind is not.

**Translation validation is the method, not the fallback.** The reason it is
reachable at all is that a signature no longer compiles as a monolith: a block
goes in and a named set of blocks comes out, which is a lemma-sized obligation
with the aggregate as the induction. That observation is the compiler tree's and
is what makes the middle row above a plan rather than a hope.

## The fork, and why this does not decide it

`noesis` and `iogos` pull opposite ways: one would have the authoritative
semantics defined inside a prover, the other needs it outside every prover so
that a second prover can carry it as an independence check. The audit that placed
this project was explicit that a charter resting on that fork is a charter that
gets rewritten or abandoned.

This one does not rest on it, for a reason that is a constraint rather than an
assurance: **the fork is about which artifact is authoritative, and this project
refuses authority.** The compiler's answer remains the ecosystem's answer while
this exists. What gets built is a second reading, and a second reading is
compatible with either resolution — under noesis's it becomes the definition,
under `iogos`'s it becomes one of the two ports.

The constraint that keeps that true in the code: **the definitions are written to
be read as mathematics rather than as Lean.** Lean's automation may appear in
proofs and must not appear in statements; nothing a definition *means* may depend
on a tactic, a metaprogram, or an elaboration convenience. If a definition cannot
be read by somebody who does not use Lean, it has failed this constraint, and
that is a review standard rather than a mechanism — it will be broken
occasionally and the ledger is where the breaks are recorded.

## The name

*Noesis* (Greek **νόησις**, from νοεῖν "to perceive, to understand", from νοῦς
"mind") is Aristotle's word for the act by which the mind grasps a first
principle directly — the knowing that demonstration proceeds *from* and cannot
itself supply. It was reserved for this entry because the proposal is that the
semantics be something a reader **understands** by reading a definition, rather
than something a program produces and nobody reads.

The etymology is the ecosystem's rather than this project's: the name was coined
in [`why-eunoia.md`][why] before there was anything to attach it to, and the
register carries it under *reserved, and free to take*. **This directory has not
taken it.** A name is claimed when a person adds a line to the register saying
where it lives, that file is in anoieu's tree, and nothing here edits it. A
reader who finds `noesis` reserved rather than started should read that as an
edit that is owed, and the entry it is owed is *started, in eudaimonia*.

## Where this stands with the audit that placed it

[ynoia's `P3`][p3] audited this entry and returned **not yet** — the thing had
been written zero times, and two of its three prerequisites had owners who were
not it. On placement it said: not `ethos`, not `anoieu`, and **eudaimonia, if it
must start now** — because the blocker the entry names is this repository's own,
because `euthyna` is the child-project precedent, and because eudaimonia is one
of the two trees that would have to absorb the result. That placement is the one
being used.

**The verdict is not overturned here and this project does not claim it has
been.** What that audit governs is whether the ecosystem should spend a
repository and a shared name on something, which is a question about a claim on
other people's attention. Whether a person builds a thing in a directory is not
that question, and the page says as much: it approves nothing, it binds nobody,
and its own threshold sentence for this entry is *"welcome — build it for your
own reasons, nothing here waits on you"*. Nothing here waits on anybody, and
nothing about the entry's standing in the register changes because this directory
exists.

*The concrete goal above was set by the maintainer on 2026-09-01, in an explicit
instruction, which is the same decision the policy reserves for a person when a
project's scope changes as when one starts.*

## An island

Nothing in Eudaimonia links here, imports from here, or runs anything here. This
directory is not on any build path, not in any CI job, not in any generated
document, and nothing anywhere breaks if it is deleted — deleting it is the test.
It reads whatever it likes: this repository's templates and proofs, a Logos
checkout, the compiler's own tree, the manuals. It writes only inside itself.

**And it is expected to stop being one, which is worth saying now rather than
discovering later.** The stretch goal is a generated checker built from this
compiler's output — and on the day that works, this directory is on a build path
and the island is gone. That is the audit's own promotion threshold arriving, and
the honest response to it is a recorded exception naming what broke, followed by
somebody deciding whether this graduates. The failure mode to avoid is the
directory quietly becoming load-bearing while its README still says it is not.

**It has no responsibilities.** Nothing depends on it, it owes nobody an
artifact, and it has no correspondence channel — a child project is addressed
through the repository that carries it. It answers no questions on eudaimonia's
behalf and its conclusions are not eudaimonia's positions.

Its sibling [`tools/apodeixis`](../apodeixis/README.md) is the other island, and
the two are islands from each other as well: goal 1 wants the second calculus
that project produces, and if it is retired tomorrow this one loses a data point
and nothing else. Neither imports from the other.

## It is additive, never authoritative

**What a `.eos` file means is `ethos-eoc`'s answer, and stays `ethos-eoc`'s
answer.** A compiler written here governs nothing; a reader who found the two
disagreeing should read the existing one as correct and the disagreement as this
project's finding to explain.

That is not a claim the compiler is presumed right — the point of a second
implementation is that two independent readings disagree exactly where the
artifact is unclear, and those disagreements are the deliverable. But a
disagreement resolved by *asserting* this side would be this project
overstepping, and one resolved every time in the incumbent's favour would mean
this had stopped being a second reading and become a paraphrase. Both failures
are worth watching for, and a compiler makes the first one easy: an executable
disagreement feels like evidence in a way an argument does not.

## What it inherits, and from where

Every claim this project starts from was established somewhere else, and the
pointer is the point — a reader has to be able to tell what was measured from
what was reasoned.

| inherited | from | what it establishes |
| --- | --- | --- |
| the three projects *"a verified Eunoia compiler"* decomposes into, and their scales | ethos, [`docs/noesis-readiness.md`][ready] §5 | which one this is, and that the other two are not it |
| the pass table, with each pass classified provable, checkable per run, or checkable | ethos, [`docs/noesis-readiness.md`][ready] §5 | the ledger of goal 2, before this project wrote a line of it |
| `linear_patterns` as the readiness probe — *is the embedding good enough to state compiler theorems in?* | ethos, [`docs/noesis-readiness.md`][ready] §6 item 5 | goal 3, and that the question it answers is open |
| a semantics of Eunoia exists in that tree — 1,215 lines — and has never been compared with the C++ | ethos, [`docs/noesis-readiness.md`][ready] §1 | that the first task is validating a semantics rather than writing one |
| the core proof's dependence on the signature is **one operator**, `and`, and only in the statement | [`TODO.md`](../../TODO.md), and the corrections in it | the line goal 1 keeps, measured over one calculus |
| the signature contract, and the calculus profile's derived/declared split | [`README.md`](../../README.md), [`docs/generated-checker.md`](../../docs/generated-checker.md) | what the compiler's output is obliged to satisfy, stated independently of it |
| a second calculus exposed three bugs CPC could not | [`TODO.md`](../../TODO.md), §4f | that one calculus is not evidence about the shape |
| the placement, the verdict, the three prerequisites and the fork | ynoia, [`proposals.md`][p3] | why this directory is here and what it is not claiming |

The readiness document is the one to treat carefully: it was drafted from the
tree whose compiler this would be a second implementation of, it says so about
itself, and the part of it checkable by running something is its §2 measurement
rather than its argument.

## How it ends

Three endings, and a person picks: it **graduates** into its own repository —
which is what the stretch goal arriving means, and the register entry changes to
say so; it is **folded** into the parent — the line goal 1 draws becomes part of
what the template documents about itself, and the compiler is dropped; or it is
**retired in place**, with a line here saying what was learned and why it
stopped. A negative result at goal 3 is the likeliest honest route to the third,
and it would be worth more than most positive results here.

Going quiet is not one of them. If this directory has not moved and nobody is
standing behind it, the honest form of that is a retirement note.

*Started 2026-09-01 by the maintainer, in an explicit instruction. Nothing here
has been delivered yet, so nothing above is an exception the policy would ask
this project to name, and the island is stated as fact rather than as
intention.*

[p3]: https://github.com/ajreynol/anoieu/blob/main/tools/ynoia/proposals.md
[why]: https://github.com/ajreynol/anoieu/blob/main/tools/ynoia/why-eunoia.md
[ready]: https://github.com/cvc5/ethos/blob/main/docs/noesis-readiness.md
