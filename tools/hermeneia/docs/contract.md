# Correspondence for a configurable semantics

Hermeneia certifies a **particular generated semantics against a stated Lean
interpretation**. Changing a `.eos` file can change the proposition being
checked. There is no project-wide Boolean flag saying that Logos matches Lean.
The reusable artifact is a family of contracts; each configuration supplies
proofs of the contracts for the fragment it supports.

The [Lean prototype](../Hermeneia/Contract.lean) checks the shape of these
contracts and proves their generic composition. It does **not** yet instantiate
them with Logos. The [work plan](plan.md) separates that next step from what is
already checked.

## 1. What is being related

For configuration `C`, the diagram to prove commutes is:

```text
calculus Term ── translate_C ──> SmtTerm ── eval_C M ──> SmtValue
     │                                                    ▲
     │ native meaning under assignment ρ                 │ encode_C
     └───────────────────────────────> Lean value ─────────┘
```

There are at least three inputs to this meaning: the calculus `.eos` chooses
the translation, `smt.eos` chooses typing and evaluation, and the backend's
native definitions implement primitives such as integer addition. The signature,
compiler, generated definitions, and Lean version also belong to the instance.
The current native layer is itself configurable through
`plugins/lean_meta/lean.eos` in Ethos.

An instance record must retain:

| input | required identity |
| --- | --- |
| Signature and calculus semantics | Entry paths and SHA-256 of the complete input closure, including includes. |
| SMT semantics and native definitions | Entry paths and SHA-256 of the complete closure, including backend configuration and relevant plugins. |
| Generator and compiler | Exact commits, local changes if any, options, and reproducible generation command. |
| Generated Lean | Module names and source hashes, including translation, model, primitives and checker theorem dependencies. |
| Native interpretation | Target types, operations, side conditions, representation and proof module hashes. |
| Lean environment | Toolchain and dependency lockfile. |

Hashes identify what was examined; they are not evidence of correspondence.
The proofs refer to the **actual imported declarations**, not to a copied model
or a hash string. Regeneration must rebuild those proofs. A changed input makes
the old report stale; it does not necessarily make the mathematical theorem
false. Dependency-aware reuse can come later; initially recheck the whole
selected fragment. A metadata edit cannot preserve a certification without
rechecking its theorem.

## 2. Give `Term.Numeral` a precise claim

In the inspected Logos source, the following are distinct facts:

```lean
SmtEval.native_Int = Int                         -- carrier abbreviation
__eo_to_smt (Term.Numeral n) = SmtTerm.Numeral n   -- translation
__smtx_typeof (SmtTerm.Numeral n) = SmtType.Int    -- term typing
__smtx_typeof_value (SmtValue.Numeral n) = SmtType.Int
__smtx_model_eval M (SmtTerm.Numeral n) = SmtValue.Numeral n
```

These are statement sketches using the inspected names, not checked Logos
theorems shipped here. Their sources are in [the ledger](ledger.md).
The first claim is definitional equality of types; the final claim is semantic
equality of values. A constructor carrying an `Int` proves only the former.

Choose `encodeInt n := SmtValue.Numeral n`. Require its typing and injectivity,
then require literal translation, typing and evaluation. The resulting claim
is, for **every `n : Int` and every model `M`**:

```text
eval_C M (translate_C (Term.Numeral n)) = encodeInt n
```

`SortBridge`, `LiteralBinding` and `NumeralBridge` are the compiled version of
this requirement. The concrete adapter binds both constructors and `encodeInt`
explicitly; changing the native representation means making a different claim.
Literal evaluation needs no `model_wf` hypothesis for this source. The prototype
also proves `numeral_denotes`, composing the two semantic steps.

