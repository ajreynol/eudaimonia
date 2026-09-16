# Initial correspondence ledger

Inspected 2026-09-16. These are source findings and planned proof obligations,
**not certified coverage**. What has been compiled is the generic interface, its
synthetic checks, and one instance — CpcMini, one Boolean constant — whose rows
below say so explicitly. Everything else is a reading of source. This
distinction persists even when a proposed concrete proof looks as simple as
`rfl`.

| subject | observed embedded meaning / Lean target | obligation or boundary | status |
| --- | --- | --- | --- |
| Integer carrier | `native_Int` abbreviates Lean `Int`. | Fix the carrier and faithful `SmtValue.Numeral` encoding; prove typing and model-required canonicality. | Source inspected; adapter open. |
| `Term.Numeral n` | Translation to `SmtTerm.Numeral n`, evaluation to `SmtValue.Numeral n`. | Universal signed-integer literal theorem through both stages. | Source inspected; generic law checked, actual instance open. |
| Boolean literals | `SmtValue.Boolean b`; native `Bool`, then proposition `b = true`. | Literal, typing and proposition laws. | Typing and canonicality of `SmtValue.Boolean b` proved `rfl` in the CpcMini instance; the general literal law is open. |
| Boolean constants | `Term.UConst n Term.Bool` translates to `SmtTerm.UConst "@u.<n>" SmtType.Bool`; lookup is `M.values (model_key ...)`. | Every native assignment extends to a globally well-formed model. | **Proved for CpcMini, one constant.** The construction overrides Logos's own `default_typed_model` at one key; `model_fun_wf` is untouched by an override, and the two remaining conjuncts reduce to typing and canonicality of the substituted value. Generalising to finitely many keys is mechanical; `Term.Var` (bound variables) is untouched. |
| `not`, `and` | Boolean helpers use native `Bool.not` and `&&`. | Calculus translation, recursive evaluation and equivalence with `¬`, `∧`. | Computed, not proved generally: the CpcMini instance evaluates one fixed `and`/`not`/terminal-`true` chain. The inductive law over arbitrary terms is open. |
| Integer `+` | `smt.eos` selects `zplus` for numeral values; native implementation uses Lean addition. | Typed integer overload, local value law and term composition. | Open. |
| Integer equality/order | Boolean-valued comparison of integer payloads. | Tie equality to the faithful representation; compare to the Lean proposition via `= true`. | Open. |
| `div_total`, `mod_total` | Native helpers use Lean integer `/` and `%`. | Fix these particular helpers; prove their value and term laws. | Source inspected; excluded initially. |
| Public `div`, `mod` | At zero divisor the SMT semantics calls model-chosen functions. | Use a nonzero-divisor condition, constrain model choices with realizability proved, or carry these choices in the native interpretation. Unconditional native `/` and `%` are not justified for arbitrary models. | Boundary identified; excluded initially. |
| `Real` | Generated rational payload is Lean `Rat` in the inspected source. | Do not equate the sort name with Lean mathematical reals; choose and justify coverage. | **Decided: no `ℝ` bridge.** See [below](#where-the-semantics-is-narrower-than-lean) — the narrowing makes an `ℝ`-valued assignment unrealisable, not merely unproved. |
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
| Logos build used by `Instances/CpcMini` | a scratch copy of `be4791204be5616df2bf6f42ea304b45b08d33e1` |
| cvc5 used for the coverage probe | `1.3.5.dev+HEAD@c17a2d05ff` |
| lean-smt read (not built) | `ufmg-smite/lean-smt@5bdc51674065a074ece67b04e10024e9f426ec1f` |
| lean-cvc5 read (not built) | `abdoo8080/lean-cvc5@7e3365990661b697ccb30e92d6912f4cc6589322` |

Relevant declarations at those revisions:

- Eudaimonia `examples/hello/smt.eos`: `define-sort Int`, the value constructor
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
- Logos `CpcMini/Proofs/Checker.lean`: `correct___eo_is_refutation`;
  `CpcMini/Proofs/TypePreservation/Nonvacuity.lean`: `default_typed_model` and
  `default_typed_model_total_typed`.

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

Logos proves models exist. `CpcMini/Proofs/TypePreservation/Nonvacuity.lean`
(and its `Cpc/` counterpart, read but not built here) defines
`default_typed_model`, which assigns every well-formed SMT type a canonical
inhabitant, and proves `default_typed_model_total_typed : model_wf
default_typed_model`. Realising a native assignment is then an **override** at
the finitely many keys the checked assumptions mention:

- `model_fun_wf` constrains only `nativeFuns`, which an override leaves alone,
  so it transfers unchanged;
- the other two conjuncts of `model_wf` reduce, at the overridden key, to the
  typing and canonicality of the substituted value at that key's type — which is
  what a `SortBridge` already has to supply.

`Instances/CpcMini/Refutation.lean` proves `model_wf_override` in that form. The
sorts where this stops working are not the ones where the construction is hard
but the ones where the *value* cannot exist: see the next section.

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
| `lake build CpcMini.Proofs.Checker` (5-rule soundness) | 34 s wall, 40 jobs |
| `lake build logos` (executable) | 1 m 41 s wall, incremental from `Cpc.Native` |
| `#eval!` of `logos_state_is_refutation` on `test-SEQ011_size3` (2244 commands, 1.6 MB script) | 21.07 s wall |
| the same value as `theorem ... := by native_decide` | 20.99 s wall |
| `Instances/CpcMini/Refutation.lean` end to end | 0.77 s wall |
| `decide` / `rfl` on any checker run | **stuck**, not slow |
| `Eo` constants compiled by well-founded recursion | 9 of 4784; `__eo_is_closed_rec` is the one on every run's path |
| `native_decide` occurrences inside Logos's own proofs | 604 under `Cpc/`, 8 under `CpcMini/` |
| cvc5 → CPC → `logos` on 12 queries under lean-smt's `defaultSolverOptions` | 12 `correct`, each under 10 ms |
| `scripts/cpc-loc-summary.py`, proof development | 820 files, 691,928 lines (634,322 in rule proofs) |

The reflection and coverage measurements are read in full, with their
consequences, in [`lean-smt.md`](lean-smt.md).

## What the instance has checked

`Instances/CpcMini/check.sh` checks `unsat`, `M_wf`, `denote` and
`native_refutation`. No report contains `sorryAx`. Every `native_decide` axiom in
those reports is either one of the four the instance itself introduces
(`checked`, two for `transOk`, `translated`) or one inherited from Logos's own
proofs. The theorem `native_refutation` carries no open soundness hypothesis:
CpcMini's `correct___eo_is_refutation` is proved, not assumed.

These fixtures are still not generated from `.eos`, and the instance is CpcMini,
not `Cpc`.
