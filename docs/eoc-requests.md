# Notes for the eoc developer

What a *template* for Logos-like checkers needs from `ethos-eoc`, and why.

Eudaimonia generates a checker for a calculus that is not CPC. Everything it
knows about the calculus arrives through eoc, so where eoc cannot express a
distinction, the template cannot either — it can only describe it in prose and
hope the reader acts on it. This file is the list of those places.

Each item states the evidence, since several of them look like template
problems until you look at what is emitted.

Companion document: `~/logos/docs/modularity.md`, written from the Logos side.
Where the two overlap it is noted; the two lists agree.

---

## Priority

**Top: item 5, seed the checker layer as templates.**

It is the only item on this list that removes *work* rather than overhead.
Measuring a generated checker by who has to write what:

| | files | lines |
| --- | ----: | ----: |
| generated from the signature | 9 + one per rule | — |
| copied in complete, working | 5 in the package, plus everything outside it | 641 in the package |
| **left for the user to write** | **3, plus the rules** | — |

Those three are `Proofs/RuleSupport/Support.lean`, `Proofs/CheckerCore.lean`
and `Proofs/Checker.lean`. Item 5 moves the last of them — and plausibly the
middle one and `Contract.lean` — out of that column, because
`Cpc/Proofs/Checker.lean` is already byte-identical to `CpcMini`'s modulo the
package name, names no `CRule` and no `UserOp`, and uses three `Term`
constructors. The hard part is done; what is missing is that it is
hand-maintained per package instead of seeded.

It also does not wait on item 6. Stabilizing the SMT-LIB model is what would
make this *library* reuse; seeding makes it *template* reuse, which is exactly
what byte-identity across two packages already buys. Sequencing item 6 first
would be right if the goal were sharing compiled proofs, and wrong if the goal
is that a new checker starts with fewer blank files.

Then, in order:

2. **Item 1 — conditional datatype emission.** Now backed by a measurement
   rather than an argument: 15% of the smallest possible calculus is machinery
   it cannot use, and the mechanism to trim it shipped in 1b.
3. **Item 2 — `--calc-name` and `--smt-semantics` on `main`.** Not a capability
   request; a release one. Until it lands, every generated checker pins a
   development branch and cannot honestly claim a reproducible build.
4. **Item 3 — the premise-list nil diagnostic.** Small, and it turns a silently
   broken package into one sentence.
5. **Item 6 — stabilize the SMT-LIB model.** Still the biggest lever on total
   cost, and still the right thing to do before anyone tries to share theory
   proofs between two checkers. It is below the others here only because it is
   the largest and unblocks nothing that is currently blocking.
6. **Item 4 — generated `cmdTranslationOk`.** Worth doing when a second
   consumer actually hits the hand-maintained table; Eudaimonia seeds the
   generic version and has not yet.

---

## 1. Emit feature machinery conditionally

**The ask:** let what eoc emits depend on what the signature actually uses.

**Evidence.** `plugins/lean_meta/lean_meta_checker_term.lean` is a fixed
template. It declares

```lean
inductive Term : Type where …
inductive DatatypeDecl : Type where
  | nil : DatatypeDecl
  | cons : native_String -> Datatype -> DatatypeDecl -> DatatypeDecl
```

unconditionally — `DatatypeDecl`, `Datatype` and `DatatypeCons` are written out
with literal constructors, not behind a placeholder — and they appear again in
the fixed `lean_meta_smt_model_defs.lean`, `lean_meta_smt_value_order.lean` and
`lean_meta_parser.lean`.

To be precise about what is and is not conditional: `Term`'s own constructor
list *is* a placeholder (`$LEAN_TERM_DEF$`), so whether `Term.DatatypeType` is
emitted for a datatype-free signature is untested here — there was no such
signature to hand. The three support inductives above are unconditional
regardless, and so is everything downstream that matches on them.

Roughly 330 lines of a generated CPC package mention datatypes:

| module | lines mentioning datatypes | of |
| ------ | -------------------------: | -: |
| `Logos.lean` | 140 | 10,488 |
| `SmtModel.lean` | 85 | 2,183 |
| `Parser.lean` | 31 | 2,047 |
| `Spec.lean` | 31 | 472 |
| `SmtModelDefs.lean` | 17 | 294 |
| `LogosTerm.lean` | 16 | 309 |
| `SmtValueOrder.lean` | 11 | 153 |

