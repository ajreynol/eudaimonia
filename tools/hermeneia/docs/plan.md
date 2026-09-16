# Initial implementation plan

The target is a checked instance for selected `.eos` semantics, with a small
reusable contract library. All work stays inside `tools/hermeneia/`; compiler
extension proposals stay here until separately adopted by their owner.

| step | concrete deliverable | completion check | status |
| --- | --- | --- | --- |
| H0 — state the contract | Typed sort/literal/operator laws, native-to-model existence, and refutation transfer. | Standalone Lean build; changed literal, translation, addition and empty model class rejected by proved counterexamples; axiom report. | Complete as an interface experiment; no Logos instance. |
| H1 — bind one configuration | `Instances/<id>/` adapter and input manifest referring to actual generated declarations. Bind `Int`, `Term.Numeral`, `SmtTerm.Numeral`, `SmtValue.Numeral` and the two semantic functions. | Prove all numeral laws for arbitrary signed integers and arbitrary models, value canonicality, and source/translated typing as required. Rebuild against the recorded toolchain; report axioms. | **Done against full `Cpc`**, in [`Instances/HermeneiaCpc/`](../Instances/HermeneiaCpc): `boolSort`, `intSort` and `ratSort` bind actual generated declarations, with typing, canonicality and injectivity proved. The numeral *operation* laws (H4) are not. |
| H2 — prove the Boolean fragment | Typed variables, Boolean literals, negation, conjunction, a native assignment interpreter, and model construction. | Prove correspondence by induction, global model well-formedness for every native assignment, conjunction/list agreement, and conversion from the real `eo_satisfiability ... false`. | **Done in general for the parts that are general.** Model existence is proved for an arbitrary finite native assignment (`exists_model`), and the conjunction fold and conversion from the real `eo_satisfiability` predicate are proved once and rule-free (`no_realizing_model`, no `native_decide` axiom). What remains per-fragment is the symbol laws: 4 of 148 `SmtTerm` constructors. |
| H3 — compose a refutation | A fixed actual assumption list and checked proof, yielding a theorem written in native Lean propositions. | Prove the intended-list relation and all bridge obligations. Check and report every checker soundness dependency; label the result conditional if any soundness hypothesis remains. | **Done against `Cpc`, conditionally.** `native_refutation` carries `eo_satisfiability (argListAssumes F) false` as a hypothesis; [`Refutation.lean`](../Instances/HermeneiaCpc/Refutation.lean) discharges it with CPC's `correct___eo_is_refutation` in three lines. That last file has not been checked here — it needs the whole proof development. No `sorryAx` anywhere. |
| H4 — add integer expressions | Integer variables, literals, equality, addition, subtraction, negation, multiplication and order. | One operation law per symbol/sort signature and one expression induction theorem; regression inputs include negative and large values. Literal-only success does not close this step. | After the Boolean transfer works. |
| H4 — add integer expressions — *superseded in order* | see below | | [`generality.md`](generality.md) argues H5's mechanisms should come first. |
| H5 — generate obligations | First a typed adapter/sidecar prototype, then a candidate `.eos` field design informed by H1–H4. | Emit theorem statements and bind supplied proof names by type. Missing proofs/unsupported symbols cannot certify a fragment. Altering semantics forces rechecking. | Design only; no compiler implementation yet. **Reordered before H4** — see below. |

## Growing the fragment comes before widening it

[`generality.md`](generality.md) works out what each kind of addition to CPC
costs this project. Two findings change the order of the table above.

**Rules and calculus operators cost nothing**, because the bridge is stated
about `SmtTerm` rather than `Eo.Term`. The surface that grows is the semantics:
148 `SmtTerm` constructors and 15 `SmtType` constructors, against CPC's 591
rules and 189 operators. So H4's breadth is cheaper than it looks.

**But nothing yet keeps the fragment honest while the semantics moves.** There
is no decidable supported-fragment predicate, no exhaustive classifier that
fails the build when a constructor is added, no Hermeneia-side `incomplete`
verdict, and no recorded semantics identity. Those are `generality.md` §4's five
mechanisms, and they belong in H5 — which therefore should come **before** H4,
not after it. Widening a fragment that cannot report its own edges produces
coverage claims nobody can check.

