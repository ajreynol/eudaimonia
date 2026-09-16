# A baseline reconstruction for lean-smt

**The question.** [lean-smt][lean-smt] proves Lean goals by sending them to cvc5
and replaying the returned proof rule by rule, in hand-written Lean. Could a
*baseline* take its place: one uniform justification that works for any CPC
proof, obtained by running the Logos checker inside Lean and carrying its
conclusion into Lean's own logic through Hermeneia?

**The short answer.** Yes, and the seam is shorter than it looks. The checker
half is already built: reflection on a 2244-command proof was measured to cost
nothing over running the checker, and the whole chain — checker run, soundness
theorem, model construction, native proposition — was composed end to end for a
small calculus with no `sorry`. What is missing is not the checker, and not the
rules. It is the bridge, and within the bridge it is the sorts: what a Lean
`Real`, an arbitrary Lean type under an uninterpreted sort, or a Lean function
under an array is allowed to be.

Everything below distinguishes **measured** from **read** from **inferred**.
Measurements were taken on 2026-09-16 against the revisions in
[the ledger](ledger.md#evidence-baseline); the lean-smt side is read from
`ufmg-smite/lean-smt@5bdc516` and `abdoo8080/lean-cvc5@7e33659`, not built here.

## 1. What the deliverable is

lean-smt's reconstruction produces, for a query with assertions `as`,
a term of type `¬ andN as` (`Smt/Reconstruct.lean`, `reconstructProof`), which
`Smt/Tactic/Smt.lean` then applies against the preprocessed hypotheses and the
negated goal.

Logos's conclusion has the same *shape* in a different logic:
`correct___eo_is_refutation` ends at `eo_satisfiability (argListAssumes F) false`,
where `argListAssumes` is the `and`-chain of the assumption list. It is a
statement about embedded terms and embedded models, not about Lean `Prop`s —
turning the one into the other is precisely the bridge, and §5.1 and §5.3 are
what that costs. The point here is only that the two ends match: what lean-smt
needs is what Logos establishes, once carried across.

So the deliverable is a library producing *a term of the type lean-smt already
consumes*, justified differently:

| | lean-smt today | the baseline |
| --- | --- | --- |
| per CPC rule | a hand-written Lean lemma or tactic | nothing |
| per SMT sort/symbol | reused from the rule lemmas | one correspondence lemma |
| what is executed in Lean | reconstruction in `MetaM` | the checker, by reflection |
| an unsupported step | `addTrust` — left as a goal (effectively a `sorry`) | either the whole proof is checked or the tactic fails |
| trusted beyond the kernel | the Lean compiler when `+native` | the Lean compiler, always (see §4) |

Two ways to deliver it, and the second is the one to aim at first:

- **Whole-proof.** A `smt +baseline` that justifies the entire refutation
  through Logos. Maximal payoff, maximal bridge coverage required.
- **Gap-filler.** lean-smt keeps its fast path; for each step it cannot
  reconstruct — today an `addTrust` mvar carried to the user — the baseline
  re-queries cvc5 for that one lemma and closes it. This is incremental,
  disturbs nothing, and turns lean-smt's *remaining `sorry`s* into checked
  proofs. It needs bridge coverage only for the sorts appearing in the gaps.

## 2. Why the seam is short

Four facts, each of which would otherwise have been a project of its own.

**Logos states soundness about a decidable function, not about a derivation.**
`Cpc/Api.lean` packages the executable as `logos_check_proof : String -> Except
String Verdict`, and `Cpc/ApiCorrect.lean` proves

```lean
theorem correct___logos_check_proof (input : String) (assums : List Term) (cmds : CCmdList)
    (hParse : parseProof input = Except.ok (assums, cmds))
    (hCorrect : logos_check_proof input = Except.ok Verdict.correct) :
    eo_satisfiability (logos_assumption_term assums) false
```

Both hypotheses are decidable facts about concrete values. That is a reflection
interface, already built, with no adapter needed.

**There is a second front end that skips the parser.** `Cpc/Native.lean` and
`Cpc/Native/Correct.lean` give `correct___logos_state_is_refutation`, stated
about a script that *names* its assumptions and commands instead of parsing
them. For a tactic that constructs the assumption terms itself this is the
better interface: it removes the unverified parser from the path entirely.

**lean-cvc5 already prints CPC.** `Solver.proofToString` takes a
`ProofFormat`, and `ProofFormat.CPC` is one of them (`cvc5.lean`, `cvc5/Types.lean`).
lean-smt already holds the `cvc5.Proof` object; it can obtain the CPC text
in-process, with no file, no second solver run and no external checker binary.

**The toolchains already agree.** Logos, Hermeneia and lean-smt all pin
`leanprover/lean4:v4.33.0`.

## 3. What was measured

### Reflection is free

`native_decide` on the largest Logos regression proof — `test-SEQ011_size3`,
2244 checker commands, a 1.6 MB Lean script:

| | wall | user |
| --- | --- | --- |
| `#eval!` of `logos_state_is_refutation` (what `logos-native` does) | 21.07 s | 43.0 s |
| `theorem ... := by native_decide` on the same value | 20.99 s | 42.6 s |

**Producing the proof term costs nothing over running the checker.** Both
figures are dominated by elaborating the 1.6 MB of `def`s; the checker run and
the reflection step are noise inside that. Since a tactic would build the terms
in `MetaM` rather than elaborate surface syntax, this is an upper bound.

### Logos accepts what lean-smt's solver configuration produces

Twelve queries in the theories lean-smt targets, run through cvc5 with
**lean-smt's own `defaultSolverOptions`** — including `proof-granularity=dsl-rewrite`
and `proof-elim-subtypes` — then through the `logos` executable. The queries and
the runner are [`probes/cpc-coverage/`](../probes/cpc-coverage/README.md):

| query | theory | steps | `logos` |
| --- | --- | --- | --- |
| `01-prop` | propositional | 4 | `correct` |
| `02-uf` | UF + `scope`/`process_scope` | 9 | `correct` |
| `03-lia`, `04-lia2`, `11-natish` | LIA | 56 / 174 / 51 | `correct` |
| `05-quant` | quantifiers | 34 | `correct` |
| `06-lra` | LRA | 53 | `correct` |
| `07-bv` | bit-vectors | 6 | `correct` |
| `08-mixed` | UF over `Int` | 5 | `correct` |
| `09-dt` | datatypes | 22 | `correct` |
| `10-str` | strings | 24 | `correct` |
| `12-arr` | arrays | 9 | `correct` |

Twelve for twelve, each in under 10 ms. This is a *small sample of small
queries* and is not a coverage claim; it is evidence that the granularity
lean-smt asks cvc5 for is one Logos reads, which was the thing most likely to
be wrong. The real measurement is lean-smt's own test suite, and it is the
cheapest next experiment there is — it needs no Lean at all, only cvc5 and the
`logos` binary.

For scale on the other side: Logos's `CRule` has **591** constructors, one per
CPC rule; lean-smt's `Smt/Reconstruct/` is **95 files**, with several hundred
top-level rule and rewrite cases between them (counted by pattern, so a proxy,
not a rule count). The baseline makes that number irrelevant, not smaller.

### The chain composes, against full CPC

[`Instances/HermeneiaCpc/`](../Instances/HermeneiaCpc) runs the whole path
against `Cpc` — 591 rules, the calculus cvc5 emits — in three files split by
build cost:

1. `__eo_checker_is_refutation F cmds = true` — `native_decide`;
2. the two translation side conditions — `native_decide` and `trivial`;
3. `correct___eo_is_refutation` — CPC's soundness theorem;
4. a model realising each native assignment — `default_typed_model` overridden
   at an arbitrary finite set of keys, with `model_wf` re-proved;
5. one evaluation fact per assumption, from the symbol laws;
6. `∀ b : Bool, ¬ (b = true ∧ (!b) = true)` — a proposition in Lean's own terms.

Steps 1, 2, 4, 5, 6 need only the semantics and check in **10 s** on top of a
one-minute Logos build; step 3 is three lines in a separate file and is the only
thing that needs CPC's 691,928-line proof development. The seam theorem —
`no_realizing_model`, which is steps 5 and 6's whole interface — reports
**no `native_decide` axiom at all**: just `propext`, `Classical.choice`,
`Quot.sound`.

Two facts made this cheap, and both are worth naming because the plan budgeted
neither:

**Logos already proves models exist.**
`Cpc/Proofs/TypePreservation/Nonvacuity.lean` builds `default_typed_model`,
total and canonical at every well-formed SMT type, and proves it `model_wf` — in
a 14-job, 32-second build that does not touch a single rule proof. Realising a
native assignment is then an *override* at finitely many keys: `model_fun_wf`
constrains only `nativeFuns`, which an override leaves alone, and the rest
reduces to the typing and canonicality of the values put in.

**The composition is rule-free, so it can be developed without the rule proofs.**
`correct___eo_is_refutation` names no rule; `Proofs/Checker.lean` is
byte-identical between `Cpc` and `CpcMini` modulo the package name. Stating the
bridge with Logos's conclusion as a *hypothesis* keeps the entire development
inside the one-minute build, and pays the hours-long one once at the end.

## 4. Kernel reduction

`decide` and `rfl` **cannot** discharge the checker run. This is not a timeout:
reduction gets stuck. Bisected, the cause is that the assumption-push guard
calls `__eo_is_closed`, whose `__eo_is_closed_rec` recurses on the first
argument in one clause and the second in another, so Lean compiles it by
well-founded recursion, which the kernel will not unfold.

`__eo_typeof` — a far larger function — reduces fine, and only **9 of 4784**
generated `Eo` constants are compiled this way:

```
__eo_is_closed_rec  __eo_typeof_dt_cons_rec  __eo_typeof_dt_sel_return
__dt_eq_cons        __eo_datatype_cons_selectors_rec
__re_flatten        __poly_add  __mvar_mul_mvar  __bv_mk_bitblast_step_shr_rec_step
```

Only the first is on the path every run takes. So "make the core checker
kernel-reducible" is a small, identifiable request to the compiler, not a
rewrite — and it would matter, because it is the only route to a baseline whose
own reflection step adds nothing to the trusted code base. (It would not empty
that base on its own; see below.)

**But it would not change the position today**, because of a fact worth stating
plainly: Logos's own soundness proof uses `native_decide` — **604 occurrences
under `Cpc/`**, 8 under `CpcMini/`. The Lean compiler is already in the trusted
code base of the theorem the baseline composes with. `native_decide` on the
checker run adds no new *kind* of assumption; it does add degree, since it runs
far more code, on input a solver supplied. Logos's `scripts/check-proof-hygiene.sh`
rejects `sorry`, `admit` and `axiom` textually, which does not see these — the
axiom report does, and this is why every theorem in the instance prints one.

## 5. The challenges, in the order they will actually hurt

### 5.1 The bridge is about sorts, not rules — and three sorts are narrowed

Logos's conclusion is *false under every well-formed model*. To get a Lean
proposition you need the other direction: **every native assignment must have a
corresponding well-formed model**, or the transfer proves nothing about
assignments the model class cannot express. `FormulaBridge.realizes` is that
obligation.

A narrower model class makes this *harder*, and Logos's
[conformance document](https://github.com/cvc5/logos/blob/main/docs/smt-lib-conformance.md)
names exactly three narrowings — each of which lands on this direction:

| narrowing | consequence for the bridge |
| --- | --- |
| `Real` is `Rat` | **There is no bridge to Mathlib's `ℝ`.** An assignment sending a variable to an irrational has no model. lean-smt supports Real arithmetic; the baseline would cover `ℚ`-valued goals only. |
| uninterpreted sorts are countably infinite | An assignment over an arbitrary Lean type needs an injection into a countable domain. Quantifier-free goals can be handled by encoding only the finitely many elements the assumptions denote — but that makes the bridge term-indexed rather than environment-indexed, which is a different and larger construction. |
| arrays are almost-constant maps | Only almost-constant Lean functions are realisable. Fine quantifier-free; not in general. |

None of these is a defect in Logos. They are recorded, and they are confined to
quantified or nonlinear reasoning. They are listed here because they are
invisible from the checker side and decisive on the bridge side, and because
`ℝ` in particular is a *coverage regression* against what lean-smt does today.

### 5.2 The bridge grows with the semantics, not with the calculus

This is the question [`generality.md`](generality.md) is about, and the answer
is favourable but conditional.

Hermeneia bridges at `SmtTerm`, not at `Eo.Term`: `eo_satisfiability` is
*defined* as `smt_satisfiability` of the translation, so the calculus enters
only as a computation on the concrete assumptions. That makes CPC's **591 rules
and 189 operators free**. What is left is **148 `SmtTerm` constructors** needing
one evaluation law each and **15 `SmtType` constructors** needing a carrier. The
instance has 4 laws and 2 sorts.

The conditional part is that none of the machinery that keeps this honest as CPC
moves exists yet: no decidable supported-fragment predicate, no exhaustive
classifier that fails the build when a constructor is added, no
Hermeneia-side `incomplete` verdict, no generated obligations, no recorded
semantics identity. `generality.md` §4 lists the five, and until they exist the
instance is evidence that the layering works rather than a system that stays
honest by itself.

One consequence for sequencing: a *coverage* proof (needed for quantifiers) is
not independent per sort. Proving that nothing but `SmtValue.Boolean` has type
`Bool` required shape lemmas about maps, sets, sequences and datatype
application chains. Adding a sort can reopen every existing coverage proof;
adding one cannot break an existing *realisation* proof.

### 5.3 The middle of the chain is two unverified translations meeting

lean-smt translates a Lean goal to SMT-LIB **text**; cvc5 parses it, solves, and
prints a CPC proof; Logos parses that. lean-smt's translation is unverified;
Logos's parser is unverified and its theorem is explicitly about the assumptions
*as parsed*. A baseline that stopped at "Logos said `correct`" would have
replaced per-rule trust with translation trust and called it progress.

The honest construction closes the loop with a *checked* obligation rather than
a verified translator: for each assumption term `Aᵢ` the tactic gets back, it
must produce a Lean proof of `denote ρ Aᵢ ↔ Pᵢ`, where `Pᵢ` is the actual
preprocessed hypothesis type in the goal's context, discharged by `rfl`/`simp`/
`decide` — **and fail loudly when it cannot**. That reduces the trusted
translation to a decidable syntactic agreement, checked by the kernel, and it is
the piece most likely to be quietly skipped.

Note what this does *not* remove: `Smt/Translate` is still needed to build the
query. The baseline replaces `Smt/Reconstruct/**`, not the translation.

### 5.4 Dependency weight

Using `correct___logos_check_proof` means depending on Logos's proof
development: `scripts/cpc-loc-summary.py` reports **820 proof files, 691,928
lines**, of which 634,322 are the per-rule proofs. Logos's README documents a
full build at over two hours, and its CI builds only a representative subset.

For a *user* of lean-smt this is a distribution problem, not a per-call one —
the oleans are built once. But it is a real one: lean-smt would acquire a
dependency an order of magnitude larger than itself, and would need prebuilt
artifacts (Reservoir, Lake cloud cache) to stay usable. A narrower package
exporting `Cpc.Api` plus `Cpc.ApiCorrect` and nothing else would help; whether
that is possible without pulling the rule proofs transitively is a question for
Logos, since `Cpc/Proofs/Checker.lean` rests on `RuleLemmas.lean` which imports
every rule.

### 5.5 Proof size in the goal, not in the solver

The measured 21 s was elaboration of 1.6 MB of surface syntax. A tactic building
the same terms in `MetaM` avoids the parser, but the *proof term* still contains
the command list, and it is stored in the olean. Two ways out, both worth
measuring before choosing:

- **the text route** — embed the CPC proof as a single `String` literal and use
  `correct___logos_check_proof`. Cheap to elaborate, but the theorem's `hParse`
  hypothesis names `assums` *and* `cmds`, putting the big term back. A corollary
  existentially quantifying the command list would fix this, and is a small,
  concrete request to Logos:
  `(h : (parseProof input).map Prod.fst = Except.ok assums) -> ... `.
- **the native route** — build `assums` and `cmds` as terms and use
  `correct___logos_state_is_refutation`. Keeps the parser out of the path, at
  the cost of carrying the commands as an expression.

### 5.6 Coverage is not free, it moves

The baseline makes rule coverage free and leaves *sort and symbol* coverage as
the cost. That is a good trade — there are 591 rules and a few dozen sorts — but
it is a trade, not an elimination, and the two coverage notions do not nest:
Logos can report `incomplete` for a proof it accepts whose terms have no SMT
translation, and refuses parametric datatypes outright.

## 6. A staged plan

Each stage is separately useful, and each has a check that does not depend on
the next.

| stage | deliverable | check |
| --- | --- | --- |
| **L0** | Run lean-smt's test-suite queries through cvc5 → CPC → `logos` and publish the table. `probes/cpc-coverage/run.sh` already does this for a directory of queries; L0 is pointing it at lean-smt's. | A pass rate per theory. Needs no Lean. This decides whether the rest is worth doing. |
| **L1** | Widen layers 2 and 3 of the existing CPC bridge: the rest of the Boolean and `Int` symbol laws, `eq`, and a decidable supported-fragment classifier ([`generality.md`](generality.md#4-the-five-mechanisms-that-keep-it-honest-as-it-grows) M1–M2). | `check-cpc.sh` still passes; a symbol outside the fragment is *reported*, not silently admitted. Axioms reported. |
| **L2** | A `Term`-level Lean denotation `denote : Env → Term → Prop` for that fragment, plus the transfer theorem from `eo_satisfiability (argListAssumes F) false` to `∀ ρ, ¬ (denote ρ A₁ ∧ … )`. | Instantiated on a cvc5-produced proof, not a hand-written one. |
| **L3** | A tactic taking a CPC proof and a list of Lean `Prop`s, producing `¬ andN as` — the type lean-smt's `reconstructProof` already returns — including the `denote ρ Aᵢ ↔ Pᵢ` obligations of §5.3, failing when they cannot be discharged. | Closes goals lean-smt closes, with a matching axiom report. |
| **L4** | The gap-filler integration: lean-smt's `addTrust` steps re-queried and closed by L3. | lean-smt tests that currently leave goals close. |
| **L5** | `smt +baseline` for whole proofs; then the packaging question of §5.4. | A benchmark table against the existing path. |

L0 is a day. L1–L2 is the mathematics. L3 is where the honesty of §5.3 is
decided. L4 is the first thing lean-smt would actually want.

## 7. What this investigation does not establish

- **The CPC composition step is not yet checked here.** Layers 0–3 and the
  conditional example are checked against `Cpc`;
  [`Refutation.lean`](../Instances/HermeneiaCpc/Refutation.lean), which applies
  `correct___eo_is_refutation`, needs the whole proof development, whose cost is
  taken from Logos's README and CI configuration rather than measured.
- **The lean-smt side was read, not run.** No lean-smt build, no `smt` tactic
  invocation, no measurement of the existing reconstruction path to compare
  against.
- **Twelve queries is not a coverage result.** §3's table is a sanity check that
  the proof granularity lines up. L0 is the measurement.
- **Nothing here is a commitment on anyone else's part.** Hermeneia is
  [an island](../README.md#an-island); the compiler request in §4, the corollary
  request in §5.5 and the packaging question in §5.4 stay in this directory
  until a person carries them through the parent's reporting process. The
  lean-smt integration in §6 is a proposal to a project that has not been asked.

[lean-smt]: https://github.com/ufmg-smite/lean-smt
