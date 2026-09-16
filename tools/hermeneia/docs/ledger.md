# Initial correspondence ledger

Inspected 2026-09-16. These are source findings and planned proof obligations,
**not certified coverage**. Only the generic interface and synthetic checks in
this child have been compiled. This distinction persists even when a proposed
concrete proof looks as simple as `rfl`.

| subject | observed embedded meaning / Lean target | obligation or boundary | status |
| --- | --- | --- | --- |
| Integer carrier | `native_Int` abbreviates Lean `Int`. | Fix the carrier and faithful `SmtValue.Numeral` encoding; prove typing and model-required canonicality. | Source inspected; adapter open. |
| `Term.Numeral n` | Translation to `SmtTerm.Numeral n`, evaluation to `SmtValue.Numeral n`. | Universal signed-integer literal theorem through both stages. | Source inspected; generic law checked, actual instance open. |
| Boolean literals | `SmtValue.Boolean b`; native `Bool`, then proposition `b = true`. | Literal, typing and proposition laws. | Open. |
| Boolean variables | Lookup depends on typed variable identity and model. | Every native assignment extends to a globally well-formed model. | Open. |
| `not`, `and` | Boolean helpers use native `Bool.not` and `&&`. | Calculus translation, recursive evaluation and equivalence with `¬`, `∧`. | Open. |
| Integer `+` | `smt.eos` selects `zplus` for numeral values; native implementation uses Lean addition. | Typed integer overload, local value law and term composition. | Open. |
| Integer equality/order | Boolean-valued comparison of integer payloads. | Tie equality to the faithful representation; compare to the Lean proposition via `= true`. | Open. |
| `div_total`, `mod_total` | Native helpers use Lean integer `/` and `%`. | Fix these particular helpers; prove their value and term laws. | Source inspected; excluded initially. |
| Public `div`, `mod` | At zero divisor the SMT semantics calls model-chosen functions. | Use a nonzero-divisor condition, constrain model choices with realizability proved, or carry these choices in the native interpretation. Unconditional native `/` and `%` are not justified for arbitrary models. | Boundary identified; excluded initially. |
| `Real` | Generated rational payload is Lean `Rat` in the inspected source. | Do not equate the sort name with Lean mathematical reals; choose and justify coverage. | Representation decision deferred. |
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
