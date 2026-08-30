# Logos experience report

Every `sorry` a freshly generated checker contains, and what the same
obligation cost [Logos](https://github.com/cvc5/logos) — a verified checker for
CPC, a 591-rule calculus over most of SMT-LIB.

This is not a survey of Logos. It is a report against **the stubs a generated
checker actually contains**, one section each, so that before starting any of
them you know what you are walking into.

It is fixed documentation: it describes Logos, not your calculus, so it lives
here rather than being copied into each generated project. Those projects link
back to it.

Where two numbers are given they are `Cpc` (591 rules) against `CpcMini` (the
same signature reduced to five rules). The gap between them is the single most
useful thing in this document: it shows which costs follow the **signature and
its theories** and which follow the **rule count**.

## The inventory

A generated checker, immediately after `install/install-<calculus>.sh`:

| stub | obligation | in Logos |
| ---- | ---------- | -------: |
| [`Proofs/TypePreservation.lean`](#proofstypepreservationlean) | `smtx_typeof_wf` | 17,691 / 4,234 |
| [`Proofs/TranslationTypePreservation.lean`](#proofstranslationtypepreservationlean) | `eo_to_smt_type_typeof_of_smt_type` | 33,453 / 5,141 |
| [`Proofs/NonVacuity.lean`](#proofsnonvacuitylean) | `canonical_type_inhabited_of_type_wf`, then the model | 104 — but its hard half now ships proven |
| [`Proofs/Canonicity.lean`](#proofscanonicitylean) | none for a Boolean-only calculus — **proven** | 10,083 / 228 |
| [`Proofs/Checker.lean`](#proofscheckerlean) | `correct___eo_is_refutation` | 1,063 — **and identical across both packages** |
| [`Proofs/RuleSupport/Support.lean`](#proofsrulesupportsupportlean) | a stub, not a `sorry`: nothing to state rules against | 352,795 |
| [`Proofs/Rules/*.lean`](#proofsruleslean) | one per rule of your signature | 279,000 across 591 files |

Three more files carry **no** obligation, having been ported from Logos and
verified against a calculus that is not CPC:

- **`Proofs/TypeDefaults.lean`** (243 lines) and **`Proofs/TypePredicates.lean`**
  (36) come from `Cpc/Proofs/Canonical/TypeDefaultBasic.lean` and
  `Cpc/Proofs/TypePreservation/Predicates.lean`, two of six files Logos measures
  to be byte-identical between `Cpc` and `CpcMini`. They depend on nothing but
  the generated `SmtModel`, which is why they transfer unchanged.
- **`Proofs/Canonicity.lean`** is proven for the Boolean case.

Two more carry none for a different reason:

- **`ModelWf.lean`** is shipped proven. Its three theorems are the projections
  of the generated `model_wf`, immediate against that definition. Change
  `smt.eos` and they may not be — the build will say so, which is the point of
  having the file.
- **`Proofs/Invariants/Extra.lean`** is pointed at `True` and proves its one
  obligation trivially. That is the *correct* state for most calculi; see below.

## Reading order

1. **`Proofs/Invariants/Extra.lean`** — decide whether you need an extra
   invariant at all. It costs nothing to leave alone and is expensive to add
   later.
2. **`Proofs/TranslationTypePreservation.lean`** — the one nobody can hand you,
   and the one whose size you control by keeping the signature small.
3. **`Proofs/NonVacuity.lean`** — cheapest on the list, and the one whose
   absence would silently void everything else.
4. The rest, in any order. Each front-end theorem is a leaf: none imports
   another, so a `sorry` in one does not stop the others from building.

---

## `Proofs/Invariants/Extra.lean`

*No `sorry` — and the decision that most affects everything else.*

The core maintains three invariants of the proof state on its own: well typed,
translatable, locally true. This slot is for whatever **your** rules need beyond
that, and `Proofs/Checker.lean` is written against its four names without ever
mentioning what they stand for.

### What Logos did

`Cpc/Proofs/Invariants/Stability.lean` is **552 lines** against CpcMini's 488 —
and that difference is not duplication. CpcMini defines
`StableWhenTrueInAnyVarModel` as `True` and pays nothing; Cpc points the slot at
a real invariant.

CPC's is **assumption stability**: every assumption on the checker stack stays
true when the model's variable assignment is varied.

**The cost is not in that file.** `StableWhenTrueInAnyVarModel` is defined in
`Cpc/Proofs/Closed/Support.lean`, and `Closed/` is **32,274 lines** — larger
than Logos's entire checker layer. CpcMini has none of it.

**And exactly one rule uses the slot.** Of 591, `Re_unfold_neg` is the only
proof that reaches for `true_in_var_model`. (The `Closed/` machinery beneath is
shared more widely — `Quant_unused_vars` and other binder rules import it
directly — but the *invariant* has one consumer.)

### What to take from it

Leaving this at `True` is the common case and costs nothing. Do not reach for it
speculatively.

When a rule does need it, the price is paid in the machinery it rests on, not
here. The question is not "do I want this invariant" but **"am I prepared to
build what it stands on"** — for CPC, 32,274 lines for one rule.

It is also coupled to `Proofs/RuleSupport/Support.lean`: a load-bearing
invariant needs a matching field in the evidence a rule receives about its
premises (`true_in_var_model` alongside `true_here`). Decide both together, up
front.

---

## `Proofs/TranslationTypePreservation.lean`

*`sorry`: `eo_to_smt_type_typeof_of_smt_type`. The corollaries below it are
proven from it.*

The bridge between the two type systems: the checker computes `__eo_typeof`,
the semantics computes `__smtx_typeof`, and this connects them.

### What Logos did

`Cpc/Proofs/Translation/`: **33,453 lines across 11 files**, against CpcMini's
5,141 across 5.

| file | lines |
| ---- | ----: |
| `Apply.lean` | 17,003 |
| `EoTypeofCore.lean` | 6,887 |
| `Full.lean` | 4,967 |
| `Inversions.lean` | 3,524 |
| `Base.lean` | 501 |

`Apply.lean` is the application case — one arm per operator of the signature.
That is the shape of the whole development: a case analysis over the operator
set.

### What to take from it

CpcMini has the same 591-operator signature and only five rules, and still pays
**5,141 lines here**. This cost follows your *signature*, not your rule count.

It is also the only obligation on this list that no upstream work can ever
discharge, because it is about `__eo_to_smt` for your operators, generated from
your `.eos`. That makes keeping the signature small the one lever you have.

---

## `Proofs/TypePreservation.lean`

*`sorry`: `smtx_typeof_wf` — a term the semantics types has a well-formed type.*

### What Logos did

`Cpc/Proofs/TypePreservation/`: **17,691 lines across 16 files**, against
CpcMini's 4,234 across 10. The files are named by theory — `CoreArith.lean`,
`BitVec.lean`, `Sets.lean`, `SeqStringRegex.lean` — which is itself the evidence
that the cost follows theories.

About half is invariant between the two packages: `Datatypes.lean` (1,334 lines)
is byte-identical, `Common.lean` (529) differs by four lines. The
theory-specific halves hold the size.

---

## `Proofs/NonVacuity.lean`

*`sorry`: `model_wf_nonvacuous` — a well-formed model exists.*

Easy to overlook and fatal to omit. Soundness says the assumptions of a checked
proof hold in **no** well-formed model. If `model_wf` were satisfied by nothing,
that would be true of every proof, and the development would prove nothing while
appearing to prove everything.

### What Logos did

`Cpc/Proofs/TypePreservation/Nonvacuity.lean`: **104 lines** — by far the
cheapest thing on this list.

It constructs a model rather than arguing one exists: every symbol is mapped to
a default value of its declared type, and the three conjuncts of `model_wf` are
discharged against that construction. It reduces to one lemma about the value
types — every well-formed type has a canonical inhabitant — and the rest is
bookkeeping.

Copy that shape: find a canonical inhabitant per type and the model is
immediate. With the stock SMT-LIB types this is nearly free.

---

## `Proofs/Canonicity.lean`

*`sorry`: `model_eval_boolean_canonical`, and one more per literal kind you add.*

That evaluating a literal gives a value in normal form — bit-vectors reduced
modulo their width, maps ordered and without redundant entries.

### What Logos did

`Cpc/Proofs/Canonical/`: **10,083 lines across 11 files**, against CpcMini's
**228 in one**.

That ratio — 44 to 1 — is the sharpest illustration here of cost following
theories. The one file CpcMini keeps, `Canonical/TypeDefaultBasic.lean`, is
byte-identical to Cpc's. Everything else — `Maps.lean`, `Seq.lean`, `Ops.lean`,
`Pump.lean`, `FiniteSoundness.lean` — exists because CPC has arrays, sequences,
strings and sets, each with its own notion of normal form.

A calculus over Booleans owes the one file. Add a theory with structured values
and you buy its canonicity development with it.

---

## `Proofs/Checker.lean`

*`sorry`: `correct___eo_is_refutation` — the soundness theorem.*

**This one should not be yours, and the evidence is unusually clean.**

### What Logos did

`Cpc/Proofs/Checker.lean` is **1,063 lines and byte-identical to
`CpcMini/Proofs/Checker.lean`** modulo the package name. Those two packages
differ in rule set (591 against 5), in signature, *and* in which invariants
their rules require. It names no rule and no operator, and uses three `Term`
constructors.

It is a proof about a stack machine that pushes assumptions and proven facts —
not about a calculus.

### What to take from it

Do not start here, and do not expect to write it. It carries a `sorry` in this
template only because upstream still maintains it per package rather than
seeding it into new ones. When that changes it should arrive copied in, like
`Api.lean` and `ApiChecks.lean` already do.

---

## `Proofs/RuleSupport/Support.lean`

*A stub rather than a `sorry`: every generated rule statement is written against
names it is meant to supply, so until it is real no rule can be built at all.
`scripts/build-rules.sh` reports that instead of hundreds of identical errors.*

### What Logos did

`Cpc/Proofs/RuleSupport/`: **352,795 lines**. It is the largest thing in the
repository, larger than the rule proofs themselves, and it is a flat directory
of per-theory support libraries that the individual rule proofs draw on.

The seam itself is small — `Contract.lean` is 164 lines and defines
`StepRuleProperties`, the contract between the checker and a rule. What grows is
everything beneath it.

---

## `Proofs/Rules/*.lean`

*One `sorry` per rule of your signature, emitted with the rule's statement.*

### What Logos did

**279,000 lines across 591 files**, and a full build takes over two hours.

The statement is generated and the proof goes in the same file, so a reinstall
preserves it — which is why a rule whose *statement* changed keeps its old proof
and fails to build. That failure is the signal.

`scripts/rule-status.sh` counts what is left; `scripts/build-rules.sh` builds
the proofs that exist, one at a time, and is resumable.

---

## The one-line summary

Of the seven obligations above, one (`Checker.lean`) should not exist, one
(`NonVacuity`) is nearly free, one (`Invariants/Extra`) is usually free, and the
remaining four scale with **how much SMT-LIB your calculus takes on**. Logos's
own numbers make the point: 61,000 lines of semantics against a 4,500-line
checker layer.

Keep the signature small until the development works.
