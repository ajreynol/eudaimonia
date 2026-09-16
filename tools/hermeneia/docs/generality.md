# What has to happen as the calculus grows

**The question.** Hermeneia's first instance bridges one sort and two symbols.
CPC has 591 rules and 189 operators today and will have more tomorrow. What of
this project has to be redone each time something is added, and what does not?

**The answer, in one line.** Rules and calculus operators cost nothing. The
cost is in the *semantics*: one law per `SmtTerm` constructor, and one carrier
with two separate directions per `SmtType` constructor. Those are the numbers to
watch, and they are much smaller and much slower-moving than the calculus.

## 1. The scaling law

| what is added | today | what Hermeneia owes | why |
| --- | --- | --- | --- |
| a CPC **proof rule** | 591 | **nothing** | `correct___eo_is_refutation` names no rule. Measured: the file stating it is byte-identical between `Cpc` (591 rules) and `CpcMini` (5). |
| a CPC **operator** (`UserOp`/`UserOp1..3`) | 189 | **nothing**, if it translates into `SmtTerm` constructors that already have laws | `eo_satisfiability t b` is *defined* as `smt_satisfiability (__eo_to_smt t) b`, so the calculus is discharged by *computing* `__eo_to_smt` on the concrete assumptions, never by reasoning about it |
| an **`SmtTerm` constructor** | 148 | one evaluation law, or it is classified unsupported | layer 3 of [`Bridge.lean`](../Instances/HermeneiaCpc/Bridge.lean) |
| an **`SmtType`** (a sort) | 15 | a carrier, a realisation proof, and — for quantifiers — a coverage proof | layer 2 |
| a change to an **existing** `smt.eos` symbol | — | the affected law must *fail to prove*, not silently pass | §4 |

The shape of that table is the whole design. It is achieved by one decision,
which is §2.

## 2. Bridge at the semantics, not at the calculus

Hermeneia could have been written as an induction over `Eo.Term`, with a case
per `UserOp`. It is not. Every theorem in [`Bridge.lean`](../Instances/HermeneiaCpc/Bridge.lean)
is about `Smtm` — the SMT-LIB semantics — and none mentions a calculus operator
or a rule. The file imports `Cpc` only because that is where the generated
`Smtm` namespace lives.

This is sound because Logos's conclusion is *already* a statement about
`SmtTerm`: `eo_satisfiability` is definitionally `smt_satisfiability` of the
translation. So the calculus enters only as a computation — for a concrete
assumption list `F`, `__eo_to_smt (argListAssumes F)` is a closed term that
reduces, and the tactic proves the resulting equality by `rfl`. Adding operators
to CPC cannot invalidate a proof that never quantified over them.

It also means the bridge is not CPC-specific at all. Eudaimonia already
identifies `smt.eos` by digest in a checker's
[profile](../../../docs/generated-checker.md); any two checkers agreeing on that
digest can share this bridge unchanged. Retargeting it is an import change.

