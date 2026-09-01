# Open question 7, from this side

> **Where is the line between the invariant core and what a signature
> contributes?** eudaimonia's blocker and arrangement **B**'s design question
> are the same question, and euthyna cannot advise logos on modularizing
> without answering it as well. Whoever answers it answers all three.
>
> — ynoia, [`why-eunoia.md`][why], open question 7

**Goal 1.** This page reads what this repository already knows about that line,
in one place, and then says which part of the question that leaves open.

Its method is unglamorous and is the reason it is worth doing here: three
answers already exist in this tree, written at different times, for different
readers, by people who were not answering this question. Nobody has laid them
against each other. Where independent answers converge, the line is real; where
they diverge, the divergence is the finding.

## The three answers this repository already has

### 1. The measurement

`TODO.md` reports what the core checker proof — around 4,900 lines across
`Checker.lean`, `CheckerCore.lean`, `CheckerState.lean`, `Invariants/` and
`Common.lean` — actually depends on. The number has come down twice, and the
current figure, corrected by the Logos maintainer against the tree itself and
re-verified here, is **one operator: `and`**. `not` and `=` went first; `imp`
went last and by accident, as five lemmas nothing used.

Two refinements matter more than the number:

- **`Proofs/Checker.lean` names no operator at all**, and in Logos it is
  byte-identical between a 591-rule package and a 5-rule one that differ in rule
  set, in signature *and* in which invariants their rules need. It is a proof
  about a stack machine that pushes assumptions and proven facts.
- The one remaining operator is **no longer on the path a proof takes through
  the checker** — only in the statement of what a run proves.

### 2. The contract

`README.md` states what a signature must provide, and arrives at the same place
from the other direction: *"the contract is about stating what a run
establishes, not about performing it, and it comes down to one operator"* — a
binary `and`, translated by the semantics to `SmtTerm.and`, plus the Bool
literals, which are language builtins and cost a signature nothing. The nil
attribute is required conditionally and is surface syntax rather than substance.

The convergence is the useful part. The measurement is an observation about
existing Lean code; the contract is a requirement written for a person bringing
a calculus; and they were not derived from each other.

### 3. The classification

`docs/generated-checker.md` splits a generated checker's files into **G**
(generated from the signature, overwritten), **F** (fixed, copied in complete)
and **H** (hand-written, preserved) — which is the same line drawn at file
granularity rather than at operator granularity, and it is the sharpest of the
three because it is not a summary: every file in a generated project has a
letter, and the letters are checkable by regenerating.

`TODO.md` proposes a fourth category, **L**, for files a project *inherits*
rather than writes, and says the distinction *"is the difference between a
scaffold and a framework"*. That sentence is open question 7 asked about this
repository rather than about the ecosystem.

## What the three agree on

**The soundness statement's dependence on a calculus is one operator wide, and
it is a dependence of the statement rather than of the machinery.** Everything
that *performs* checking — the stack, the command list, the dispatch, the
diagnostics — is calculus-agnostic, and this is measured rather than hoped:
regenerate for another calculus and those files do not move.

Stated the way the ecosystem's question wants it: *the invariant core is
everything except the meaning of the symbols, and the meaning of the symbols
enters at exactly two places* — the translation into SMT-LIB, which is
per-calculus by construction, and the single operator the conclusion is phrased
in.

If that survives a second calculus it is a real answer, and it is a better one
than anybody expected: the pessimistic prediction was that a verified checker is
saturated with its calculus.

## What it leaves open, which is the whole of the remaining question

The line above is drawn through the **proof of the core**. It says nothing about
the **obligations a calculus arrives owing**, and that is where the honest
version of the question lives.

The classification already names them. `Proofs/Invariants/Extra.lean` is marked
*"the calculus-specific seam"*; `Proofs/TranslationTypePreservation.lean` is
marked *"cannot be inherited"*; `Proofs/Rules/` is `G+H` — statement generated,
proof yours. These are not core files and they are not free either. So:

1. **Is the seam's *shape* invariant, or only its *name*?** The template offers
   a fixed set of slots pointed at `True` for a calculus that needs nothing
   there. A calculus needing something the slots cannot express would not show
   up as a harder proof; it would show up as the template being wrong about what
   an obligation is. Nothing has tested that, because nothing has brought a
   calculus the framework was not shaped around.
