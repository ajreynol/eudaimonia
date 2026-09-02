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

## Iteration 1 — authorship  *(partly done)*

**Done:** `rule-partition.py` replaces reach with a disjoint share. Every file
of the rule-proof layer is claimed by the most core rule that reaches it, the
columns sum to the layer, and the run fails if they do not. The correction is
large — the median rule claims 315 lines where its reach was 15,400 — and it
reorders the heavy tail: `Bv_extract_mult_leading_bit` led on reach and does
not appear in the top seven on share.

**Still open**, and these are what "authorship" would actually mean:

- **Own lines versus first-claimed support.** A rule's share bundles its own
  file with whatever support it happened to reach first. Splitting the two
  gives the number a rule author would recognise.
- **Sharing degree per file.** Attribute each support file to the *set* of
  rules that reach it, so "shared by 400 rules" and "shared by 3" stop looking
  alike. The partition currently flattens that to a single claimant.
- **Unshared claim.** How much of a rule's share is reached by it and nothing
  else — the part that is unambiguously its own, independent of the order.
  This is the measure that would let the order's leading positions be read
  fairly.

## Iteration 2 — calculus-independence

*The project's central measurement.* Which lines of the proof would survive a
different signature?

- Classify every proof file by whether it names a CPC operator, a CPC rule, or
  a CPC-specific invariant. `check-proof-modularity.sh` already does this for
  seven hand-written checker files and finds exactly one operator dependency
  (`and`); the same question over all 820 proof files is a much larger and
  much more interesting answer.
- **And then stop trusting it, because names are not dependence.** Logos
  `43732cc5` made the core checker independent of the definition of `and` and
  the name-counting measure reported the identical result either side of it —
  the checker still writes `UserOp.and`, through `argListAssumes` and the state
  folds, having stopped relying on what it means. Measured, not argued:
  `proof-modularity.txt` is byte-identical between the 2026-08-31 and
  2026-09-02 snapshots. So the classification above is an **upper bound** on
  calculus dependence and should be reported as one. Narrowing it means asking
  what a proof *uses* rather than what it writes — whether the definition is
  unfolded, whether a lemma about the operator is applied — and that is a
  question about elaborated terms, which is [iteration 3](#iteration-3--cost-that-is-not-lines)
  arriving early and for a different reason.
- Separate *generated* proof text from hand-written. The distinction matters
  more than volume: generated bulk is a compiler's output and moves with the
  compiler, hand-written argument moves only with a person.
- Produce the refined inheritance estimate: not "8.3% is not rule
  correctness" but "N% of the proof mentions nothing calculus-specific".
- Test it against the scatter's two corners. The baseline finds them different
  in kind: the expensive corner is semantic (`Arrays_ext`, `Cong`,
  `Instantiate` — extensionality, congruence, instantiation) and the cheap one
  is syntactic (chained resolution, concat pull-ups). The semantic corner is
  where a calculus-independent argument would pay off most, because those
  rules are about equality and instantiation rather than about CPC. Whether
  that intuition survives measurement is the test.

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

**Done:** the rule scatter. `plot-rules.py` draws partitioned proof size
against partitioned rule size, one point per rule, both axes logarithmic, with
constant-ratio diagonals so "hard to prove for its size" is a distance rather
than a computation. Small multiples by theory family sit under it, and a table
view carries the same data for anyone the chart does not serve. It is a
standalone HTML file, self-contained, light and dark, regenerated by
`euthyna plot`.

Still to draw, in the order the findings justify:

- **The layer diagram**, sized by lines and wired by the dependency edges the
  `--deps` output already gives. Seven boxes where one is 91.7% of the area is
  a picture that makes its own argument, and it is the fastest way to explain
  why the generality question is what it is.
- **Calculus-independence shading** on the scatter, once iteration 2 can
  compute it. This is the artifact the project is really for: the same points,
  coloured by whether they would survive a different signature. It is also the
  one place a second colour dimension is worth the cost — and it should be a
  two-value distinction or a sequential ramp, not seven categorical hues.
- **The series**, once there is one: the same scatter with points moving, or
  the derived metrics over time.

House rules when it comes to that: everything readable in both light and dark,
no chart that a table would say better, and every visual claim traceable to a
snapshot file. A chart here is a claim about somebody's proof and it should be
as checkable as the numbers under it. The scatter follows them — its subtitle
names the commit it was drawn from, and every number on it is in
`rule-partition.csv` beside it.

## Not doing

Worth writing down, so it is not rediscovered as an idea.

- **Not editing the vendored scripts.** Anything Euthyna needs and upstream
  does not provide goes beside them in `analysis/`, against their output. The
  one restatement of upstream logic, in `euthyna_lean.py`, is held in place by
  a reconciliation check rather than by good intentions. See
  [method.md](method.md#the-vendoring-discipline).
- **Not reordering `rule-order.txt`.** Append and delete only. A reordering
  changes every partitioned number without a line of proof changing, and makes
  snapshots either side of it incomparable. See
  [partition.md](partition.md#the-coreness-order).
- **Not proposing changes to Logos here.** Euthyna measures and reads. A
  finding that suggests work belongs in a conversation with Logos, in Logos's
  terms; a research directory in an unrelated repository is not where somebody
  else's proof gets reorganized.
- **Not coupling to Eudaimonia.** No shared code, no shared CI, no
  cross-links. The connection is what is learned, and it travels as prose.