**Why it matters more than the line count.** The generated lines are cheap; what
is not cheap is that they must be *reasoned about*. A calculus with no datatypes
still gets datatype cases in `__eo_to_smt` and `__smtx_typeof`, and so still owes
translation and type-preservation proofs for them — in a layer that is already
the dominant cost (93,530 lines against a 4,474-line checker layer in Cpc; see
`modularity.md` TODO 5).

**Shape of the fix.** Key emission on what the signature declares — which is
exactly what item 1b now does for indexed operators, so the mechanism exists and
the question is what else to point it at. Datatypes are the clearest remaining
case: `declare-datatypes` is present or it is not. Then binder machinery
(`Term.Var`, closedness), and plausibly whole theories.

**Measured, no longer guessed.** `examples/hello` in Eudaimonia is a
datatype-free signature with no literals beyond `Bool` — three declared
constants and one rule. There was no such signature when this was first
written, so `Term`'s constructor list could only be guessed at. Compiling it
settles it:

| constructor | in Hello's term module | Hello's signature declares it |
| ----------- | ---------------------: | ----------------------------- |
| `DatatypeType`, `DtCons`, `DtSel` | present | no |
| `DatatypeDecl` | present | no |
| `Numeral`, `Rational`, `Binary` | present | no |

**370 of Hello's 2,395 generated lines — 15% — are datatype or literal
machinery for a calculus that has neither.** Item 1b shows the mechanism to fix
this exists; it is simply not pointed here yet.

**What the template already does.** `install/defs/profile.conf` in a generated
checker records the answers, including `PROFILE_DATATYPES` and
`PROFILE_BINDERS`. They are marked *declared* rather than *derived*, precisely
because nothing in the emitted output distinguishes them today. If eoc gains
conditional emission, those keys are what a generated checker would key on, and
they become derivable at the same moment.

## 1b. Indexed operators — **done** (ethosEoc3, 2026-08-30)

`UserOp<n>` and the matching `Term.UOp<n>` are now emitted only for an arity the
signature uses. Verified here:

| package | indexed arities used | `UserOp1/2/3` | `LogosTerm.lean` | `UOp1/2/3` mentions in the core |
| ------- | -------------------: | ------------- | ---------------: | ------------------------------: |
| `Cpc` | 3 | 14 / 4 / 2 | 305 | 260 |
| `CpcMini` | 0 | **absent** | 105 | **0** |
| `Hello` | 0 | **absent** | 99 | **0** |

Two things worth recording about the shape of the fix:

- **It keys on the compiled rule set, not just the signature.** `CpcMini` is
  CPC's own signature reduced to five rules, and it now sheds all three arities.
  That is the more useful behaviour and not the obvious one.
- **Absence is the signal.** The placeholder `| None` constructor is gone, so a
  consumer reads the answer off which enums exist. Eudaimonia's `indexed-ops`
  profile check was updated accordingly, and still tolerates a placeholder if it
  meets one.

This is the first item on this list to land, and it is the proof that the list
is worth keeping: the request was written from measurements, and the fix
matched them.

## 2. Put `--calc-name` and `--smt-semantics` on `main`

**The ask:** these two options are what make a template possible rather than a
fork of Logos, and they exist only on the `ethosEoc3` branch.

- `--calc-name` — what the generated Lean calls the calculus. Without it the
  name comes from the signature's file name, so the calculus name stops being
  the user's to choose.
- `--smt-semantics` — the SMT-LIB semantics the calculus is read against, which
  is one of the three files a specification consists of.

**Evidence.** `main`'s `tools/eoc/driver.py` has `--semantics` but neither of
the above; `ethosEoc3` has both. So a template must pin to a development branch
whose head moves, and does — Eudaimonia pins a commit and says why in
`install/get-eo-compiler.sh`. Logos carries the same workaround and the same
TODO.

## 3. Diagnose a premise-list operator with no nil

**The ask:** eoc knows both halves of this and could say so; today it emits
silently broken code.