Two calculus-level facts *are* needed, and they are exactly Eudaimonia's
[signature contract](../../../README.md#the-signature-contract): a binary `and`
sent to `SmtTerm.and`, and the Bool literals. Both hold by `rfl` here, and the
contract already requires them of any signature the framework will generate a
checker for. A signature that broke either would break `eval_argListAssumes`
rather than pass silently.

## 3. Sorts have two directions, and they behave differently

| direction | what it says | who needs it | how it scales |
| --- | --- | --- | --- |
| **realisation** | every native value of the carrier has a well-typed, canonical embedded counterpart, injectively | everything | **independent per sort.** Adding a sort cannot break an existing realisation proof. |
| **coverage** | every embedded value *of that sort* is the image of a native one | quantifiers only | **not independent.** Adding a sort can reopen every existing coverage proof. |

`SortRealize` and `SortCover` in `Bridge.lean` are these two, deliberately
separate records rather than one.

**Coverage is where the coupling is, and it is not theoretical.** `boolCover` —
"nothing but the `Boolean` constructor has type `Bool`" — is not a fact about
`Bool`. Its proof needs shape lemmas about maps, sets, sequences and
datatype-constructor application chains, because those are the other ways a
value could have acquired that type. Proving it required an auxiliary theorem
(`apply_value_chain`) about datatype application, for a bridge that mentions no
datatypes. A new value former with a permissive typing rule would send someone
back to `boolCover`.

**A sort can realise and not cover.** Bridging Lean `Nat` to `SmtType.Int`
realises — every `Nat` is an `Int` — and does not cover, since negative numerals
are no `Nat`. So an embedded `∀` over `Int` is not a Lean `∀ n : Nat` without a
guard. lean-smt embeds `Nat` exactly this way, so this is the first case anyone
will hit rather than a curiosity.

**A sort can fail realisation outright**, and then there is nothing to design
around. `SmtValue.Rational` carries a `Rat`, so a Lean `ℝ`-valued assignment has
no embedded counterpart at all: `ratSort` is the only carrier `SmtType.Real`
admits. The same argument, in its own way, excludes arbitrary Lean types under
uninterpreted sorts and arbitrary Lean functions under arrays. These are Logos's
three recorded [narrowings][conf], read from this side; the
[ledger](ledger.md#where-the-semantics-is-narrower-than-lean) records the
decisions.

[conf]: https://github.com/cvc5/logos/blob/main/docs/smt-lib-conformance.md

## 4. The five mechanisms that keep it honest as it grows

None of these is in place yet; they are what the plan has to build.

**M1 — the classifier is exhaustive, and the default is "unsupported".**
The supported fragment must be a decidable predicate written as a `match` over
`SmtTerm` and `SmtType` constructors **with no catch-all**, so that adding a
constructor makes Hermeneia *fail to compile* until someone classifies it. A
catch-all returning `false` would be sound — a new constructor would fall
outside the fragment — but silent, and silence is the failure mode this project
exists to avoid. The fix for a new constructor is one line (`| .newThing =>
.unsupported`), which is the right price.

**M2 — Hermeneia needs its own `incomplete`.**
Logos already reports three verdicts, because its semantics does not cover
everything CPC can express; a proof it accepts whose terms have no SMT
translation is `incomplete`, not `correct`. Hermeneia needs the same valve for a
second, narrower reason: the Lean correspondence does not cover everything the
semantics expresses. The two narrowings are in series, and a tactic built on
this must have three outcomes — certified, outside the certified fragment
(naming the symbol or sort), rejected — never two.

**M3 — obligations are generated, not listed.**
[The contract](contract.md#3-additional-fields-intent-followed-by-evidence)
proposes per-symbol fields; what makes them load-bearing is that the *statement*
of each law is emitted from `smt.eos` and a person supplies the proof or a
declaration of non-support. Then adding a symbol produces an unproved obligation
automatically. Without this, the classifier and the semantics drift apart and
nothing notices. This is plan step H5, and §1 says it should come before H4's
breadth rather than after it.

**M4 — statements name actual declarations.**
Every law is an equation about the *generated* `__smtx_model_eval_*` functions.
A change to an existing symbol's meaning therefore breaks a proof rather than a
statement — the failure is loud and local. A new symbol, by M1, breaks the
classifier. Between them, the only silent outcome left is a change that alters
no law and adds no constructor, which is the one that should be silent.

**M5 — a certification names the semantics it is of.**
Hashes do not establish correspondence, but they say *what* was corresponded.
Eudaimonia already computes whether a checker's `smt.eos` is Logos's unmodified;
a Hermeneia certification must record that identity, so that "this fragment is
certified" is never read as a claim about a different semantics.

## 5. What this instance does and does not establish

[`Instances/HermeneiaCpc/`](../Instances/HermeneiaCpc) is against **full CPC**,
not a cut-down calculus. Layers 0 and 1 are complete and general: the refutation
seam reports no `native_decide` axiom at all, and model realisation is proved
for an arbitrary finite assignment. Layer 2 has two sorts of four constructors'
worth of work, with both directions for `Bool` and `Int` and the carrier fixed
for `Real`. Layer 3 has four laws of 148.

What is absent is everything in §4. There is no classifier, no decidable
fragment, no `incomplete`, no generated obligation, and no recorded semantics
identity — so today the instance is a proof that the layering works, not a
system that stays honest while CPC moves.

### A note on CpcMini

An earlier version of this instance was written against Logos's `CpcMini`, a
five-rule calculus. That was a mistake twice over: `CpcMini` is Logos's own
development playground and not an interface anyone should depend on, and it
bought nothing — `Proofs/Checker.lean` and
`Proofs/TypePreservation/Nonvacuity.lean` are byte-identical between the two
packages modulo the package name, and the CPC versions of everything this
instance needs build in about a minute. The only thing `CpcMini` was ever
shortening was the *rule proofs*, which the bridge does not import. Splitting
[`Refutation.lean`](../Instances/HermeneiaCpc/Refutation.lean) off from
[`Example.lean`](../Instances/HermeneiaCpc/Example.lean) gets that saving at full
generality: the bridge is rechecked in a minute, and CPC's whole proof
development is built once, for the last three lines.
