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

**Top: item 4b, the dispatcher's catch-all branch.** It is a few lines, and it
is the only thing keeping `Proofs/RuleLemmas.lean` out of a generated checker's
CI now that `Proofs/CheckerCore.lean` supplies the sixteen names it needs.

**Then item 5, seed the checker layer as templates** — and within it, the one
small change that unblocks the rest: make `Checker.lean` take its two
rule-bridge theorems as hypotheses instead of importing `RuleLemmas`. Four call
sites, 1,063 lines, and it is what stands between a generated checker and a
soundness proof it does not have to write.

It is the only item on this list that removes *work* rather than overhead.
Measuring a generated checker by who has to write what:

| | files | lines |
| --- | ----: | ----: |
| generated from the signature | 9 + one per rule | — |
| copied in complete, working | 5 in the package, plus everything outside it | 651 in the package |
| **left for the user** | **6, plus the rules** | — |

Those six are `Proofs/{TypePreservation, TranslationTypePreservation, NonVacuity,
Canonicity}.lean`, `Proofs/RuleSupport/Support.lean` and
`Proofs/CheckerCore.lean`. A seventh, `Proofs/Checker.lean`, carries a `sorry`
but should not: it is what item 5 would remove, because
`Cpc/Proofs/Checker.lean` is already byte-identical to `CpcMini`'s modulo the
package name, names no `CRule` and no `UserOp`, and uses three `Term`
constructors. The hard part is done; what is missing is that it is
hand-maintained per package instead of seeded.

`Proofs/CheckerCore.lean` is the likely second: its differences from CpcMini's
are simp-lemma lists and one namespace qualifier — drift between two
hand-maintained copies rather than calculus-specific content.

Of the four front-end theorems, only `TranslationTypePreservation` is
unconditionally the user's; the rest could arrive proven while the SMT-LIB
semantics is the stock one. See
[the Logos experience report](logos-experience-report.md).

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
7. **Item 7 — state the conclusion over the assumption list.** The last of the
   `and` dependency, and the only item that would empty the signature contract
   rather than shorten it. Last because it is speculative until someone scopes
   what it does to `Common.lean`, not because it is unimportant: it is what
   would let a calculus declare no operators at all.

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

## 1c. The input assumption format — **done** (Logos #459, 2026-08-31)

`__eo_invoke_assume_list` took a proof's assumptions as an `and`-chain
terminated by `true`, with a catch-all sending anything else to `Stuck`. It now
takes a `CArgList`:

```lean
def __eo_invoke_assume_list (S : CState) : CArgList -> CState
  | CArgList.nil => S
  | (CArgList.cons F as) => (__eo_push_input_assume_check ... F (__eo_invoke_assume_list S as))
```

`eo_is_refutation` and `__eo_checker_is_refutation` are retyped with it. What it
buys a template, in order of how much it matters here:

- **Running a proof no longer touches the signature.** Assumptions in as a
  `CArgList`, commands in as a `CCmdList`, both structural. The contract's reach
  shrinks from *performing* a run to *stating* what one establishes.
- **`ValidAssumptionList` is gone** — the predicate, its two derivation
  theorems, and the hypothesis they were threaded through. 64 lines off
  `CheckerState.lean` per package, in exactly the layer item 5 wants seeded.
- **`TranslatableAssumptionList` collapses** to an `abbrev` for
  `cArgListTranslationOk`: input assumptions and a rule's arguments are the same
  shape, so one predicate serves both.
- **The malformed-input case goes with it.** There is no longer a `Stuck` arm
  for an input that is not an `and`-chain, because there is no longer a shape to
  get wrong.

**What it does not do.** `and` is still assumed. `argListAssumes`
(`Proofs/Assumptions.lean`) folds the list into the conjunction the conclusion is
about, and `stateAssumes` / `statePushes` / `stateProvens` still fold the proof
stack with it. Both signature-contract checks stand unchanged, and
`modularity.md` still lists `and` under hard-coded symbols. Item 7 is what would
finish the job.

Adopted here by bumping the pin to `406b5499`, which is what Logos main carries.

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
With plain binary `and`, the input assumption list, the refutation test and the
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

## 4b. Emit the dispatcher's catch-all branch conditionally

**Small, local, and the only thing keeping `Proofs/RuleLemmas.lean` out of a
generated checker's CI.**

