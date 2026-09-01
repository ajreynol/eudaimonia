# The pass ledger

Every pass the compiler has, what noesis's counterpart is, and which of the three
strengths that counterpart can carry. **Goal 2**, and nothing below goal 2 in the
charter is well-posed before this page is right.

It is written before any code deliberately. A pass ledger written afterwards
records what was achieved and calls it the plan; the value of this one is that
the strengths are committed to while being wrong about them is still cheap.

## What is borrowed, and from where

**The decomposition is not this project's.** The compiler's tree published the
pass table, the line counts and the classification — provable, checkable per run,
checkable — in [`docs/noesis-readiness.md`][ready] §5, as part of an argument
about what could be done *while the fork is undecided*. This page takes that
table as its starting point and adds one column: what a Lean reimplementation of
each pass would be, and what it could claim.

Two things that classification already settles, and that this project does not
get to relitigate:

- **Two thirds of the C++ is checkable rather than provable.** A Lean rewrite
  does not change that arithmetic. It changes *who is trusted* — a checked pass
  in Lean is still a trusted pass — and pretending otherwise is the single most
  available way for this project to oversell itself.
- **The semantic content is concentrated.** `desugar` is where the meaning is,
  and it is the pass whose correctness needs a validated semantics of Eunoia,
  which nobody has. Everything else is structure.

## Where this project sits

*"A verified Eunoia compiler"* is three projects, at very different scales:

| | what it verifies | scale |
| --- | --- | --- |
| verify `ethos` | 10,278 C++ | CompCert |
| **verify `ethos-eoc` — this project** | 5,430 C++ + 2,026 Python | CompCert, and blocked on a validated semantics |
| make the output self-certifying per run | one artifact per run | an increment |

The third is not a rival to the second here; it is the **method** the second uses
wherever a theorem is out of reach. That is available because the unit of
compilation is no longer the whole signature: a block goes in and a named set of
blocks comes out, which is a lemma-sized obligation with the aggregate as the
induction.

## The passes

Line counts are the existing implementation's, and they are a map of where the
weight sits rather than a prediction about the Lean one.

| pass | LOC | classified as | noesis's counterpart | strength it can hold |
| --- | --: | --- | --- | --- |
| `linear_patterns` | 176 | provable | a function on the term embedding | **proved** — goal 3, and the probe |
| `trim_defs` | 757 | checkable per run | reachability over the definition graph | **validated per run**, possibly proved |
| `defs_reader` | 612 | checkable | reading and writing the intermediate form | **checked** — round trip |
| `lean_meta` | part of 2,835 | checkable | the emitter for the Lean development | **checked** — see below |
| `smt_meta` | part of 2,835 | checkable | *none* — out of scope | — |
| `desugar` | 1,347 | the semantic content | the definitions themselves, or a proved transformation over them | **open**, and the fork below |

### `linear_patterns` — first, and the probe

Small, purely syntactic, and its specification is one sentence: the linearized
program is extensionally equal to the original. It is first not because it is
easy but because of what failing it would mean — the readiness list that named it
did so as the cheapest way to answer *is the embedding good enough to state
compiler theorems in?*, and nobody knows.

A proof here is a small result. **A failure here is a large one**, and would move
the whole project: it would say the embedding needs work before any compiler
theorem is stateable, which is a different piece of work in a different tree.

### `desugar` — the pass that may not exist

The interesting design question, and it is genuinely open.

If the semantics is a **definition** rather than a program's output, then
desugaring is one of two things, and they are not the same project:

- **a proved transformation** on abstract syntax, mirroring what the existing
  compiler does, with a theorem that the desugared form denotes what the source
  form denotes; or
- **nothing at all** — the definitions are given directly over the surface
  syntax, and what is a pass today becomes a lemma about notation.

The second is the more attractive and the more likely to be wrong: surface
Eunoia has constructs whose meaning is genuinely stated by elaboration, and a
definition that pretends otherwise will be a definition of a smaller language
wearing the name of the real one. Deciding between them is goal 4's first
question, it needs the semantics before it can be decided, and this page will be
wrong about it until then.

Either way this pass is **not** where the project starts. It is where the
validated-semantics dependency bites, and that dependency is somebody else's:
see [prerequisites.md](prerequisites.md).

### The emitters, and the CompCert-shaped split

`lean_meta` writes Lean source text. A theorem about emitted *syntax* would need
the compiler to reason about the text it prints, which is the wrong shape and
buys nothing here.

So the split is the usual one: **the theorem covers the translation into a
semantic object; printing that object as Lean source is trusted, and checked by
round trip.** That leaves the printer in the trusted base by design rather than
by omission, and the classification it inherits — *checkable, by round trip and
cross-backend agreement* — is exactly this arrangement described from the other
side.

`smt_meta` has no counterpart: the verification-condition backend stays with the
existing compiler, which the entry's own account concedes.

## The trusted base, if all of this works

The point of the ledger is that this list is short, explicit, and written down
now rather than discovered by a reader later. A finished noesis would still
trust:

1. **the definitions** — that they say what Eunoia means. This is the one that
   matters most and the one this project cannot discharge for itself: it is the
   prerequisite owned by the compiler's tree, and until the embedding has been
   laid against the implementation, everything proved here is proved against a
   reading nobody has checked;
2. **the concrete parser** — getting from `.eo` text to abstract syntax, out of
   scope and deliberately so;
3. **the Lean printer**, per the split above;
4. **the checker of per-run evidence**, for every validated pass — small, and
   itself Lean;
5. **Lean**, and this project's use of it.

A claim that omitted any of the five would be false, and the aggregate claim is
never *the compiler is correct*.

## What would change this page

- **The probe failing.** Then the strength column is aspirational and the ledger
  is rewritten around what the embedding can actually state.
- **The desugar fork resolving.** Either resolution changes the last row and
  possibly removes it.
- **The line moving.** What the compiler is allowed to vary is what a signature
  contributes, and [question-7.md](question-7.md) is where that is kept. A
  second calculus changing the answer there changes what the emitter is obliged
  to produce, and therefore what a preservation statement says.
- **The compiler changing underneath.** The table above is a snapshot of somebody
  else's tree, taken from a document with a date on it. It is not maintained by
  them for this purpose and will drift.

[ready]: https://github.com/cvc5/ethos/blob/main/docs/noesis-readiness.md
