# Hermeneia

A **child project** of the Eudaimonia build framework: a correspondence between
the embedded SMT-LIB semantics and Lean's own logic, so that a theorem about an
embedded formula can become a theorem about the values and propositions a Lean
development uses.

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

## Initial technical work

The [correspondence contract](docs/contract.md) accounts for the configurable
calculus translation, SMT evaluation and native backend definitions. It spells
out what it means for `Term.Numeral n` to denote Lean's `n : Int`, and proposes
native-meaning and proof fields that could eventually accompany `.eos` entries.
These are proposed fields; the existing compiler does not accept them.

The [implementation plan](docs/plan.md) gives ordered deliverables and completion
checks. The [ledger](docs/ledger.md) records inspected sources, semantic
boundaries, and the distinction between source observations and proved coverage.

A standalone [Lean contract experiment](Hermeneia/Contract.lean) checks literal
and operation interfaces and proves generic refutation transfer. Its
[synthetic checks](Hermeneia/Checks.lean) prove that changing literal meaning,
translation or addition breaks the fixed correspondence, and that a vacuous
model class cannot support every native assignment. Run it independently:

```bash
cd tools/hermeneia
lake build
```

It has no external Lake dependencies, and it does not by itself certify any
Logos fragment.

Beside it, [`Instances/CpcMini/`](Instances/CpcMini/Refutation.lean) is the
first configuration that does compose with checker soundness. A refutation in
Logos's CpcMini calculus is checked by reflection, carried through CpcMini's
proved `correct___eo_is_refutation`, and turned into a proposition about Lean
`Bool`s — with no `sorry` and no open soundness hypothesis. It imports a
neighbouring Logos checkout, so it stays outside this package's build and is run
by its own script:

```bash
Instances/CpcMini/check.sh <path-to-logos-checkout>
```

See [`Instances/README.md`](Instances/README.md) for what an instance is and
why these are not in `lakefile.toml`. What it establishes and what it does not
is in [the ledger](docs/ledger.md#what-the-instance-has-checked): one calculus,
one constant, no `Int`, no operation law, no fragment reached by induction.

[`docs/lean-smt.md`](docs/lean-smt.md) asks what this would have to reach to be
useful to [lean-smt][lean-smt] as a **baseline proof reconstruction** — one
uniform justification for any CPC proof, in place of its per-rule replay. It
records what was measured — reflection on a 2244-command proof costs nothing
over running the checker, and twelve solver-produced CPC proofs under lean-smt's
own options all check ([`probes/cpc-coverage/`](probes/cpc-coverage/README.md),
rerunnable) — what blocks kernel reduction, and where the difficulty actually
is: not the 591 rules, but three narrowed sorts. It is a proposal to a project
that has not been asked, and nothing depends on it.

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

## Status and endings

**Started 2026-09-16 by explicit maintainer instruction.** This README is the
initial charter. The configurable-semantics contract, initial plan, source
ledger and standalone Lean interface experiment are present. Generic transfer
and synthetic rejection proofs compile.

Since launch, on the same day: the first concrete instance composes with a real
checker soundness theorem and yields a native Lean proposition, for CpcMini and
one Boolean constant; and [`docs/lean-smt.md`](docs/lean-smt.md) records what a
baseline reconstruction for lean-smt would take. A `Cpc` instance, `Int`, any
operation law, and a refutation of a solver-produced proof remain open. No
dependency on this project has been introduced, and the instance is outside this
package's build.

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
