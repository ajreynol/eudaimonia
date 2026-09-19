# Initial correspondence ledger

Inspected 2026-09-16. These are source findings and planned proof obligations,
**not certified coverage**. What has been compiled is the generic interface, its
synthetic checks, and one instance against **full CPC**, whose rows below say so
explicitly. Everything else is a reading of source. This distinction persists
even when a proposed concrete proof looks as simple as `rfl`.

| subject | observed embedded meaning / Lean target | obligation or boundary | status |
| --- | --- | --- | --- |
| `Int` sort | `native_Int` abbreviates Lean `Int`; values are `SmtValue.Numeral`. | Carrier, typing, canonicality, injectivity — and coverage for quantifiers. | **Both directions proved** against `Cpc`: `intSort` and `intCover`. The *operations* remain open (next rows). |
| `Term.Numeral n` | Translation to `SmtTerm.Numeral n`, evaluation to `SmtValue.Numeral n`. | Universal signed-integer literal theorem through both stages. | Source inspected; generic law checked, actual instance open. |
| `Bool` sort | `SmtValue.Boolean b`; native `Bool`, then proposition `b = true`. | Carrier, typing, canonicality, injectivity — and coverage for quantifiers. | **Both directions proved** against `Cpc`: `boolSort` and `boolCover`. Coverage needed auxiliary shape lemmas about maps, sets, sequences and datatype application — see [below](#sorts-two-directions-and-how-each-scales). |
| Free constants | `Term.UConst n T` translates to `SmtTerm.UConst "@u.<n>" T`; lookup is `M.values (model_key ...)`. | Every native assignment extends to a globally well-formed model. | **Proved in general** against `Cpc`: `exists_model` builds one for an arbitrary finite assignment by overriding Logos's `default_typed_model`. `model_fun_wf` is untouched by a `values` override; the rest reduces to the sort's typing and canonicality. `Term.Var` (bound variables) is untouched. |
| `and`, `not`, Bool literals, `UConst` | `SmtTerm.and`/`not`/`Boolean`/`UConst` evaluation. | One evaluation law per `SmtTerm` constructor. | **Proved** against `Cpc` (`eval_and`, `eval_not`, `eval_bool`, `eval_uconst`) — 4 of 148 constructors. The `and` law plus the Bool literals are what the conjunction fold `eval_argListAssumes` needs, and they are exactly Eudaimonia's signature contract. |
| Integer `+` | `smt.eos` selects `zplus` for numeral values; native implementation uses Lean addition. | Typed integer overload, local value law and term composition. | Open. |
| Integer equality/order | Boolean-valued comparison of integer payloads. | Tie equality to the faithful representation; compare to the Lean proposition via `= true`. | Open. |
| `div_total`, `mod_total` | Native helpers use Lean integer `/` and `%`. | Fix these particular helpers; prove their value and term laws. | Source inspected; excluded initially. |
| Public `div`, `mod` | At zero divisor the SMT semantics calls model-chosen functions. | Use a nonzero-divisor condition, constrain model choices with realizability proved, or carry these choices in the native interpretation. Unconditional native `/` and `%` are not justified for arbitrary models. | Boundary identified; excluded initially. |
| `Real` sort | `SmtValue.Rational` carries a Lean `Rat`. | Choose and justify the carrier. | **Decided: the carrier is `Rat`; there is no `ℝ` bridge.** `ratSort` is proved; see [below](#where-the-semantics-is-narrower-than-lean). The narrowing makes an `ℝ`-valued assignment unrealisable, not merely unproved. |
| Bit-vectors / strings | Indexed or validity-constrained representations. | Width, normalization, character domain and exceptional behavior before operation laws. | Deferred. |

## Evidence baseline

The revisions below identify source inspection, not a single regenerated build.
Both neighboring working trees were clean when read. Paths are relative to the
Eudaimonia root; neighboring files are read-only evidence, not package imports.

| tree | inspected commit / setting |
| --- | --- |
| Eudaimonia | `4f92c6284b8977047f8cb51d8d187f83ae9a39fc` |
| Logos | `be4791204be5616df2bf6f42ea304b45b08d33e1` |
| Ethos | `8dc85c4db8d6cc612f02dc3bb627331732605eff` |
| Eudaimonia's compiler pin | `406b5499f3c83f2a114113107be251f8e58b2d85` — different from the inspected Ethos checkout |
| Hermeneia experiment toolchain | `leanprover/lean4:v4.33.0` |
| Logos build used by `Instances/HermeneiaCpc` | a scratch copy of `be4791204be5616df2bf6f42ea304b45b08d33e1` |
| cvc5 used for the coverage probe | `1.3.5.dev+HEAD@c17a2d05ff` |
| lean-smt read (not built) | `ufmg-smite/lean-smt@5bdc51674065a074ece67b04e10024e9f426ec1f` |
| lean-cvc5 read (not built) | `abdoo8080/lean-cvc5@7e3365990661b697ccb30e92d6912f4cc6589322` |

Relevant declarations at those revisions:

- Eudaimonia `new_checker/examples/hello/smt.eos`: `define-sort Int`, the value constructor
  `Numeral`, `define-literal Numeral`, Boolean and arithmetic symbol entries.
- Logos `Cpc/LogosTerm.lean`: `Term.Numeral : native_Int → Term`.
- Logos `Cpc/Spec.lean`: `__eo_to_smt` literal and Boolean cases;
  `eo_satisfiability` delegates to `smt_satisfiability`.
- Logos `Cpc/SmtModel.lean`: `__smtx_typeof`, `__smtx_typeof_value`,
  `__smtx_model_eval`, `model_wf`, and `smt_satisfiability.intro_false`.
- Logos `Cpc/SmtEval.lean`: `native_Int`, Boolean primitives, `native_zplus`,
  `native_div_total` and `native_mod_total`.
- Ethos `plugins/lean_meta/lean.eos`: native carrier and operation definitions;
  `plugins/model_smt/model_smt.eo`: builtin numeral translation case.
- Ethos `tools/eoc/sem_target.py`: `LITERALS` admits typing/value aggregates;
  `tools/eoc/semantics/README.md`: current attributes and native layer grammar.
- Logos `Cpc/Api.lean`, `Cpc/ApiCorrect.lean`, `Cpc/Native.lean`,
  `Cpc/Native/Correct.lean`: the two front ends and the soundness statements
  about what each computes.
- Logos `Cpc/Proofs/Checker.lean`: `correct___eo_is_refutation`;
  `Cpc/Proofs/TypePreservation/Nonvacuity.lean`: `default_typed_model` and
  `default_typed_model_total_typed`;
  `Cpc/Proofs/TypePreservation/Helpers.lean`: `typeof_map_value_shape`,
  `typeof_seq_value_shape`, `dt_cons_chain_result_of_dt_cons_value_type`.

The [contract's proposed attributes](contract.md#3-additional-fields-intent-followed-by-evidence)
are additions to this inspected language, not existing features. Full input
hashes and generation provenance belong to H1's actual instance manifest;
these source pointers alone cannot certify a configuration.

## What the prototype has checked

`lake build` on the pinned toolchain checks `numeral_denotes`, `transfer_unsat`
and `transfer_refutation`. It also proves that fixed native bindings reject
a shifted literal value, shifted literal translation, subtraction substituted
for addition, and an everywhere-false model well-formedness predicate with an
inhabited native assignment space. These fixtures are not generated from `.eos`.

Lean reports no axioms for the literal composition, unsatisfiability transfer
or the fixture theorems. The classical refutation theorem reports `propext`,
`Classical.choice`, `Quot.sound`. None reports `sorryAx`; no checker soundness
theorem is imported. The theorem arguments still carry the uninstantiated
correspondence and unsatisfiability obligations.

## Model existence, and why it is cheaper than the plan assumed

`FormulaBridge.realizes` — every native assignment has a corresponding
*globally* well-formed model — was the obligation
[the contract](contract.md#4-operators-and-formulas-require-more) singles out as
the one that cannot be weakened to "assuming a related model exists". It turns
out not to need a model built from nothing.

Logos proves models exist. `Cpc/Proofs/TypePreservation/Nonvacuity.lean` defines
`default_typed_model`, which assigns every well-formed SMT type a canonical
inhabitant, and proves `default_typed_model_total_typed : model_wf
default_typed_model` — in a 14-job, 32-second build that touches no rule proof.
Realising a native assignment is then an **override** at the finitely many keys
the checked assumptions mention:

- `model_fun_wf` constrains only `nativeFuns`, which an override leaves alone,
  so it transfers unchanged;
- the other two conjuncts of `model_wf` reduce, at the overridden key, to the
  typing and canonicality of the substituted value at that key's type — which is
  what a `SortBridge` already has to supply.

`Instances/HermeneiaCpc/Bridge.lean` proves this as `model_wf_override`, and
`exists_model` lifts it to an arbitrary finite assignment. The sorts where it
stops working are not the ones where the construction is hard but the ones where
the *value* cannot exist: see the next section.

## Sorts: two directions, and how each scales

A sort needs **realisation** (every native value has an embedded counterpart,
typed, canonical and injective) and, for quantifiers only, **coverage** (every
embedded value of that sort is the image of a native one). They scale
differently, which is why `SortRealize` and `SortCover` are separate records.

| | realisation | coverage |
| --- | --- | --- |
| needed by | everything | quantifiers |
| adding a sort can break an existing proof? | **no** | **yes** |

Coverage's coupling was measured, not assumed. Proving `boolCover` — nothing but
`SmtValue.Boolean` has type `Bool` — needed shape lemmas about maps, sets,
sequences, and an auxiliary theorem `apply_value_chain` about
datatype-constructor application, none of which is about `Bool`. Those are the
other ways a value could acquire the type, so a new value former with a
permissive typing rule sends someone back to every existing coverage proof.

A sort can also realise without covering. Bridging Lean `Nat` to `SmtType.Int`
realises and does not cover, since negative numerals are no `Nat` — so an
embedded `∀` over `Int` is not a Lean `∀ n : Nat` without a guard. lean-smt
embeds `Nat` this way.

[`generality.md`](generality.md) works this through, and draws the boundary it
sits inside: Logos tracking CPC is assumed, not audited here.

## Where the semantics is narrower than Lean

Logos's [conformance document][conf] records three narrowings of the model
class. They are invisible from the checker's side, and each one lands on the
native-to-model direction this project needs.

| narrowing | effect on a Lean bridge | status |
| --- | --- | --- |
| `Real` is `Rat` | An assignment sending a variable to an irrational has **no** corresponding model. No bridge to Mathlib's `ℝ` is possible against this semantics. A `ℚ`-valued bridge is. | Decision recorded: `ℝ` is excluded, not deferred. |
| uninterpreted sorts are countably infinite | An assignment over an arbitrary Lean type needs an injection into a countable domain. Quantifier-free goals can instead encode only the finitely many elements the assumptions denote, at the cost of a term-indexed rather than environment-indexed bridge. | Deferred; the two constructions are different projects. |
| arrays are almost-constant maps | Only almost-constant Lean functions are realisable. | Deferred. |

[conf]: https://github.com/cvc5/logos/blob/main/docs/smt-lib-conformance.md

## Measurements taken 2026-09-16

Against the revisions above, with a scratch copy of the Logos checkout.
These are facts about builds and runs, not about correspondence.

| measurement | result |
| --- | --- |
| `lake build Cpc.Native` (checker + API, no proofs) | 1 m 59 s wall |
| `lake build Cpc.Proofs.TypePreservation.Nonvacuity` (model existence, full CPC) | 32 s wall, 14 jobs |
| `lake build Cpc.Proofs.TypePreservation.Helpers` | 24 s wall |
| `lake build CpcMini.Proofs.Checker` (Logos's 5-rule playground; not used by this project) | 34 s wall, 40 jobs |
| `lake build logos` (executable) | 1 m 41 s wall, incremental from `Cpc.Native` |
| `#eval!` of `logos_state_is_refutation` on `test-SEQ011_size3` (2244 commands, 1.6 MB script) | 21.07 s wall |
| the same value as `theorem ... := by native_decide` | 20.99 s wall |
| `Instances/check-cpc.sh` (bridge + conditional example, full CPC) | 10 s wall after the Logos build |
| `decide` / `rfl` on any checker run | **stuck**, not slow |
| `Eo` constants compiled by well-founded recursion | 9 of 4784; `__eo_is_closed_rec` is the one on every run's path |
| `native_decide` occurrences inside Logos's own proofs | 604 under `Cpc/`, 8 under `CpcMini/` |
| cvc5 → CPC → `logos` on 12 queries under lean-smt's `defaultSolverOptions` | 12 `correct`, each under 10 ms |
| `scripts/cpc-loc-summary.py`, proof development | 820 files, 691,928 lines (634,322 in rule proofs) |
| vocabulary that the bridge must cover | `SmtTerm` 148 constructors, `SmtType` 15, `SmtValue` 14 |
| vocabulary that costs it nothing | `CRule` 591, `UserOp`+`UserOp1..3` 189 |
| `Cpc/Proofs/Checker.lean` vs `CpcMini/Proofs/Checker.lean` | byte-identical modulo the package name; likewise `TypePreservation/Nonvacuity.lean` |
| CPC rule proofs, partial build | 107 of 591 modules produced **1.6 GB** of oleans, so the full set needs roughly 9 GB and the whole `.lake` around 15 GB |

The last row is why `check-cpc.sh --full` has not been run here: the attempt was
made in a 7.8 GB scratch filesystem and was stopped for memory with 1.3 GB of
disk left, which would not have been enough regardless. It is a capacity fact,
not a result about the proof. `Instances/HermeneiaCpc/Example.lean`'s
`refutation_of_soundness` checks the same three lines against a transcription of
the theorem's statement, so what `--full` would add is confirmation that the
transcription matches.

The reflection and coverage measurements are read in full, with their
consequences, in [`lean-smt.md`](lean-smt.md).

## What the instance has checked

`Instances/check-cpc.sh` checks `no_realizing_model`, `exists_model`,
`boolCover`, `intCover`, `M_wf` and `native_refutation`. No report contains
`sorryAx`.

`no_realizing_model` — the refutation seam, and the whole of what Logos's
conclusion has to be turned into — reports **only** `propext`,
`Classical.choice` and `Quot.sound`: no compiler dependency at all. So do
`boolCover` and `intCover`. `exists_model` and the example inherit two
`native_decide` axioms from Logos's own canonicality proofs, and the example
introduces three of its own (`checked`, and two for `transOk`).

`native_refutation` still carries `eo_satisfiability (argListAssumes F) false` as
a hypothesis. `Instances/HermeneiaCpc/Refutation.lean` discharges it in three
lines with CPC's `correct___eo_is_refutation`; that file has not been checked
here, because it needs the whole proof development.

These fixtures are still not generated from `.eos`, and there is no decidable
supported-fragment predicate — see
[`generality.md`](generality.md#5-the-five-mechanisms-that-keep-it-honest-as-the-semantics-grows).
