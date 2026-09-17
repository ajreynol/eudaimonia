# Boolean gates

Worked files for [Extending theories](../../docs/extending-theories.md): add
NAND and NOR as a small theory over the existing Boolean semantic domain.

| File | Purpose |
| --- | --- |
| [`gates.eo`](gates.eo) | Entry point, including the theory and rule files |
| [`theories/BooleanGates.eo`](theories/BooleanGates.eo) | Boolean vocabulary and the two new gate symbols |
| [`rules/BooleanGates.eo`](rules/BooleanGates.eo) | Gate expansion rules and contradiction |
| [`Gates.eos`](Gates.eos) | Translate gates to existing SMT Boolean operators |
| [`Semantics.lean`](Semantics.lean) | Six checked lemmas about the generated translations and Boolean values |
| [`check.py`](check.py) | Check proof outcomes and diagnostics in Ethos and the generated checker |

The [tutorial commands](../../docs/extending-theories.md#5-compile-and-inspect-the-result)
generate and build a checker outside this repository. The unchanged target
semantics comes from Eudaimonia's `examples/hello/smt.eos`; it is not duplicated
here. The example uses compiler pin
`8dc85c4db8d6cc612f02dc3bb627331732605eff` and Lean 4.33.0.

Once the example checker is built:

```bash
python3 check.py /path/to/ethos /path/to/TheoryDemo/.lake/build/bin/theorydemo
```

Run the Lean checks from the generated `TheoryDemo` directory:

```bash
lake env lean /path/to/this/example/Semantics.lean
```

| Proof | Expected outcome |
| --- | --- |
| [`nand.cpc`](test/nand.cpc) | `correct`, exit 0 in both checkers |
| [`nor.cpc`](test/nor.cpc) | `correct`, exit 0 in both checkers |
| [`wrong-conclusion.cpc`](test/wrong-conclusion.cpc) | Ethos rejects the claimed gate expansion; the generated checker uses the computed conclusion and rejects the subsequent contradiction step |
| [`wrong-type.cpc`](test/wrong-type.cpc) | Ethos rejects the argument type; the generated checker rejects the ill-typed assumption |

Checked on 2026-09-17: both tools were built from the pin above, all eight
proof runs had the expected outcome, and the six Lean lemmas compiled without
`sorryAx`. The generated executable built and its regeneration comparison
passed. This is **not a verified checker**: its generated rule proofs and
checker obligations remain open. No new semantic type or value domain was
implemented; the example reuses Boolean semantics.
