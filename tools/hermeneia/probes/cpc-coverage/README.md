# Probe: does Logos check what lean-smt's solver configuration produces?

**The question.** A baseline reconstruction ([`docs/lean-smt.md`](../../docs/lean-smt.md))
only exists if the CPC proofs cvc5 emits *under lean-smt's own options* are ones
Logos accepts. The option most likely to matter is
`proof-granularity=dsl-rewrite`, which lean-smt sets and which changes what
rules appear.

**What this is not.** Twelve small queries are a sanity check, not a coverage
measurement. The measurement is lean-smt's own test suite, run the same way;
that is L0 of the plan in `lean-smt.md`, and it needs no Lean.

## Running it

```bash
probes/cpc-coverage/run.sh <cvc5-binary> <logos-binary>
```

`run.sh` carries lean-smt's `defaultSolverOptions` (`Smt/Reconstruct.lean`) as
command-line flags; keep the two in step when lean-smt changes them. It writes
only into a temporary directory it removes. Point the third argument at another
directory to run it over different queries.

## Result recorded 2026-09-16

cvc5 `1.3.5.dev+HEAD@c17a2d05ff`, `logos` built from
`be4791204be5616df2bf6f42ea304b45b08d33e1`: **12 of 12 `correct`**, each in under
10 ms.

| query | theory | steps |
| --- | --- | --- |
| `01-prop` | propositional | 4 |
| `02-uf` | UF, via `scope`/`process_scope` | 9 |
| `03-lia` | LIA | 56 |
| `04-lia2` | LIA | 174 |
| `05-quant` | quantifiers | 34 |
| `06-lra` | LRA | 53 |
| `07-bv` | bit-vectors | 6 |
| `08-mixed` | UF over `Int` | 5 |
| `09-dt` | datatypes | 22 |
| `10-str` | strings | 24 |
| `11-natish` | LIA, non-negative | 51 |
| `12-arr` | arrays | 9 |

A `correct` here says the assumptions of that CPC proof are unsatisfiable in
Logos's semantics. It says nothing about whether those assumptions are the Lean
goal anyone started from — that is the obligation
[`docs/lean-smt.md`](../../docs/lean-smt.md) states in §5.3, and no solver or
checker verdict can discharge it.
