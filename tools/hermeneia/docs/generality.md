# What Hermeneia depends on, and what it therefore tracks

**The premise.** Hermeneia assumes Logos evolves as CPC does. Keeping the
checker, its rule proofs and its semantics in step with the calculus is Logos's
responsibility, and nothing here is a claim on it. This document is about the
other side of that assumption: **given** a Logos that tracks CPC, what does
Hermeneia have to redo, and when?

**The answer.** Hermeneia is not downstream of the calculus. It is downstream of
the *semantics* and of one theorem's *statement*. CPC can gain rules and
operators indefinitely without reaching this project; the channel by which CPC
growth eventually does reach it is Logos extending `smt.eos`, and only then.

## 1. The dependency boundary, measured

`Instances/HermeneiaCpc/Bridge.lean` is the reusable layer — the refutation
seam, model realisation, sorts and symbol laws. Counting the declarations it
names from Logos:

| what it names | how many | examples |
| --- | --- | --- |
| the **SMT-LIB semantics** (`Smtm`) | **45** | `smt_satisfiability`, `model_wf`, `__smtx_model_eval`, `__smtx_typeof_value`, `default_typed_model`, the `SmtType`/`SmtValue`/`SmtTerm` constructors it classifies |
| the **calculus**, in total | **5** | `eo_satisfiability`, `__eo_to_smt`, `argListAssumes`, `CArgList.nil`, `CArgList.cons` |
| CPC **proof rules** (`CRule`) | **0** | — |
| CPC **operators** (`UserOp`, `UserOp1..3`) | **0** | — |
| Logos's **proof** of anything | **0** | the bridge imports no rule proof and rechecks none |

The five calculus names are all type-level or fold-level: none of them is an
operator, and the bridge never case-splits on `Eo.Term`. Two definitional facts
about the fold are needed and are discharged by `rfl` — that `argListAssumes`
builds an `and`-chain which `__eo_to_smt` sends to `SmtTerm.and`, and that the
Bool literals translate. Those are exactly Eudaimonia's
[signature contract](../../../README.md#the-signature-contract), which the
framework already requires of any signature it will generate a checker for.
They are not *named* anywhere; they are enforced by two `rfl`s that would fail.

Separately, `Example.lean` and `Refutation.lean` name **five** declarations from
the checker theorem's statement — `correct___eo_is_refutation`,
`eo_is_refutation.intro`, `__eo_checker_is_refutation`,
`TranslatableAssumptionList`, `CmdListTranslationOk` — and nothing from its
proof. `Refutation.lean` is three lines for exactly that reason.

So Hermeneia depends on three things, and the third is tiny:

1. the SMT-LIB semantics `smt.eos`;
2. the **statement** of the checker theorem and its two side conditions;
3. the signature contract's `and` and Bool literals.

**And on none of these:** CPC's rule set, CPC's operator set, or the
correctness of any Logos proof. Hermeneia composes with the checker theorem and
retains whatever hypotheses it carries; it does not re-establish it.

## 2. What that buys, and what it does not

Because the dependency runs through the semantics, the things that can be added
to, or changed in, the ecosystem land very differently:

| what is added | today | does Hermeneia react? |
| --- | --- | --- |
| a CPC **proof rule** | 591 | **no** — `correct___eo_is_refutation` names no rule. Measured: the file stating it is byte-identical between `Cpc` (591 rules) and `CpcMini` (5). |
| a CPC **operator** (`UserOp`/`UserOp1..3`) | 189 | **no**, as long as Logos translates it into `SmtTerm` constructors that already have laws |
| an **`SmtTerm` constructor** | 148 | **yes** — one evaluation law, or it is classified unsupported (layer 3) |
| an **`SmtType`** (a sort) | 15 | **yes** — a carrier, a realisation proof, and, for quantifiers, a coverage proof (layer 2) |
| a change to an **existing** `smt.eos` symbol | — | **yes, loudly** — the affected law must fail to prove, not silently pass (§5) |
| a change to the checker theorem's **statement** | — | **yes, loudly** — `Refutation.lean` stops compiling |

The rows that say "no" are not claims that the work is cheap. They are claims
that the work is not Hermeneia's: when CPC gains an operator, someone extends
`Cpc.eo` and someone extends the semantics, and Hermeneia is reached only if
that second step introduced a constructor it has no law for.

The rows that say "yes" are the real backlog, and they are bounded by numbers an
order of magnitude smaller than the calculus's.

## 3. Why the boundary sits there

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

This was a choice, not an accident, and it is the choice everything else in this
document rests on. Written the other way — an induction over `Eo.Term` with a
case per `UserOp` — Hermeneia would have acquired a 189-case obligation that
grows with every CPC release, for no gain: the cases would have been about
translating into the same `SmtTerm` constructors the semantics layer already
has laws for.

## 4. Sorts have two directions, and they behave differently

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

## 5. The five mechanisms that keep it honest as the semantics grows

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

## 6. What this instance does and does not establish

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
