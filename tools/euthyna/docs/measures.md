# Measures

The catalogue. Eight measures come from Logos and are run unedited, one is
Euthyna's own, and the derived metrics below them are computed from all of
their output by `analysis/derive.py`.

`bin/euthyna measures` prints the first table's live version.

## The catalogue

Eight rows are Logos's own scripts, run unedited. The bolded row is
Euthyna's.

| measure | script | needs | reports |
| ------- | --------------- | ----- | ------- |
| `rule-status` | `classify-rule-status.py Cpc` | source | Every rule, classified `Proven` / `Unproven` / `OutOfScope`, by a recursive scan of `cmd_step_<rule>_properties` and `__eo_prog_<rule>` for proof gaps (`sorry`, `admit`, `sorryAx`, `axiom`). TSV, with a summary block. |
| `core-rule-status` | `classify-core-rule-status.sh` | source | The same, restricted to the core rules named in `core-rules.txt` — the subset a calculus is expected to have before anything else. |
| `rule-loc` | `cpc-rule-loc.py --csv` | source | Per rule: `proof_loc` and `proof_files`, the transitive reach of its correctness proof excluding the lower proof layers and the definitional base; and `eo_prog_loc` / `eo_prog_defs`, the size of the `__eo_prog_` implementation it is proven about. Neither column is a partition. |
| `rule-partition` | **Euthyna's** `analysis/rule-partition.py` | source | Per rule, the **partitioned** proof size and rule size: every file of the rule-proof layer claimed by the most core rule that reaches it, so both columns are disjoint and sum to their layer. Excludes the central theorems entirely. Reconciles against bucket (f) or fails. See [partition.md](partition.md). |
| `loc-summary` | `cpc-loc-summary.py --files --deps` | source | The whole development divided into four pieces — the definition of satisfiability, the checker, the parser, the proof — with the proof further split into seven **disjoint** buckets by priority attribution, so they sum to the whole. Plus the per-file listing and the inter-bucket dependency edges. |
| `proof-hygiene` | `check-proof-hygiene.sh` | source | Fails if any standalone `sorry`, `admit`, or `axiom` token appears anywhere under `Cpc` or `CpcMini`, comments included. Reports how many files were scanned. |
| `proof-modularity` | `check-proof-modularity.sh` | source | Six invariants of the checker layer: that `Cpc` and `CpcMini` share one copy of each common file, that `Checker.lean` names no rule or operator or calculus-specific invariant, that `CheckerState.lean` carries no invariant, that the checker layer depends on exactly one operator, and that it names no generated arm by number. |
| `rule-style` | `check-rule-style.sh` | source | That no top-level rule file imports another rule file — shared declarations belong in `RuleSupport`. |
| `checker-soundness` | `check-checker-soundness.sh Cpc` | **build** | That `Proofs/Checker.lean` and `ApiCorrect.lean` elaborate against an already-built `CheckerCore`, with the two bridge theorems from `RuleLemmas.lean` stubbed. Closes the gap left by CI, which cannot afford the two-hour full rule build. Skipped unless `--build` is given. |

`needs: source` means the measure reads source text and nothing else, which is
why a full run is fifteen seconds rather than two hours.

### Snapshotted but not run

`analysis/upstream/` holds the **whole** of Logos's `scripts/` directory — all
seventeen files — not just the nine the catalogue names. Which scripts measure
a proof is a judgement that will change as Euthyna asks better questions; which
scripts existed at a Logos commit is a fact, and the fact is the thing worth
keeping. Widening the catalogue later should not require going back through
history to find what a script looked like.

The eight not in the catalogue: `build.sh`, `build-cpc-rule.sh`,
`build-all-cpc-rules.sh`, `clean-build.sh`, `lean-toolchain-env.sh` and
`run-ci.sh` drive builds and CI; `bump-eoc-version.py` moves a compiler pin.
None of them measures a proof.

`check-parser-tables.py` is the near miss: it checks a generated parser table
against the signature it came from. That is a real consistency measure, and it
is about *generation*, not about proof. If Euthyna later asks what the
signature-to-artifact seam costs, it belongs in the catalogue; today it would be
a number with no question attached.

## The partition, and the two axes

`rule-partition` is Euthyna's answer to the one thing upstream says plainly it
does not do. `cpc-rule-loc.py` reports transitive *reach*, which counts shared
support once per rule that touches it and sums to twenty times the layer; the
partition gives each file to the most core rule that reaches it, so the columns
are disjoint and sum to the layer exactly.

