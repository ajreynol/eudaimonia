# Baseline

The first measurement. Logos at `373d56c5bb24`, measured 2026-08-31. Snapshot
`data/snapshots/2026-08-31-373d56c5bb24-dirty/`.

The tree carried two untracked files (`ai-estimate.txt` and a regression input,
neither a Lean source under `Cpc`), so the snapshot is marked dirty and is not
exactly reproducible. Nothing measured here depends on either.

Every number below is from that snapshot; `bin/euthyna show` reprints the
report it came from. What the numbers mean is in [measures.md](measures.md);
what they are *not* evidence of is in [method.md](method.md#what-these-numbers-are-not).

## Status

| | rules | proven | unproven | out of scope |
| --- | ---: | ---: | ---: | ---: |
| all | 591 | 591 | 0 | 0 |
| core | 164 | 164 | 0 | 0 |

Every rule is proven, and no source file under `Cpc` or `CpcMini` contains a
`sorry`, an `admit`, or an `axiom` — 872 files scanned. All three structural
checks pass: the checker layer is calculus-agnostic, `Cpc` and `CpcMini` share
one copy of each of their six common files, and no rule file imports another.

`checker-soundness` was skipped: it needs a built Logos. So this snapshot does
not establish that the soundness proof elaborates, only that nothing under
`Cpc` is proven by escape hatch.

This is the useful shape of the baseline. Logos is not a development with holes
in it, and no measure here is going to find one. The interesting question is
not *whether* it is proven but *what the proof is made of*, and that is where
the rest of this goes.

## Extent

| piece | lines | files |
| ----- | ----: | ----: |
| (1) definition of `eo_satisfiability` | 2,680 | 6 |
| (2) proof checker | 8,573 | 3 |
| (3) proof parser | 2,632 | 3 |
| (4) proof of correctness | **691,993** | 820 |

The parser splits 633 signature-independent to 1,999 generated. The proof is
262 times the size of the thing it is about.

Within the proof, the seven buckets are disjoint and sum to the whole:

| bucket | lines | share |
| ------ | ----: | ----: |
| (a) smt-model-eval type preservation | 19,832 | 2.9% |
| (b) canonicity theorem | 1,091 | 0.2% |
| (c) translation type preservation | 23,796 | 3.4% |
| (d) non-vacuity | 83 | 0.0% |
| (e) closedness / evaluation invariance | 8,204 | 1.2% |
| **(f) proof rule correctness** | **634,388** | **91.7%** |
| (g) top-level checker correctness | 4,599 | 0.7% |

with the dependency order `defs → (a) → (b), (c), (d) → (e) → (f) → (g)`.

**Nine tenths of this proof is rule correctness.** Everything else — the
type-preservation foundation, canonicity, translation, closedness, the
top-level soundness theorem that ties it together — is 57,605 lines, 8.3%.
That is the single most important fact in the baseline, and it sets what any
generality effort has to be about. The 8.3% is the part a second calculus
would plausibly inherit; the 91.7% is the part it would have to redo.

## Shape

Per-rule proof reach, over 591 rules:

```
min 9,494   p25 10,720   median 15,400   p75 21,186   max 124,076
```

The derived metrics:

| metric | value | |
| ------ | ----: | --- |
| floor | 9,494 | lines every rule proof reaches (attained by `And_intro`) |
| surplus, median | 5,906 | lines a rule adds over the floor |
| surplus, total | 7,007,602 | |
| top-decile share | 48.8% | of surplus, held by the heaviest 59 rules |
| leverage | 19.9× | times the average rule-layer line is reached |
| marginal per rule | 1,073 | lines of rule layer per rule |
| proof per prog line | 47.3× | median |

### The floor is most of the median rule

9,494 lines is 62% of the median rule's entire proof reach. The cheapest rule
in the development — `And_intro`, and it is hard to imagine a cheaper one —
still reaches nearly ten thousand lines of shared support and checker
scaffolding. That is the fixed cost of being a rule at all.

This cuts encouragingly. The fixed cost is paid once; it is the 8.3% plus the
shared support, and it is the part that a differently-shaped calculus has the
best chance of reusing.

### The variable cost is extremely skewed

| surplus under | rules |
| ---: | ---: |
| 500 | 95 |
| 1,000 | 133 |
| 2,000 | 173 |
| 5,000 | 292 |
| 10,000 | 410 |
| 50,000 | 552 |

Median surplus is 5,906 and mean is 11,857 — the mean is twice the median,
which is the signature of a long tail. The heaviest tenth holds 48.8% of all
surplus; the heaviest quarter holds 74.0%; the lighter half holds 6.8%
between them. Six rules hold 9.2%.

The heaviest, by surplus:

| rule | surplus |
| ---- | ----: |
| `Bv_extract_mult_leading_bit` | 114,582 |
| `Bv_mult_slt_mult_2` | 107,701 |
| `Bv_mult_slt_mult_1` | 107,701 |
| `String_reduction` | 105,516 |
| `Bv_bitblast_step` | 103,752 |
| `Quant_dt_split` | 103,046 |
| `Evaluate` | 102,433 |
| `Quant_var_elim_eq` | 96,748 |
| `Seq_eval_op` | 71,260 |
| `Str_in_re_consume` | 69,438 |

They are bitvectors, strings, quantifiers, and evaluation — theory reasoning,
not proof-calculus reasoning. And the two `Bv_mult_slt_mult` rules have
*identical* reach to the line, which means they share their entire support:
one body of work carrying two rules.

Half the rules are nearly free, given the floor. A tenth are enormous, and the
enormous ones cluster by theory. Those are two different problems and they
want two different answers — the light half is evidence the shared support
works, and the heavy tail is where the theory-specific reasoning lives.

### Leverage

The 591 per-rule reaches sum to 12.6 million lines over a 634,388-line rule
layer: every line of that layer is reached, on average, 19.9 times. The honest
marginal figure is the other one — 1,073 lines of rule layer per rule.

Both readings hold at once. The shared support is doing twenty times its own
weight in work. And a change to that support is felt by, on average, twenty
rules — which is exactly why `check-rule-style.sh` and
`check-proof-modularity.sh` exist and why they are checked rather than
documented.

### Price

The `__eo_prog_` implementations are small: median 280 lines, 251,336 across
all 591. The median rule's proof reaches 47 lines for every line of the
checker code it is about.

## Cost, partitioned

Everything above is reach. The `rule-partition` measure replaces it with a
disjoint share: every file of the rule-proof layer claimed by the most core
rule that reaches it, under the order in `analysis/rule-order.txt`. How the
attribution works and what it does and does not license is in
[partition.md](partition.md).

It reconciles exactly, which is the point of doing it this way:

```
631,572 partitioned  +  2,816 unattributed  =  634,388  (bucket (f))
```

The 2,816 unattributed lines are three files — `Proofs/CheckerCore`,
`Proofs/CheckerState`, `Proofs/Invariants/Stability` — that `Checker.lean`
imports directly and no rule reaches. They are checker scaffolding, not any
rule's cost, and are reported rather than folded in.

| | min | p25 | median | p75 | max | total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| lines of proof claimed | 18 | 154 | 315 | 557 | 55,045 | 631,572 |
| lines of rule claimed | 1 | 4 | 6 | 8 | 761 | 7,206 |

The median rule claims **315 lines of proof**. Against a median *reach* of
15,400, that is the size of the correction: 98% of what a rule's proof touches,
it shares with rules more core than itself.

Concentration is worse than reach suggested — the heaviest tenth holds **70.0%**
of all partitioned proof, against 48.8% of surplus. Partitioning moves weight
onto the rules that genuinely introduce it.

| rule | rule LOC | proof LOC | ratio |
| ---- | ---: | ---: | ---: |
| `Bv_bitblast_step` | 294 | 55,045 | 187× |
| `Instantiate` | 44 | 46,731 | 1,062× |
| `Str_in_re_consume` | 153 | 43,154 | 282× |
| `String_reduction` | 196 | 38,034 | 194× |
| `Cong` | 20 | 28,035 | 1,402× |
| `Evaluate` | 333 | 25,589 | 77× |
| `Aci_norm` | 79 | 22,569 | 286× |

## The scatter

`rules.html` in the snapshot, drawn by `euthyna plot`. Lines of rule on x,
lines of proof on y, both logarithmic, one point per rule.

The relationship is real but loose — Pearson *r* = 0.49 on the raw values, 0.56
on the logs. Bigger rules do cost more to prove, and the residual is where the
interest is: **proof per line of rule spans 0.45× to 1,593×, a 3,505-fold
spread, around a median of 58×.** Two rules of the same size can differ by
three orders of magnitude in what they cost to prove.

**Short rule, hard to prove** — the top-left corner:

| rule | rule LOC | proof LOC | ratio |
| ---- | ---: | ---: | ---: |
| `Arrays_ext` | 5 | 7,965 | 1,593× |
| `Arrays_read_over_write_1` | 3 | 4,437 | 1,479× |
| `Cong` | 20 | 28,035 | 1,402× |
| `Instantiate` | 44 | 46,731 | 1,062× |
| `Sets_choose_singleton` | 3 | 2,857 | 952× |

**Large rule, easy to prove** — the bottom-right:

| rule | rule LOC | proof LOC | ratio |
| ---- | ---: | ---: | ---: |
| `Chain_resolution` | 44 | 20 | 0.45× |
| `Chain_m_resolution` | 34 | 20 | 0.59× |
| `Bv_and_concat_pullup3` | 18 | 19 | 1.06× |
| `Bv_or_concat_pullup3` | 18 | 19 | 1.06× |

The two corners are different in kind, and that is the finding. The expensive
corner is **semantic**: extensionality, congruence, instantiation — rules whose
statement is three lines and whose justification reaches into the model theory.
The cheap corner is **syntactic**: chained resolution and bitvector
concatenation pull-ups, where the implementation does the work and the proof
follows it mechanically. Rule size does not predict proof cost; what the rule
has to *mean* does.

By family, partitioned:

| family | rules | proof LOC | share |
| ------ | ---: | ---: | ---: |
| core / other | 150 | 195,480 | 31.0% |
| strings | 201 | 192,758 | 30.5% |
| bitvectors | 140 | 149,845 | 23.7% |
| arithmetic | 49 | 35,546 | 5.6% |
| quantifiers | 8 | 18,101 | 2.9% |
| arrays | 10 | 16,218 | 2.6% |
| datatypes | 10 | 15,501 | 2.5% |
| sets | 23 | 8,123 | 1.3% |

Quantifiers are eight rules holding 2.9% — 2,263 lines of proof per rule,
against 959 for strings and 1,070 for bitvectors. Families are grouped by
rule-name prefix, which is a heuristic and not a taxonomy.

## What the baseline sets up

Three things to carry into the next iteration.

1. **The generality question has a number now, and it is 8.3%.** That is the
   share of the proof that is not rule correctness — the best current estimate
   of what a second calculus inherits. Refining it is the most valuable next
   measurement, and it needs the calculus-independence measure that does not
   exist yet ([measures.md](measures.md#gaps)).
2. **The floor and the tail are separate problems.** Lowering the 9,494-line
   floor helps every rule a little. Attacking the heaviest 59 rules addresses
   half the variable cost. These are not the same work and should not be
   argued about as if they were.
3. **The two corners of the scatter want different work.** The semantic corner
   — `Arrays_ext`, `Cong`, `Instantiate` — is where a small statement costs a
   thousand lines, and it is also where a calculus-independent argument would
   pay off most, because those rules are about equality, extensionality and
   instantiation rather than about CPC. The syntactic corner is already cheap
   and there is nothing to win there. A generality effort that starts anywhere
   else is starting in the wrong place.
4. **Partitioned is still not authorship.** A rule's share is what it adds
   *given the order*, so the first rule to touch a shared file carries all of
   it, and the order's leading positions absorb the base by construction. The
   remaining step is to separate a rule file's own lines from the support it
   happens to claim first — see [measures.md](measures.md#gaps).