`RuleLemmas.lean` dispatches over the rule enum and closes with a wildcard:

```lean
  cases r with
  | contra => ...
  -- Every rule unsupported by plain `step` reduces definitionally to `Stuck`.
  | _ =>
      exact False.elim (hProg rfl)
```

The branch is emitted unconditionally. When every rule of the calculus is a
plain `step` rule the enum is already exhausted, and Lean rejects it:

```
error: Wildcard alternative is not needed
```

It is an error from the `cases` elaborator rather than a lint, so nothing on the
consumer side suppresses it — `set_option match.ignoreUnusedAlts true` does not
apply.

**The fix:** emit the wildcard only when the `cases` does not already cover
every constructor — that is, when at least one rule is not handled by the arm
being generated. Both dispatchers need it (`step` and `step_pop`).

This bites exactly the calculi most likely to be someone's first: a starter
signature whose rules are all plain `step` rules. A calculus with a `step_pop`
rule compiles today, which is what Eudaimonia's CI uses to keep the checker
layer honest.

## 5. Seed the checker layer as templates

`modularity.md` TODO 2. From this side it is the missing third file category: a
generated project sorts files into **G** (generated, overwritten) and **F**
(copied in complete). The checker layer wants to be F and is not.

`Cpc/Proofs/Checker.lean` is byte-identical to `CpcMini`'s modulo the package
name, names no `CRule` and no `UserOp`, and uses three `Term` constructors. It
is ready to be seeded. `CheckerState.lean`, `RuleSupport/Contract.lean` and a
generic `Assumptions.lean` are the rest of the set.

### The rule seam is already calculus-independent — measured

The compiler emits every rule proof against a fixed vocabulary of **eight
names**, and nothing else:

    AllHaveBoolType   AllHaveSmtTranslation   AllTypeofBool   cmdTranslationOk
    premiseTermList   RuleProofs.eo_has_smt_translation
    StepRuleProperties   StepPopRuleProperties

Across **595 generated rule files in three calculi** — CPC's 591, plus a
3-rule and a 1-rule signature — the statements collapse to exactly **two
shapes**, byte-identical apart from the rule's own constructor name: one for
`step`, one for `step_pop`. Nothing in a rule statement varies with the
calculus.

So `RuleSupport/Contract.lean` is not merely *a* candidate for seeding — the
compiler already fixes its entire interface, and every consumer of it is
generated by the compiler too. Eudaimonia currently ships a stub
(`templates/pkg/Proofs/RuleSupport/Support.lean.in`) that defines the
hypotheses for real and leaves the two obligations as an **empty proposition**,
so rule files compile while remaining impossible to close except with `sorry`.
That is enough to build rules, but the shape of the obligation is a decision the
compiler is really the one making.

### What `RuleLemmas.lean` needs, and does not get

The dispatcher is generated *with its proof bodies*, and those bodies reference
a checker layer that no generated file defines:

| needed by `RuleLemmas.lean` | kind |
| --- | --- |
| `checkerTypeInvariant`, `checkerTranslationInvariant`, `checkerLocalTruthInvariant`, `checkerAssumptionStabilityInvariant` | state invariants |
| `CmdStepFacts`, `stateStepPopSuffix` | the dispatcher's own vocabulary |
| `premiseTermList_has_{bool_type, smt_translation, typeof_bool}` | 3 bridge lemmas |
| `cmd_step{,_pop}_facts_of_rule_properties` | 2 bridge lemmas |
| `checker{Type,Translation}Invariant_head_assume_push` | 2 invariant-maintenance lemmas |
| `checker{Type,Translation}Invariant_of_stateStepPopSuffix` | 2 invariant-maintenance lemmas |
| `term_ne_stuck_of_typeof_bool` | in Logos, part of `Contract.lean` |

In Logos these live in `Proofs/CheckerCore.lean` (1,123 lines; 246 lines of diff
between Cpc and CpcMini) and `RuleSupport/Contract.lean`. A generated checker
gets neither, so `RuleLemmas.lean` cannot compile no matter how its rules are
stubbed — and `Checker.lean` and `ApiCorrect` sit downstream of it.

This is the concrete content of "seed the checker layer": generating a file that
*uses* these names while generating nothing that *defines* them is the gap.