| column | what it is |
| ------ | ---------- |
| `proof_loc` | lines of the rule-proof layer this rule claims — its share, not its cone |
| `proof_files` | files it claims |
| `rule_loc` | lines of `__eo_prog_<rule>` and the helpers it claims |
| `rule_own_loc` | lines of `__eo_prog_<rule>` alone |
| `proof_reach_loc` | the old reach figure, kept alongside so the two can be compared |
| `order` | the rule's position in the coreness order |

`rule_loc` and `proof_loc` are the axes of the scatter. Everything about how
the attribution is decided, why the order is append-only, and how to read a
point is in [partition.md](partition.md).

## Derived metrics

These are Euthyna's. They exist because the vendored measures each answer one
question and stop, and the question Euthyna is actually asking — what is this
proof *shaped* like — is not any one of theirs. Definitions are in
`analysis/derive.py`, which reads only the measures' output.

### floor

The smallest `proof_loc` of any rule.

Every rule's correctness proof transitively reaches at least this much, so the
floor is the fixed cost of stating *any* rule proof at all: the shared rule
support and the checker scaffolding it is written against. It is measured
rather than asserted, and the rule that attains it is reported, because that
rule is by construction the cheapest possible proof in this development and a
good place to look at what the fixed cost consists of.

### surplus

`proof_loc − floor`, per rule.

The part of a rule's proof reach that is about *that rule*. This is the number
a generality argument has to move: the floor is paid once for the whole
development, the surplus is paid 591 times. Reported as median, total, and the
fifteen heaviest rules.

Still reach-based, so still not authorship: a rule's surplus includes support
files shared with a few other rules but not with all of them.

### concentration (`top_decile_share`)

The share of total surplus held by the heaviest tenth of rules.

A development where the cost is flat and one where a handful of rules carry it
are different problems with different remedies, and the median alone cannot
tell them apart.

### leverage

`sum of all proof_loc` divided by the size of the rule-proof bucket `(f)`.

Per-rule reach double-counts everything shared, so this ratio is how many
times the average line of the rule layer is reached across the 591 rules. It
reads two ways at once, and both are worth having: high leverage means the
shared support is doing a great deal of work, and it means a change to that
support is felt everywhere.

Reported alongside `marginal_lines_per_rule` — the rule layer's actual size
divided by the rule count — which is the honest per-rule figure that reach is
not.

### proof per prog line

Median of `proof_loc / eo_prog_loc`.

What one line of checker costs in lines of proof reached. A crude price, and
the only measure here that puts the proof next to the thing it is about.

## Gaps

What is not measured yet, in roughly the order it matters. Each is a line in
[roadmap.md](roadmap.md).

- **Authorship, not reach.** Partly answered. `rule-partition` gives each rule
  a disjoint share, which is much closer to cost than reach was. It is still
  not authorship: a rule's share is what it adds *given the order*, so the
  first rule to touch a support file carries all of it. Splitting a rule file's
  own lines from the support it is the first to claim is the remaining step.
- **Calculus-independence.** Nothing yet asks which lines of the proof mention
  a CPC-specific operator and which would survive a different signature. That
  is the generality question stated as a measurement, and it is the one this
  project exists to answer.
- **Naming an operator is not depending on it**, and the one measure that looks
  at operators cannot tell the two apart. `check-proof-modularity.sh` reports
  the checker layer's operator dependency by collecting `UserOp.<name>` out of
  the core files and asserting the set is exactly `{and}`. It is counting
  *names*.

  Logos `43732cc5`, "Make core checker independent of definition of `and`",
  landed between the 2026-08-31 and 2026-09-02 snapshots and changed thirteen
  files across both packages. **The measure did not move**: `Cpc: and` and
  `CpcMini: and`, byte-identical output either side of it. Both readings are
  correct. The checker no longer relies on what `and` *means*, and it still
  names `UserOp.and` — through `argListAssumes` and the state folds — so a
  grep for the name still finds it.

  This is a caution about the measurement iteration 2 proposes rather than a
  defect in the vendored check, which asks its question honestly and answers it.
  **A name-based classification of the proof will over-report calculus
  dependence**, and the size of the gap is unknown: here it is the difference
  between *changed* and *did not change* on the single most-watched dependency
  in the development. See [roadmap.md](roadmap.md#iteration-2--calculus-independence).
- **The order's leading positions.** By construction the earliest rules absorb
  the shared base, so their partitioned size says more about the order than
  about them. A measure that reports how much of a rule's claim is *unshared*
  — reached by it and nothing else — would separate the two.
- **Time.** One snapshot exists. Every metric here becomes more useful as a
  series, and the harness is built to produce one.
- **Elaboration cost.** All of this is text. Build time per rule, and where it
  goes, is a different and possibly more actionable measure of weight.
- **Tactic and proof-term shape.** Lines are a poor proxy for what a proof
  does. Nothing here distinguishes generated bulk from hand-written argument.
