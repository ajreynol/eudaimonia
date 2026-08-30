# Limitations

What a generated checker does not yet do, and why. Measured rather than
guessed: `scripts/run-ci.sh` generates a checker for each option configuration
and runs that project's own CI, so what is here is what that suite cannot make
pass.

Smaller known rough edges live in [TODO.md](../TODO.md#7-rough-edges).

## Nothing is proven yet

A generated checker ships **compiling**, not proven. Every module builds; the
outstanding work is `sorry`, and `scripts/rule-status.sh` and
`scripts/run-ci.sh hygiene` report it. A verdict of `correct` means *the checks
passed*, not *this has been proven*.

Two files are **stubs** — they compile, have no `sorry` of their own, and are
nonetheless placeholders:

| file | what it stubs |
| ---- | ------------- |
| `Proofs/RuleSupport/Support.lean` | the eight names every rule statement is written against |
| `Proofs/CheckerCore.lean` | the sixteen the generated dispatcher is written against |

Both follow the same discipline. The **hypotheses** a proof is *given* are
defined for real, so no statement is vacuously true. The **obligations** it must
*establish* are empty propositions, so nothing closes them by accident: a rule
can only be discharged with `sorry`, and the dispatcher cannot come out looking
proven while resting on nothing. Defining the obligations as `True` instead
would let a checker report 591 rules proven having proven nothing.

`CheckerCore.lean` goes one step further and is worth understanding before
starting on it: its invariants are `True`, which keeps the dispatcher's
hypotheses satisfiable but means several of its bridge lemmas are not merely
unproven but **false as stated**. `premiseTermList_has_bool_type` says every
premise is well-typed, and nothing currently guarantees that. Read them as the
specification of what the invariants will have to deliver once they have
content. Giving them content is the first thing to do in that file.

## The rule dispatcher is excluded from `modules`

`Proofs/RuleLemmas.lean` is the one module the generated `modules` CI group does
not build, and the reason is now a single upstream codegen bug rather than
anything missing in the template.

The compiler emits a catch-all branch in its `cases` over the rule enum:

```lean
  cases r with
  | contra => ...
  -- Every rule unsupported by plain `step` reduces definitionally to `Stuck`.
  | _ =>
      exact False.elim (hProg rfl)
```

It emits that branch unconditionally. When every rule of the calculus is a plain
`step` rule, the enum is already exhausted and Lean rejects the wildcard —
`Wildcard alternative is not needed`. It is an error rather than a lint, so
there is no option that suppresses it.

So the dispatcher compiles for a calculus with at least one rule the plain
`step` path does not handle, and fails for one whose rules are all plain `step`
rules. Since a starter calculus is usually the latter, the exclusion stays until
the branch is emitted conditionally.

**This is not the checker layer being missing.** `Proofs/CheckerCore.lean`
supplies all sixteen names the dispatcher needs, and where the wildcard is
legitimate the whole chain builds — dispatcher, `Proofs/Checker.lean`, and
`ApiCorrect`. The framework CI verifies exactly that on the `Scoped`
configuration every run, so the layer cannot silently rot.

Emitting the branch conditionally is a small, local change, filed with the rest
in [eoc-requests.md](eoc-requests.md).

## Seeding the checker layer is still worth doing

`CheckerCore.lean` is a stub, and the interface it fills is fixed by the
compiler rather than by your calculus — sixteen names, and a calculus without
`step_pop` rules needs a subset of the same set. The compiler generates a file
that *uses* that vocabulary while generating nothing that *defines* it.

In Logos the corresponding file is 1,123 lines, and `Proofs/Checker.lean` — the
soundness proof it feeds — is byte-identical between a 591-rule package and a
5-rule one. Neither is calculus-specific. Seeding them is
[item 5](eoc-requests.md) of the wish list and the top priority there: it is the
one item that removes work rather than overhead.

## The compiler is pinned to a development branch

`ethosEoc3`, not `main`, which lacks `--calc-name` and `--smt-semantics` — the
two options that make the calculus name and the SMT-LIB semantics the user's to
choose. Builds are reproducible; the branch is not a released one.

The commit is not the whole pin. `install/defs/smt.eos` is a snapshot of that
commit's semantics, and the format is still changing, so the two move together —
`scripts/bump-eoc.sh` advances both, and `.github/workflows/smt-drift.yml` runs
weekly and says when the branch has moved ahead.

Keeping the pin current is deliberately manual. Taking an update can invalidate
what is shipped proven, and that wants judgement rather than a bot.