This says Lean **`Int`**, not `Nat` or an arbitrary `OfNat` instance. Negative
constructor payloads are included. Native Lean numeral notation is overloaded;
the [Lean integer reference](https://lean-lang.org/doc/reference/latest/Basic-Types/Integers/)
documents the `Int` instance and its separate negation operation. A later bridge
from a Lean `Nat` expression needs an explicit cast and its own operation laws.

The configurable source currently says:

```lisp
(define-literal Numeral ((n <numeral>))
  :typeof Int
  :value (smt.numeral n))
```

If its value becomes `(smt.numeral ("zplus" n 1))`, the same constructor and
carrier remain but the chosen correspondence is false at zero. Likewise,
changing the translation can invalidate the claim even when evaluation is
unchanged. Both failures have checked synthetic witnesses in
[Checks.lean](../Hermeneia/Checks.lean). Actual `.eos` mutation tests are still
work in the plan.

## 3. Additional fields: intent followed by evidence

The existing `:typeof` and `:value` fields define the embedded semantics. They
do not identify a native interpretation to compare it with. Proposed additional
information is:

| proposed field | purpose | obligation it creates |
| --- | --- | --- |
| `:lean-type` | Native carrier for a sort, e.g. `Int`. | Elaborates to the expected type. |
| `:lean-encode` | Native-to-embedded value map. | Correct embedded type and injectivity; canonicality where the model requires it. |
| `:lean-denote` | Native meaning of a literal or operation. | Evaluation agrees with this expression on related arguments. |
| `:lean-domain` | Explicit side condition; `True` for unconditional agreement. | Every use proves this condition. |
| `:lean-bridge` | Name of the correspondence proof or proof bundle. | Its type is exactly the generated obligation for this configuration. |

For example, this is **proposed syntax, not accepted `.eos` today**:

```lisp
(define-sort Int ()
  :default (smt.numeral 0)
  :lean-type "Int"
  :lean-encode "SmtValue.Numeral")

(define-literal Numeral ((n <numeral>))
  :typeof Int
  :value (smt.numeral n)
  :lean-denote "fun (n : Int) => n"
  :lean-domain "True"
  :lean-bridge "Hermeneia.Generated.numeral")
```

Initially put these choices in a hand-written Lean adapter inside Hermeneia;
it already gives typed fields and requires proofs. Only after the first actual
adapter works should a sidecar format or `.eos` extension be implemented.
The quoted Lean text above is a design sketch, not a decided interchange format.
The existing `define-method :lean` facility emits Lean clauses; it is not a
correspondence annotation or a substitute for these obligations.

The calculus side separately identifies the source constructor/operator and
proves its translation to the selected SMT operation. Overloaded symbols need
one entry per sort signature: integer `+` and real `+` are different claims.
Proof lookup must check the full type, including selected operations and
conditions; finding a declaration with the right name is insufficient.

Missing annotations mean **unsupported**. An annotation without a checked proof
means **declared**. A checked theorem with explicit domain/model conditions is
**conditional**. An unconditional checked theorem is **direct**. None of these
statuses should be selected by a trusted user-supplied `matchesLean := true`.
Failed proof elaboration prevents certification of the affected fragment.

## 4. Operators and formulas require more

Numerals alone say nothing about addition. For integer addition, separately
prove that the selected evaluator on `encodeInt x, encodeInt y` returns
`encodeInt (x + y)`. `BinaryBridge` states this local law. A complete operation
adapter must also prove translation, term typing and the equation that connects
recursive term evaluation to that evaluator. Then structural induction proves
the expression theorem. The prototype's subtraction-in-place-of-addition
witness shows why the literal bridge cannot certify an operation.

Booleans first correspond to Lean `Bool`. Native propositions are obtained by
`b = true`: prove the `true`, `false`, `not` and `and` equations and their
propositional equivalences. Representing arbitrary Lean propositions via
`decide` requires decidability or an explicit classical interpretation; it
must not appear as an unexplained coercion in generated proofs.

An assignment relation must use typed variable identities and preserve sharing
and distinctness. It must include a construction of a **globally well-formed**
model for every supported native assignment, including defaults outside the
fragment and the model's function component. Just proving evaluation agrees
assuming a related model exists is insufficient. `FormulaBridge.realizes`
exposes this obligation, and `empty_models_rejected` checks a vacuous model
class cannot supply it for an inhabited assignment space.

Keep the first fragment quantifier-free. Extending to quantifiers needs coverage
of all relevant embedded values, not just injectivity of `encode`; function
sorts and binders need further environment and application laws. The prototype
deliberately does not assert these.

## 5. The exact refutation seam

The inspected `smt_satisfiability t false` means every well-formed model
evaluates `t` to **`SmtValue.Boolean false`**. It is stronger than merely saying
no model evaluates to true. Hermeneia's generic `Unsatisfiable` uses the latter.
The actual adapter must prove the one-way conversion by excluding equality
between the true and false constructors. Do not silently redefine Logos's
predicate or assume every untyped value is Boolean.

`transfer_unsat` derives `∀ ρ, ¬ native ρ checked` from the formula bridge and
that no-true-model conclusion. `transfer_refutation` additionally requires:

```text
native ρ checked ↔ (hypotheses ρ ∧ ¬ goal ρ)
```

The adapter must use the exact `argListAssumes F` named by checker soundness,
prove its supported-fragment membership, and connect the actual list `F` to
the intended hypotheses and negated goal. Its conjunction fold and empty-list
case are proof obligations too. Retain translatability, command translation and
all remaining soundness hypotheses. No parser or solver verdict supplies them.

The generic transfer theorem is checked but conditional on its bridge and
unsatisfiability arguments. It is not a checked solver example. Its classical
refutation step uses `propext`, `Classical.choice` and `Quot.sound` according to
Lean's axiom report; `numeral_denotes` and `transfer_unsat` use no axioms.
