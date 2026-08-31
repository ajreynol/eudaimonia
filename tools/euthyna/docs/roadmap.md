# Roadmap

Where this goes. Two ends, and the work that reaches them.

**Visualization**, because the interesting facts about this proof are
distributional and structural, and a table of quantiles is a poor way to see a
distribution or a dependency cone.

**Actionable generality**, because the point of understanding what Logos's
proof is made of is to say which specific changes would let more of it hold
for a calculus that is not CPC — which is the thing Eudaimonia is trying to
do, and the only sense in which this island connects to the mainland.

The baseline says the whole question sits in one number: 91.7% of the proof is
rule correctness, so 8.3% is what a second calculus plausibly inherits.
Everything below is either a better estimate of that number or a way to move
it.

## Iteration 1 — authorship

*Blocks nearly everything else.* Every figure in the baseline is transitive
reach: a rule's dependency cone, with all shared support counted again for
every rule that touches it. The single most useful number about a rule — how
many lines were written *for it* — does not exist yet.

- Own-file LOC per rule, separated from imported support.
- Attribute shared support files to the set of rules that reach them, so
  "shared by 400 rules" and "shared by 3" stop looking alike.
- Restate surplus and concentration on the authorship basis and compare to
  the reach basis. Where the two orderings disagree is where reach is
  misleading, and that disagreement is itself a finding.

## Iteration 2 — calculus-independence

*The project's central measurement.* Which lines of the proof would survive a
different signature?

- Classify every proof file by whether it names a CPC operator, a CPC rule, or
  a CPC-specific invariant. `check-proof-modularity.sh` already does this for
  seven hand-written checker files and finds exactly one operator dependency
  (`and`); the same question over all 820 proof files is a much larger and
  much more interesting answer.
- Separate *generated* proof text from hand-written. The distinction matters
  more than volume: generated bulk is a compiler's output and moves with the
  compiler, hand-written argument moves only with a person.
- Produce the refined inheritance estimate: not "8.3% is not rule
  correctness" but "N% of the proof mentions nothing calculus-specific".
- Test it against the cheap rules. Half the rules have surplus under 5,000. If
  those are also the calculus-independent ones, the boundary is in a
  convenient place; if not, that is the more important result.

## Iteration 3 — cost that is not lines

Lines are a proxy and a poor one. Two measures that are not:

- **Elaboration time per rule**, from a full build. Expensive to collect —
  the rule build is over two hours — so it is a per-release measure, not a
  per-commit one. `check-checker-soundness.sh` is already vendored and is the
  build-needing measure the harness is shaped around.
- **Proof-term shape**: tactic mix, term size, depth. What distinguishes a
  proof that a tactic found from one that a person constructed, which is the
  distinction "lines" cannot see.

## Iteration 4 — series

One snapshot describes; a series explains. The harness already produces
comparable snapshots and keeps them in git for exactly this.

- `euthyna diff <a> <b>`: what moved between two snapshots, and which rules
  moved it.
- Backfill: run the current measures over historical Logos commits, so the
  series starts before Euthyna did. Cheap — fifteen seconds a commit, and no
  build.
- Watch the derived metrics rather than the totals. A rising floor with flat
  surplus and a rising surplus with a flat floor are opposite situations that
  a line count reports identically.

## Visualization

Deliberately last in build order and first in importance. `summary.json` is
already the feed; nothing is drawn yet, and nothing should be until iterations
1 and 2 give it something worth drawing.

What the baseline says is worth drawing:

- **The distribution.** 591 rules, surplus on a log axis, floor marked. The
  long tail is the finding and a table of quantiles hides it.
- **The layer diagram**, sized by lines and wired by the dependency edges the
  `--deps` output already gives. Seven boxes where one of them is 91.7% of the
  area is a picture that makes its own argument.
- **The rule map**, rules grouped by theory (bitvectors, strings, quantifiers,
  arithmetic, core), area by cost, shaded by calculus-independence once
  iteration 2 can shade it. This is the artifact the project is really for:
  the picture that shows where the weight is and which of it is portable.
- **The series**, once there is one.

House rules when it comes to that: everything readable in both light and dark,
no chart that a table would say better, and every visual claim traceable to a
snapshot file. A chart here is a claim about somebody's proof and it should be
as checkable as the numbers under it.

## Not doing

Worth writing down, so it is not rediscovered as an idea.

- **Not editing the vendored scripts.** Anything Euthyna needs and upstream
  does not provide goes in `analysis/derive.py` against their output. See
  [method.md](method.md#the-vendoring-discipline).
- **Not proposing changes to Logos here.** Euthyna measures and reads. A
  finding that suggests work belongs in a conversation with Logos, in Logos's
  terms; a research directory in an unrelated repository is not where somebody
  else's proof gets reorganized.
- **Not coupling to Eudaimonia.** No shared code, no shared CI, no
  cross-links. The connection is what is learned, and it travels as prose.