2. **Is the profile's derived/declared split a fact about calculi or about the
   compiler?** Several profile questions are *declared* — taken on trust —
   precisely because the machinery they name is emitted unconditionally, so a
   calculus with the feature and one without compile to the same thing. That is
   a statement that those features are on the invariant side **by construction
   rather than by argument**, and it is exactly the kind of line that a second
   calculus either vindicates or exposes.
3. **What does the translation have to be total over?** A checker's verdict is
   about the conjunction of its assumptions under SMT-LIB model semantics. A
   calculus whose objects are not SMT-LIB formulas — clauses, sequents, anything
   with its own notion of what a step concludes — has to be mapped in, and where
   that mapping is stated is a placement question this page cannot answer from
   one calculus.

## Why this cannot be finished here

**One calculus and its own cut-down variant is a family, not a sample.** CPC,
`CpcMini` and `examples/hello` all agree about the line, and they agree partly
because each was written by somebody who knew where the line was. This
repository has already recorded what happens when that stops being true: the
first calculus that was not CPC exposed three bugs CPC could not, all of them
invisible while CPC was the only test, and none of them the kind of bug anybody
predicted.

So goal 1 is not answered until a calculus nobody designed this framework around
has been through it. That is [`tools/apodeixis`](../../apodeixis/README.md), and
the three questions above are what it is being watched for — not whether it
succeeds, which is not the interesting outcome either way.

## The other tree draws a different line and calls it the same question

The compiler's tree claims open question 7 *"can now be read off this tree rather
than argued"*, and it means something real: after its configuration
restructuring, 1,215 lines say what Eunoia is, 336 say what a target is, and
3,185 lines of configuration say what a theory does. That is a boundary somebody
can point at, and it was not available before.

**It is not this page's boundary.** That line runs through the *compiler's
inputs* — language, target, theory. This one runs through the *checker's proof* —
what a soundness statement depends on. Both are legitimate readings of the same
one-sentence question, and whether they are the same line is itself unanswered:
there is no reason in advance why the split that makes a compiler modular should
coincide with the split that makes a proof reusable, and finding out they differ
would be a more interesting result than finding out they agree.

Naming both is the useful move. A project that quoted one of them as *the*
answer to open question 7 would be making the question look settled from
whichever tree it happened to be standing in.

## Why the compiler needs this before it needs anything else

A Lean definition of `.eos` is a definition of **what the symbols mean**, and the
sections above say the meaning of the symbols is precisely what the invariant
core does not contain. So the boundary drawn here is, exactly, the interface such
a definition sits behind — and for a compiler that emits the development, it is
something sharper than an interface: **it is the specification of what the
emitter is allowed to vary.**

Concretely, the preservation statement the charter's goal 4 asks for is: *if the
semantics sends the signature's symbols to these SMT-LIB terms, then a run that
reports `correct` has established that the conjunction of the proof's assumptions
is unsatisfiable under that reading.* Every phrase is fixed by the three answers
above except *these SMT-LIB terms*, which is what the definitions supply. The
statement is therefore free once the line is drawn and impossible before.

The failure mode this guards against is specific and would be invisible for a
long time. A compiler written while the line is only known from CPC will emit
what CPC needs, its theorem will be true, and the first calculus that contributes
something CPC did not will find the emitter silently unable to express it — with
a proof attached saying everything is fine. That is why goal 1 is goal 1 and not
an appendix.

## One observation about the source material

`TODO.md`'s *Extract the invariant core* item still reads *"exactly **two**
operators, `and` and `imp`"*, and its *Corrections from the Logos maintainer*
subsection, further down the same file, supersedes that with *"it is now `and`
alone"*. Both are correct as written and dated; a reader who stops at the first
gets a number that is one too high. This page uses the corrected figure.

That is an observation about the parent's own file, not a finding against
anybody, and it leaves this island the way everything else does: a person
decides whether it is worth a line in `TODO.md`.

[why]: https://github.com/ajreynol/anoieu/blob/main/tools/ynoia/why-eunoia.md
