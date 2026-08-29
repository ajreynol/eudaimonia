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

unconditionally, and `DatatypeDecl` also appears in the fixed
`lean_meta_smt_model_defs.lean`, `lean_meta_smt_value_order.lean` and
`lean_meta_parser.lean`. So **every** signature gets the datatype machinery,
whether or not it declares a datatype. `CpcMini` — the same signature reduced to
five rules — carries exactly as much of it as `Cpc` (6 `DatatypeDecl`
occurrences in `LogosTerm.lean` for both).

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

**Shape of the fix.** Key emission on what the signature declares. Datatypes are
the clearest case — `declare-datatypes` is present or it is not — and are worth
doing first. The same applies to binder machinery (`Term.Var`, closedness), to
indexed-operator arities (item 1b), and plausibly to whole theories.

**What the template already does.** `install/defs/profile.conf` in a generated
checker records the answers, including `PROFILE_DATATYPES` and
`PROFILE_BINDERS`. They are marked *declared* rather than *derived*, precisely
because nothing in the emitted output distinguishes them today. If eoc gains
conditional emission, those keys are what a generated checker would key on, and
they become derivable at the same moment.

## 1b. Indexed operators: a fixed ladder of exactly three

**The ask:** make the number of index arities depend on the signature — both
downwards, so a calculus that indexes nothing does not carry three enums, and
upwards, so one needing four indices can be expressed at all.

**Evidence.** `lean_meta_checker_term.lean` declares the ladder literally:

```lean
inductive UserOp1 : Type where
$LEAN_EO_THEORY_OP1_DEF$
…
inductive UserOp3 : Type where
$LEAN_EO_THEORY_OP3_DEF$
```

There is no `UserOp4`, and there is no `UserOp0`-style omission.

*The ceiling.* Three is the most indices an operator can take. A calculus
wanting `(_ f i j k l)` cannot be compiled. Nothing warns; the signature simply
cannot say it.

*The floor.* An arity the calculus does not use is still emitted, holding a
placeholder:

```lean
inductive UserOp1 : Type where
  | None : UserOp1
```

That is `CpcMini`, which has one such constructor in each of `UserOp1`,
`UserOp2` and `UserOp3` — against Cpc's 14, 4 and 2. The placeholder is there
because the inductive has to be non-empty for the `deriving` clause, which is
fair enough; the cost is that `Term` still gets `UOp1`, `UOp2` and `UOp3`
constructors, and so every function matching on `Term` gets cases for all three.
In a generated CPC package that is 260 lines of `Logos.lean`, 26 of
`LogosTerm.lean`, 22 of `Parser.lean` and 20 of `Spec.lean`.

**A difference from item 1 worth noting.** Unlike datatypes, this one is
*derivable* from what is emitted: the placeholder is named `None`, so the
highest arity holding a real constructor is exactly the arity the calculus uses.
Eudaimonia derives it, and a generated checker records it as
`PROFILE_INDEXED_OPS`. So the compiler already emits enough information to know
the answer — it just does not act on it.

**Shape of the fix.** Emit `UserOp<n>` and the matching `Term.UOp<n>` for
`n = 1 … k`, where `k` is the greatest arity the signature actually uses, and
let `k` range higher than 3 — five would cover anything plausible. `k = 0` (no
indexed operators at all) should drop the constructors entirely rather than
emit placeholders.

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

## Cross-reference

`~/logos/docs/modularity.md` reaches compatible conclusions from the Logos side,
and its TODO 8 asked for a signature-contract check. Eudaimonia implements that
in `install/install-<calc>.sh`, including the two seams that document records as
unchecked — the nil attribute and the translation of `and` — both of which turn
out to be greppable in emitted Lean. Item 3 above is the request to move that
check upstream, where it belongs.
