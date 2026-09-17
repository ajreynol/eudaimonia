# CPC theory examples

Worked proofs for [Extending CPC theories](../../docs/extending-theories.md),
using cvc5's existing `int.pow2` operator and expert finite-field theory.
These fixtures load cvc5's signatures directly.

Run with an Ethos binary and the root of a complete cvc5 checkout:

```bash
python3 check.py /path/to/ethos /path/to/cvc5
```

[`check.py`](check.py) checks the exit status and verdict or expected diagnostic
for five runs. Positive proofs must derive `false`; negative tests must fail
for the stated reason.

| Proof | Signature | Expected outcome |
| --- | --- | --- |
| [`int-pow2.cpc`](test/int-pow2.cpc) | `Cpc.eo` | `evaluate` proves `(= (int.pow2 3) 8)`, yielding a refutation |
| [`int-pow2-wrong-type.cpc`](test/int-pow2-wrong-type.cpc) | `Cpc.eo` | Type error for a Boolean argument to `int.pow2` |
| [`finite-fields.cpc`](test/finite-fields.cpc) | `Cpc.eo` only | `FiniteField` is undeclared |
| Same finite-field proof | `Cpc.eo` and `expert/CpcExpert.eo` | `aci_norm_expert` proves commutativity of addition, yielding a refutation |
| [`finite-fields-wrong-type.cpc`](test/finite-fields-wrong-type.cpc) | Main and expert | Type error when adding elements of different fields |

The [tutorial commands](../../docs/extending-theories.md#5-check-the-main-and-expert-signatures-separately)
also show the individual Ethos invocations. The explicit main-only check
matters: cvc5's `cpc_gen.sh` helper includes both signatures by default.

All five runs passed on 2026-09-17 with cvc5 signature revision
`2900761a7c2e2c0e99e2cf669cffa3740ea9a138` and Ethos built from
`8dc85c4db8d6cc612f02dc3bb627331732605eff`, cvc5's checker pin at that revision.
These are hand-written proof tests, not proofs emitted by a solver build.
No Logos generation or Lean proof was run for this example, and the finite-field
example does not add that expert theory to Logos's main-signature compilation.