**Evidence.** Compile CPC with `and` declared `(-> Bool Bool Bool)` instead of
`(-> Bool Bool Bool) :right-assoc-nil true`. The compiler succeeds, and the
output contains

- **11** call sites of `__eo_mk_premise_list (Term.UOp UserOp.and)`, emitted for
  the rules that gather `:list` premises with `and`; and
- **0** arms of `__eo_nil` for `and`, because the arm exists only by virtue of
  the attribute.

Every one of those rules goes `Stuck` at run time. Nothing warns.

Eudaimonia checks for this after the fact, by grepping emitted Lean for the
mismatch. That works but is the wrong place: eoc has both facts in hand while it
is emitting.

Worth noting what this is *not*: the attribute is not a core requirement.
With plain binary `and`, `__eo_invoke_assume_list`, the refutation test and the
SMT translation are all unchanged — the checker core never uses the nil. Only
`:list`-premise rules do. So the diagnostic is conditional, not a blanket
requirement that `and` carry a nil.

## 4. Generate `cmdTranslationOk` per rule

Same as `modularity.md` TODO 1, seen from this side. `Cpc/Proofs/Assumptions.lean`
is a 257-line hand-maintained table naming 32 rules, and it is the only
hand-written non-rule file in Logos that mentions a rule — while appearing in
the hypothesis of the top-level soundness theorem.

Eudaimonia seeds a generated checker from `CpcMini`'s generic 44-line version
instead, whose `cmdTranslationOk` names no rule. That is the right default, and
it will stop being sufficient the moment a rule needs a stronger condition —
which is discovered while proving the rule, so it has to be *declared in the
rule file* rather than derived from the signature.

If the rule stub template emitted
`def cmd_step_<rule>_args_ok : CArgList → Prop := fun _ => True` and eoc
generated the dispatch, a generated checker would never need to hand-maintain
that table at all.

## 5. Seed the checker layer as templates

`modularity.md` TODO 2. From this side it is the missing third file category.

A generated project sorts its files into **G** (generated, overwritten on
reinstall) and **H** (hand-written, preserved). What the checker layer wants is
a third: files a project *inherits* — installed once, preserved thereafter,
never written by hand. That is exactly the treatment `Proofs/Rules/*.lean`
already gets.

`Cpc/Proofs/Checker.lean` is byte-identical to `CpcMini`'s modulo the package
name (verified), names no `CRule` and no `UserOp`, and uses three `Term`
constructors. It is ready to be seeded. `CheckerState.lean`,
`RuleSupport/Contract.lean` and a generic `Assumptions.lean` are the rest of the
set.

Until then, a generated checker ships those as stubs describing what belongs in
them, which is a poor substitute for shipping the thing itself.

## 6. Stabilize the SMT-LIB model

`modularity.md` TODO 5, and the item both sides rate highest.

**Evidence from this side.** Compilation *configures* the model. `CpcMini` and
`Cpc` compile from the same signature and differ only in rule count, yet:

| module | CpcMini | Cpc |
| ------ | ------: | --: |
| `SmtModel.lean` | 743 | 2,186 |
| `Spec.lean` | 105 | 475 |
| `SmtModelDefs.lean` | 171 | 297 |
| `LogosTerm.lean` | 135 | 312 |
| `SmtEval.lean` | 74 | 175 |
| `SmtValueOrder.lean` | 156 | 156 |

Only `SmtValueOrder` is invariant. So a proof file that never names an operator
is still *stated about* an `SmtModel` that varies with the signature, and
byte-identity between packages buys **template** reuse rather than library
reuse: the same text about two different types.

`SmtModel.lean` is a formalization of SMT-LIB, not of any calculus. A shared
library with per-package pruning as an optimization is what would let two
checkers share the theory proofs — and it is the precondition for items 1 and 5
paying off, so it sequences first.

---

---

## Cross-reference

`~/logos/docs/modularity.md` reaches compatible conclusions from the Logos side,
and its TODO 8 asked for a signature-contract check. Eudaimonia implements that
in `install/install-<calc>.sh`, including the two seams that document records as
unchecked — the nil attribute and the translation of `and` — both of which turn
out to be greppable in emitted Lean. Item 3 above is the request to move that
check upstream, where it belongs.
