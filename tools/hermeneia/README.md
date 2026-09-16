# Hermeneia

A **child project** of the Eudaimonia build framework: a correspondence between
the embedded SMT-LIB semantics and Lean's own logic, so that a theorem about an
embedded formula can become a theorem about the values and propositions a Lean
development uses.

**Where it is right now.** An assessment with a working demonstration under it,
not a usable component. [Status](#status) is the honest inventory — what is
machine-checked, what is only measured, and what does not exist. The two
questions it is currently being asked are
[(A) what serving lean-smt would take](#a-what-serving-lean-smt-would-take) and
[(B) what maintaining it would cost](#b-what-maintaining-it-would-cost).

## The charter

**The question.** What must be proved to carry a checked refutation out of the
embedded semantics and into an ordinary Lean proposition, with the meaning of
every supported sort and symbol preserved?

**The artifact.** A Lean library of correspondence definitions and lemmas,
together with examples composing them with a checker's soundness theorem. Its
coverage is explicit: which sorts and operations correspond directly, which
need hypotheses or a different representation, and which are unsupported.

**The goals, in order.**

1. **State the bridge.** Treat correspondence as a contract for configurable
   semantics, then choose one pinned configuration to instantiate it. Relate
   embedded values, native Lean values, and their environments. State the
   typing, translation and model assumptions needed to transfer a result.
2. **Prove one small fragment.** Start with Boolean variables, literals,
   conjunction and negation. Prove their correspondence and compose it with a
   refutation theorem to obtain a native Lean proposition. This is the first
   milestone; theory coverage comes after the whole connection works.
3. **Keep the correspondence ledger.** For each supported sort and symbol,
   record its embedded meaning, its Lean counterpart, the lemma connecting
   them, and any side conditions. Record mismatches and exclusions alongside
   successful correspondences.
4. **Extend by theory.** Integers first, then bit-vectors and strings, one
   stated fragment at a time. Choose representations and exceptional behavior
   before attempting the lemmas that depend on them.
5. **Identify what can be generated.** Once the hand-written examples establish
   the shape, determine which correspondence statements the Eunoia compiler
   could emit beside its existing per-symbol artifacts, and which still need
   mathematical choices from a person.

**The wishue (stretch goal).** A Lean development obtains a solver refutation,
checks it, and derives a theorem stated entirely in its own terms. The example
must account for the connection between the intended proposition and the
actual assumptions checked, as well as for the semantic correspondence.

**What is out of scope.**

- Replacing the SMT-LIB semantics, changing CPC, or deciding what either means.
- Proving the checker's soundness or completing the framework's proof stubs.
  Hermeneia composes with that proof and retains any hypotheses it requires.
- Verifying the compiler, the solver, or a parser; building a new checker.
- A general SMT tactic, solver orchestration, or a production integration in
  the initial milestone.
- Claiming all of SMT-LIB is covered, or hiding semantic differences behind
  identically spelled operations.
- Integrating this library into the parent's build or generated checkers while
  it remains an isolated child project.

**Publishing stance.** No `report/` exists and no paper is planned at launch.
Revisit that after a proved fragment and its correspondence ledger provide a
result worth writing up.

## What the bridge has to establish

The framework's [checker theorem template][checker] concludes
`eo_satisfiability (argListAssumes F) false`: the conjunction of the embedded
assumptions is unsatisfiable. Its hypotheses include translatability of the
assumptions, translation conditions on the commands, and a refutation. That
conclusion does not itself state a proposition about Lean's native `Int`,
`BitVec`, or `String`.

Hermeneia supplies the next connection. Each native assignment in the supported
fragment must have a corresponding well-formed embedded model, and interpreting
each translated formula in that model must agree with its native proposition.
This direction matters: agreement only for some embedded models would not
justify a conclusion about every native assignment.

With that connection proved, embedded unsatisfiability rules out the
corresponding native assumptions. To derive a goal from hypotheses by
refutation, the checked assumptions must represent those hypotheses together
with the negation of that goal. The final theorem must expose any remaining
conditions; it cannot silently discard them.

**Acceptance alone is not a proof of this chain.** A fresh generated checker
contains unfinished soundness proofs, as the parent's
[limitations](../../docs/limitations.md#nothing-is-proven-yet) explain. An
example here counts as complete only when its correspondence proofs and the
soundness result it uses have been checked, with their axioms and dependencies
reported. An example parameterized by an unproved soundness hypothesis is a
conditional result and is labeled as such.

Nor does correspondence verify that a parsed problem was the one a caller
intended. The relation to the actual checked assumptions is a separate
obligation. A solver or checker printing `unsat` or `correct` cannot discharge
it.

## Where the difficult choices live

The [original proposal][proposal] identifies the central difficulty: operations
with similar names may make different choices at their boundaries. Division
by zero, out-of-range string operations, and bit-vector widths belong in the
correspondence statement, not in an unstated convention.

For each such case, the ledger must say whether the bridge uses a direct
equality, a theorem with explicit side conditions, a representation that carries
the extra semantic choices, or no correspondence yet. Testing examples can
expose a wrong choice; the transfer claim requires a proof.

## What it builds on

| source | what Hermeneia takes from it |
| --- | --- |
| [Ynoia's Hermeneia proposal][proposal] and [work register][work] | The project scope: connecting the embedded semantics to Lean's own logic, and the per-symbol obligations that entails. |
| Eudaimonia's [signature contract](../../README.md#the-signature-contract) | The conjunction of assumptions and its SMT translation are part of what the checker theorem means. |
| The [checker theorem template][checker] and [generated-checker guide](../../docs/generated-checker.md#what-a-fresh-checker-can-and-cannot-say) | The interface to compose with, its side conditions, and the distinction between acceptance and proved soundness. |
| [Noesis](../noesis/README.md) | Related work on defining the semantics and compiler in Lean. It could make correspondence easier to maintain; it is not a prerequisite for starting this project. |

The initial source is the semantics already carried by Logos and used by the
framework. The first implementation must record the exact revisions and Lean
toolchain it uses. Noesis and Hermeneia answer different questions: preserving
meaning through compilation, and relating that meaning to native Lean
statements. Neither project's completion is assumed here.

## Status

**This is an assessment, not a service.** Nothing here is usable by anyone yet.
What exists is enough evidence to answer two questions — what serving
[lean-smt][lean-smt] would take, and what maintaining it would cost — and the
tables below say exactly which parts of that evidence are machine-checked.

Everything was checked on 2026-09-16 against the revisions in
[the ledger](docs/ledger.md#evidence-baseline), with a scratch copy of Logos.
There is no CI; every check is a script a person runs.

### What is machine-checked

| claim | where | status |
| --- | --- | --- |
| Generic contract interfaces and their refutation transfer | [`Hermeneia/Contract.lean`](Hermeneia/Contract.lean) | **compiles.** No Logos instance; parameters uninstantiated |
| Changing a literal's meaning, its translation, or addition breaks a fixed correspondence; a vacuous model class cannot realise an inhabited assignment space | [`Hermeneia/Checks.lean`](Hermeneia/Checks.lean) | **compiles.** Synthetic fixtures, not generated from `.eos` |
| The refutation seam: no well-formed model makes every assumption of a checked refutation true | `Bridge.lean`, `no_realizing_model` | **compiles against full CPC.** Axioms: `propext`, `Classical.choice`, `Quot.sound` — *no* `native_decide` |
| Every finite native assignment reaches a globally well-formed model | `Bridge.lean`, `exists_model` | **compiles.** Inherits two `native_decide` axioms from Logos's canonicality proofs |
| Sort carriers with their obligations | `Bridge.lean`, `boolSort`/`intSort`/`ratSort`, `boolCover`/`intCover` | **compiles.** `Bool` and `Int` in **both** directions (realise *and* cover); `Real` realises to `Rat` only. **2 of 15** sorts fully, a third partly |
| Symbol laws for `and`, `not`, Bool literals, `UConst` | `Bridge.lean` | **compiles.** **4 of 148** `SmtTerm` constructors |
| One refutation carried to a Lean proposition, conditional on Logos's conclusion | `Example.lean`, `native_refutation` | **compiles.** Two assumptions, one Boolean constant, hand-written |
| The three lines that discharge that condition, against a *transcription* of `correct___eo_is_refutation` | `Example.lean`, `refutation_of_soundness` | **compiles.** The transcription is confirmed by reading, not by a build |
| The same three lines against the *real* theorem | [`Refutation.lean`](Instances/HermeneiaCpc/Refutation.lean) | **never compiled.** Needs CPC's whole proof development — a build attempt ran out of disk; see [the ledger](docs/ledger.md#measurements-taken-2026-09-16) |

### What is measured but not proved

| measurement | result |
| --- | --- |
| Reflection cost: `native_decide` vs `#eval!` on a 2244-command, 1.6 MB CPC proof | 20.99 s vs 21.07 s — producing the proof term is free |
| Kernel reduction of a checker run (`decide`, `rfl`) | **stuck**, not slow. 9 of 4784 generated `Eo` constants use well-founded recursion; `__eo_is_closed_rec` is on every run's path |
| `native_decide` inside Logos's own proofs | 604 occurrences under `Cpc/` — the Lean compiler is already in the trusted base of the theorem this composes with |
| cvc5 → CPC → `logos` under lean-smt's own solver options | 12 of 12 `correct` ([`probes/cpc-coverage/`](probes/cpc-coverage/README.md)). A granularity sanity check on small queries, **not** a coverage result |

### What does not exist

- **No solver-produced proof has ever gone through the bridge.** Everything
  above is one hand-written refutation of `p` and `not p`. This is the largest
  single gap.
- No tactic, no `MetaM` code, no lean-smt integration, and nothing proposed to
  lean-smt. `docs/lean-smt.md` is an assessment written here.
- No decidable supported-fragment predicate, so the bridge cannot yet *say*
  what it does and does not cover.
- No operation law for any symbol — no arithmetic, no equality.
- No generated obligations, and no recorded semantics digest.

## (A) What serving lean-smt would take

[`docs/lean-smt.md`](docs/lean-smt.md) is the assessment; its staged plan is
L0–L5. The shape of the answer:

**The deliverable is a term of a type lean-smt already consumes.** Its
`reconstructProof` returns `¬ andN as`; Logos concludes the same shape in the
embedded logic. So the baseline is a second justification for the same
interface, not a new one — usable whole-proof, or as a gap-filler for the steps
lean-smt today leaves as goals.

**Four things make the seam short**, all of them already built by someone else:
Logos states soundness about a *decidable function*; it has a second front end
that skips the parser; lean-cvc5 already prints `ProofFormat.CPC` in-process;
and all three projects pin `leanprover/lean4:v4.33.0`.

**The hard parts are not the rules.** They are (i) the per-sort narrowings —
`Real` is `Rat`, so there is no bridge to Mathlib's `ℝ`, which is a coverage
*regression* against what lean-smt does today; (ii) the seam where two
unverified translations meet, which must be closed by a *checked* obligation per
assumption rather than by trust; and (iii) packaging a dependency an order of
magnitude larger than lean-smt itself.

**The cheapest next step is L0**, which needs no Lean: run lean-smt's own test
suite through cvc5 → CPC → `logos` and publish the pass rate.
`probes/cpc-coverage/run.sh` already does this for a directory of queries.

## (B) What maintaining it would cost

[`docs/generality.md`](docs/generality.md) draws the boundary. Measured, the
reusable bridge names **45** declarations of the SMT-LIB semantics, **5** of the
calculus, and **zero** proof rules, operators or Logos proofs.

| if this changes | Hermeneia's cost |
| --- | --- |
| a CPC proof rule is added (591 today) | **none** — not in the interface |
| a CPC operator is added (189 today) | **none**, unless it makes Logos add an `SmtTerm` constructor |
| an `SmtTerm` constructor is added (148 today) | one evaluation law, or classify it unsupported |
| an `SmtType` is added (15 today) | a carrier and a realisation proof; a coverage proof too if quantifiers are in scope — and coverage proofs are **not** independent per sort, so this can reopen existing ones |
| an existing `smt.eos` symbol changes meaning | the affected law fails to prove — loud and local |
| the checker theorem's statement changes | `Refutation.lean` stops compiling — three lines |

So the maintenance burden scales with **how much has been certified**, not with
how fast CPC moves. Today that is about 360 lines of bridge, and a semantics
regeneration would break its proofs loudly. What is missing is the other half:
nothing yet *reports* a newly added constructor, so coverage could rot silently
while every existing proof still passes. `generality.md` §5 lists the five
mechanisms that fix that — an exhaustive classifier, a Hermeneia-side
`incomplete`, generated obligations, statements naming actual declarations, and
a recorded semantics identity. **None is built.** Until they are, this is a
demonstration that the layering works, not a system that stays honest by itself.

## What is written down

| document | what it is for |
| --- | --- |
| [`docs/contract.md`](docs/contract.md) | What is being related, per configuration; the proposed `.eos` annotation fields (not accepted by the compiler today) |
| [`docs/plan.md`](docs/plan.md) | Ordered deliverables H0–H5 with completion checks, and why H5 now precedes H4 |
| [`docs/generality.md`](docs/generality.md) | The dependency boundary and what growth costs — question (B) |
| [`docs/lean-smt.md`](docs/lean-smt.md) | The baseline-reconstruction assessment and its L0–L5 plan — question (A) |
| [`docs/ledger.md`](docs/ledger.md) | Per-sort and per-symbol status, semantic boundaries, inspected revisions, and every measurement above |
| [`Instances/README.md`](Instances/README.md) | What an instance is, and why it is outside this package's build |

## Running the checks

The package itself has no external Lake dependencies:

```bash
cd tools/hermeneia
lake build
```

The CPC instance imports a neighbouring Logos checkout, so it is outside that
build and has its own script:

```bash
Instances/check-cpc.sh <path-to-logos-checkout>          # bridge + conditional example
Instances/check-cpc.sh --full <path-to-logos-checkout>   # also the real discharge
```

`--full` needs roughly 15 GB free in that checkout's `.lake/`; see
[`Instances/README.md`](Instances/README.md).

## The name

*Hermeneia* (Greek **ἑρμηνεία**, "interpretation") names the act of carrying
meaning from one account into another. Here the two accounts are the embedded
SMT-LIB semantics and Lean's native logic.

The name and this scope were already paired in [Ynoia's name register][names].
This directory starts that project in Eudaimonia. At launch, the consulted
register still lists it as reserved; recording its new home there remains a
separate update in Kanon's tree.

## An island

Hermeneia follows the ecosystem's [child-project policy][policy]. It reads the
parent and neighboring projects and writes only inside `tools/hermeneia/`.
It imports nothing from Eudaimonia, and Eudaimonia imports nothing from it.
It is outside the parent's build, CI, generated artifacts and documentation
index. Deleting this directory changes none of them.

Its account is additive. The existing semantics remains the authority for the
embedded side; disagreements are findings to explain, not changes this project
can impose. Candidate feedback stays here until a person carries it through
the parent's reporting process. Hermeneia has no separate correspondence
channel and speaks on no other project's behalf.

## Endings

**Started 2026-09-16 by explicit maintainer instruction**, and everything above
dates from that day. [Status](#status) is the current inventory; this section is
only about how the project can end.

No dependency on this project has been introduced anywhere, and the instance is
outside this package's build, so retiring it costs nothing.

A person decides whether the project **graduates** into its own repository,
is **folded** into its parent, or is **retired in place** with a note recording
what was learned. A proposal to put its output on another project's build path
requires revisiting its island status. Any delivery that changes these
boundaries is recorded here with the promotion decision and who holds it.

[checker]: ../../templates/pkg/Proofs/Checker.lean.in
[proposal]: https://github.com/ajreynol/kanon/blob/4c4a78ae23c424e4fb6cc5e1cc8c4c3a4cec2f76/tools/ynoia/why-eunoia.md#hermeneia--from-the-embedded-semantics-to-leans-own-logic
[work]: https://github.com/ajreynol/kanon/blob/4c4a78ae23c424e4fb6cc5e1cc8c4c3a4cec2f76/tools/ynoia/tools.md#hermeneia--from-the-embedded-semantics-to-leans-own-logic
[names]: https://github.com/ajreynol/kanon/blob/4c4a78ae23c424e4fb6cc5e1cc8c4c3a4cec2f76/tools/ynoia/names.md#reserved-and-free-to-take
[policy]: https://github.com/ajreynol/kanon/blob/main/docs/policy.md#research-projects
[lean-smt]: https://github.com/ufmg-smite/lean-smt
