# The partition

How the per-rule numbers are made disjoint, what decides the attribution, and
how to read a point on the scatter.

## Why reach was not enough

`cpc-rule-loc.py` reports, for each rule, the transitive import closure of its
correctness proof. It is careful to say what that is not:

> neither of which is a partition -- shared code is counted once per rule that
> pulls it in

The consequence is large. The 591 reaches sum to 12.6 million lines over a
634,388-line layer: every line is counted, on average, twenty times. That is
the right answer to *what does this rule's proof depend on*. It is the wrong
answer to *what does this rule cost*, and it distorts in a specific direction —
a rule sitting on a big shared base looks expensive whether or not it added
anything to it. The rule with the largest reach is not necessarily the rule
that was most work; it is the rule with the largest dependency cone.

## What replaces it

The same move `cpc-loc-summary.py` makes to turn overlapping closures into
disjoint buckets: fix a priority order, walk it, and let each claimant take
only what nobody ahead of it has taken.

```
for each rule R, in coreness order:
    cone(R) = import closure of Cpc.Proofs.Rules.R,  restricted to the layer
    own(R)  = cone(R) - everything already claimed
    claimed = claimed ∪ own(R)
```

Every file in the layer is claimed by exactly one rule — the most core rule
that reaches it. Shared support lands on that rule, and every later rule
reports only what it adds on top. The columns are disjoint and sum to the
layer.

The same order partitions the checker's rule code: `__eo_prog_<rule>` plus the
helper definitions it calls, first claim wins. That is the other axis.

## What is in the layer, and what is not

The partition covers **bucket (f) of `cpc-loc-summary.py` and nothing else** —
the proofs of proof-rule correctness, 634,388 lines across 771 files.

Excluded entirely, because upstream makes them their own categories and they
are not any rule's cost:

| excluded | what it is |
| -------- | ---------- |
| (a) | smt-model-eval type preservation |
| (b) | canonicity theorem |
| (c) | translation type preservation |
| (d) | non-vacuity |
| (e) | closedness / evaluation invariance |
| (g) | the top-level soundness theorem, and the API restatement |
| (1) (2) (3) | the definition of satisfiability, the checker, the parser |

Attributing the central theorems to rules would bury the thing being looked
for: they are the fixed foundation the whole development rests on, they are
8.3% of the proof, and charging a share of them to `And_intro` would say
nothing true about `And_intro`.

Three files of bucket (f) are reached by no rule at all — `Proofs/CheckerCore`,
`Proofs/CheckerState` and `Proofs/Invariants/Stability`, 2,816 lines of checker
scaffolding that `Checker.lean` imports directly. They are reported as
**unattributed** rather than folded into a rule, and the run reconciles
partitioned + unattributed against the layer total. That check is the
guarantee: if `euthyna_lean.py`'s bucket attribution ever drifts from
`cpc-loc-summary.py`'s, the numbers stop summing and `rule-partition.py` fails
rather than reporting a plausible wrong answer.

## The coreness order

The partition is a function of `analysis/rule-order.txt`. It is a decision, not
a measurement, so it is written down where it can be argued with.

**Seeded once**, on 2026-08-31:

1. entries 1–164: the rules of Logos's own `core-rules.txt`, in that file's
   order. It is curated — it opens `scope`, `process_scope`, `ite_eq`, `split`,
   `resolution` — and is the best available statement of what CPC considers
   fundamental. Euthyna does not second-guess it.
2. entries 165–591: every remaining rule by ascending cone size, then by
   name. A rule that depends on less is more foundational, so the smallest cone
   claims the shared base and later rules report only their increment.

**Append-only after that.** New rules go on the end, alphabetically. Departed
rules come out. Nothing is ever moved.

That discipline is the whole reason the order is maintained here rather than
recomputed per run. If positions could shift, a rule's partitioned size could
change without a line of its proof changing, and a series of snapshots would
measure the ordering rather than the proof. The cost is real and worth stating:
a genuinely fundamental rule added next year still sorts last, and so claims
nothing an existing rule already holds. Stability is worth more than freshness
here, and `rule-order.py seed --force` is the deliberate, dated escape hatch
for the day it is not.

```
euthyna rules check     # drift against a Logos checkout; exit 1 if any
euthyna rules update    # append the new, remove the departed
```

`euthyna measure` runs the check first and warns, but measures anyway: a
snapshot with a noted gap beats no snapshot.

## Reading a point

The scatter (`rules.html`, drawn by `plot-rules.py`) puts one point per rule,
lines of rule on x, lines of proof on y, both logarithmic.

- **Above the diagonals** — little rule, much proof. The rule is easy to state
  and hard to prove. `Arrays_ext` is five lines of rule and 7,965 of proof.
- **Below them** — more rule than proof. The implementation carries the work
  and the proof follows cheaply. `Chain_resolution` is 44 lines of rule and 20
  of proof.
- **The dashed diagonals** are constant proof-per-line-of-rule: 1×, 10×, 100×,
  1000×. On log axes a ratio is a distance, so "how hard is this to prove for
  its size" is something you can see rather than compute.

Two cautions, both of which follow from the partition being a partition:

- **A rule's y is not a property of the rule alone.** It is what the rule adds
  *given everything more core than it*. `Chain_resolution` claims 20 lines not
  because its proof is 20 lines but because `Resolution`, four places ahead of
  it, already claimed what they share. Read the pair, not either number alone.
- **The order's first entries absorb the shared base**, so early positions look
  expensive by construction. `Scope`, first in the order, claims 1,412 lines. That is
  the mechanism working, not a finding about `Scope`.

Colour carries nothing on the chart. Seven theory families would need seven
categorical hues, and a scatter is an all-pairs form where the palette in use
validates three; the families are small multiples instead. The family grouping
is a rule-name prefix heuristic and is labelled as one on the page.