## H1: the next implementable slice

1. Choose one coherent baseline. The inspected Logos revision is a useful first
   candidate. Eudaimonia's pinned Hello specification is another; do not combine
   its older compiler pin with the neighboring Ethos checkout's newer source.
   Record the entire configuration and generation recipe described in
   [the contract](contract.md#1-what-is-being-related). Keep build outputs inside
   this child and avoid modifying a neighboring checkout to build it.
   `Instances/check-cpc.sh` builds in whatever checkout it is pointed at, so
   the recorded run used a scratch copy of Logos rather than the working tree.
2. Import that baseline's generated definitions through an explicit dependency
   or an attributed snapshot inside the child. Define the adapter by direct
   references to its declarations. Do not prove the result against a toy copy
   of the literal evaluator and call that a Logos proof.
3. Construct `SortBridge ... Int`, `LiteralBinding ... Int`, and `NumeralBridge`.
   Start with definitional proofs where possible. A universal theorem is the
   deliverable; examples at `-1`, `0`, and a large integer only aid diagnosis.
4. Regenerate a separate fixture with numeral evaluation changed from `n` to
   `n + 1`. The unchanged native interpretation must fail certification.
   Independently change the calculus translation for a Boolean operator and
   check that its original bridge fails. Record unsupported changes explicitly
   if the compiler cannot express a particular mutation.
5. Change only irrelevant documentation and confirm the instance can be rebuilt.
   This distinguishes a stale identity report from an actual semantic mismatch.

## H2/H3: first native theorem

Use assumptions `[p, not p]`, where `p` is a typed Boolean variable, and an
actual refutation of that list. Construct a model for each `ρ : Var → Bool`;
prove the checked fold means `ρ p = true ∧ ¬ (ρ p = true)` with its terminal
`true` handled. This exercises variable lookup, both literals, negation,
conjunction, list folding, and model existence in a single small fragment.

For the hypotheses/goal interface, also instantiate the transfer theorem with
assumptions `[p, not q]` and a supplied sound refutation to derive
`ρ p = true → ρ q = true`. This is a conditional theorem unless a concrete proof
establishes that particular refutation; do not invent one for independent
variables. A concrete example can use `q = p`.

## The lean-smt track

[`lean-smt.md`](lean-smt.md) investigates what H1–H5 would have to reach for
Hermeneia to be usable as a *baseline proof reconstruction* in
[lean-smt][lean-smt]: one uniform justification for any CPC proof, in place of
its per-rule replay. It states its own staged plan (L0–L5), whose L1 widens the
layers this plan's H1/H2 established.

That document is a proposal to a project that has not been asked, and changes
nothing here. What it does change is the *order* H4 and H5 are worth doing in:
its findings say the per-symbol operation laws matter more than the generated
obligations, and that three sorts — `Real`, uninterpreted sorts, and arrays —
need a ledger decision before any of them can be attempted.

[lean-smt]: https://github.com/ufmg-smite/lean-smt

## Acceptance and exclusions

Build the experiment with `cd tools/hermeneia && lake build`. The default target
includes the contract checks and their axiom reports. There are no external
Lake dependencies, admitted proofs, custom axioms, or parent CI changes.

The CPC instance is deliberately *not* part of that build — it imports a
neighbouring Logos checkout, so it is run by `Instances/check-cpc.sh` with that
checkout's path. See [`Instances/README.md`](../Instances/README.md).

The current generic contract omits source-language typing, canonicality,
operation translation/composition, the concrete Logos adapter and an actual
model construction. These are explicit H1/H2 work, not facts implied by the
successful build.

The CPC instance supplies the concrete adapter and the model construction, and
the latter in general (`exists_model`, for an arbitrary finite assignment). It
does not supply an operation law for any symbol, a decidable supported-fragment
predicate, or a refutation of a solver-produced proof. Its final composition
step is checked only by inspection so far, not by a build.

Division/modulo by zero, reals, bit-vectors, strings, datatypes, functions and
quantifiers remain outside the initial supported fragment. Each needs a ledger
decision before expansion. In particular, a direct bridge for a total helper
does not establish a direct bridge for the model-dependent public operation.
