# Measures

The catalogue. Eight measures come from Logos and are run unedited; the
derived metrics below them are Euthyna's, computed from those measures' output
by `analysis/derive.py`.

`bin/euthyna measures` prints the first table's live version.

## Vendored measures

| measure | upstream script | needs | reports |
| ------- | --------------- | ----- | ------- |
| `rule-status` | `classify-rule-status.py Cpc` | source | Every rule, classified `Proven` / `Unproven` / `OutOfScope`, by a recursive scan of `cmd_step_<rule>_properties` and `__eo_prog_<rule>` for proof gaps (`sorry`, `admit`, `sorryAx`, `axiom`). TSV, with a summary block. |
| `core-rule-status` | `classify-core-rule-status.sh` | source | The same, restricted to the core rules named in `core-rules.txt` — the subset a calculus is expected to have before anything else. |
| `rule-loc` | `cpc-rule-loc.py --csv` | source | Per rule: `proof_loc` and `proof_files`, the transitive reach of its correctness proof excluding the lower proof layers and the definitional base; and `eo_prog_loc` / `eo_prog_defs`, the size of the `__eo_prog_` implementation it is proven about. Neither column is a partition. |
| `loc-summary` | `cpc-loc-summary.py --files --deps` | source | The whole development divided into four pieces — the definition of satisfiability, the checker, the parser, the proof — with the proof further split into seven **disjoint** buckets by priority attribution, so they sum to the whole. Plus the per-file listing and the inter-bucket dependency edges. |
| `proof-hygiene` | `check-proof-hygiene.sh` | source | Fails if any standalone `sorry`, `admit`, or `axiom` token appears anywhere under `Cpc` or `CpcMini`, comments included. Reports how many files were scanned. |
| `proof-modularity` | `check-proof-modularity.sh` | source | Six invariants of the checker layer: that `Cpc` and `CpcMini` share one copy of each common file, that `Checker.lean` names no rule or operator or calculus-specific invariant, that `CheckerState.lean` carries no invariant, that the checker layer depends on exactly one operator, and that it names no generated arm by number. |
| `rule-style` | `check-rule-style.sh` | source | That no top-level rule file imports another rule file — shared declarations belong in `RuleSupport`. |
| `checker-soundness` | `check-checker-soundness.sh Cpc` | **build** | That `Proofs/Checker.lean` and `ApiCorrect.lean` elaborate against an already-built `CheckerCore`, with the two bridge theorems from `RuleLemmas.lean` stubbed. Closes the gap left by CI, which cannot afford the two-hour full rule build. Skipped unless `--build` is given. |

`needs: source` means the measure reads source text and nothing else, which is
why a full run is fifteen seconds rather than two hours.

### Not vendored, and why

Logos's `scripts/` also holds `build.sh`, `build-cpc-rule.sh`,
`build-all-cpc-rules.sh`, `clean-build.sh`, `lean-toolchain-env.sh`,
`run-ci.sh`, `bump-eoc-version.py`, and `check-parser-tables.py`. The first
six drive builds and CI; `bump-eoc-version.py` moves a compiler pin. None of
them measures a proof.

`check-parser-tables.py` is the near miss: it checks a generated parser table
against the signature it came from. That is a real consistency measure, and it
is about *generation*, not about proof. If Euthyna later asks what the
signature-to-artifact seam costs, it belongs here; today it would be a number
with no question attached.

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

- **Authorship, not reach.** No measure separates a rule file's own lines from
  the shared support it pulls in. Everything above is transitive-closure
  arithmetic, and the most useful single number — what a new rule actually
  costs to write — is still missing.
- **Calculus-independence.** Nothing yet asks which lines of the proof mention
  a CPC-specific operator and which would survive a different signature. That
  is the generality question stated as a measurement, and it is the one this
  project exists to answer.
- **Time.** One snapshot exists. Every metric here becomes more useful as a
  series, and the harness is built to produce one.
- **Elaboration cost.** All of this is text. Build time per rule, and where it
  goes, is a different and possibly more actionable measure of weight.
- **Tactic and proof-term shape.** Lines are a poor proxy for what a proof
  does. Nothing here distinguishes generated bulk from hand-written argument.