### What actually blocks it, measured

Taking the transitive closure of `CpcMini/Proofs/Checker.lean` — the smaller
package, so the honest lower bound — gives **15,868 hand-written lines across 25
files**. Two distinct obstacles, and they are very different in character.

**(a) The semantics layer, and it is small.** The closure reaches
`Proofs/Translation/` and `Proofs/TypePreservation/` — 10,880 of those lines —
through exactly one import: `Proofs/Common.lean`. But `Common.lean` uses only
**15 distinct names** from them, and two of those are
`eo_to_smt_well_typed_and_typeof_implies_smt_type` and
`eo_to_smt_non_none_and_typeof_bool_implies_smt_bool` — the front-end theorems a
generated checker already declares.

So this is not a 10,880-line dependency. It is a 15-name interface, and a
seeded checker layer could rest on the consumer's front-end stubs instead of on
Logos's developments. That leaves ~4,988 lines of genuine checker layer to seed.

**(b) The rule set, and this one is structural.**
`Proofs/RuleLemmas.lean` does a non-public `import Cpc.Proofs.Rules.X` for
**every one of the 591 rules**, and `Checker.lean` imports `RuleLemmas`. So
`Checker.lean` cannot be *built* until every rule proof compiles — which in a
freshly generated checker is never, since every rule is a `sorry`.

No amount of seeding fixes that. It is why Logos excludes `Checker` and
`ApiCorrect` from CI, and why `modularity.md` TODO 7 proposes a canary that
typechecks `Checker.lean` with the two bridge theorems replaced by `sorry`.

### The fix that would work

`Checker.lean` uses **two** theorems from `RuleLemmas` —
`cmd_step_proven_facts_of_invariants` and
`cmd_step_pop_proven_facts_of_invariants` — in **four places** across 1,063
lines.

Take them as hypotheses rather than imports. `Checker.lean` then depends on no
rule, builds standalone and proven, and the application to a particular rule set
happens where `RuleLemmas` is: at the point that actually knows the rules.

That is a small, local change with a large consequence. It would make
`Checker.lean` genuinely what it already almost is — a proof about a stack
machine, parameterized over "the rules do what they claim" — and it is the
precondition for a generated checker ever shipping it proven.

It also subsumes TODO 7's canary: a `Checker.lean` that does not import the
rules is checked by every ordinary build, so no canary is needed.

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

## 7. State the conclusion over the assumption list

**The ask:** drop `argListAssumes` from the soundness statement, so that no part
of the checker layer names an operator.

**Why now.** Item 1c removed `and` from everything a run touches. What is left is
one definition and the folds that mirror it:

| site | what names `and` |
| ---- | ---------------- |
| `Proofs/Assumptions.lean` | `argListAssumes`, the conclusion's conjunction |
| `Proofs/CheckerState.lean` | `stateAssumes` / `statePushes` / `stateProvens`, 11 sites |
| `Proofs/Common.lean` | 7 sites: `__eo_to_smt` of `and`, its Bool typing, its interpretation |
| `Proofs/CheckerCore.lean` | 2 sites |

**Shape of the fix.** `eo_satisfiability (argListAssumes F) false` says "the
conjunction of `F` has no model". State it directly over the list — no model
makes every entry of `F` true — and `argListAssumes` is unnecessary. The stack
folds are the same move one level down: they exist to compare a `Term` against
the state, and a list-level predicate would not need the operator either.

**What it would unlock.** Both `and` entries come out of the signature contract,
and `install-<calc>.sh` stops checking them. A calculus would then need no
declared operator at all — only the Bool literals, which are Eunoia builtins. A
signature could be a single rule over uninterpreted propositions. That is the
point at which "bring your own calculus" has no asterisk on it.

**Cost.** Not small: the conclusion is what every rule proof is ultimately for,
and `Common.lean`'s seven lemmas are load-bearing. Worth scoping before
committing.

## Cross-reference

`~/logos/docs/modularity.md` reaches compatible conclusions from the Logos side,
and its TODO 8 asked for a signature-contract check. Eudaimonia implements that
in `install/install-<calc>.sh`, including the two seams that document records as
unchecked — the nil attribute and the translation of `and` — both of which turn
out to be greppable in emitted Lean. Item 3 above is the request to move that
check upstream, where it belongs.
