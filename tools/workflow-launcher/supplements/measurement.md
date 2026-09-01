---

## Measurement

For a tool whose output is **numbers** — timings, counts, sizes, coverage,
scores. These questions are here rather than in the core because most launches
do not need them, and because a measurement tool that has not answered them will
produce numbers that look exactly like numbers that mean something.

The order is the one that matters: what you measure decides everything else, and
the last question is the one that decides whether anybody should believe any of
it.

### M1 — What is measured, and in what unit

**Required.** The quantity, and what it is expressed in. Be exact about the
unit: wall-clock seconds and instruction counts are different measurements of
different things, and so are *lines* and *nonblank noncomment lines*.

If more than one quantity, list them and say which is **primary** — the one a
run reports when nobody asked for detail. A tool with three co-equal headline
numbers has not decided what it is for.

<!-- AM1 required -->

<!-- /AM1 -->

### M2 — The corpus, and where it comes from

**Required.** What the tool runs on: which inputs, how many, where they come
from, and whether they are **committed, fetched at a pin, or assumed present on
the machine.**

The third of those is the one that quietly ruins a measurement tool: a number
nobody else can re-measure cannot be argued with, and a corpus that lives only
on its author's disk makes every result a claim about that disk. Say which
kind you are choosing, and if it is the third, say why.

Also say whether the corpus is **fixed or growing**, because a number compared
across a changing corpus is not a comparison.

<!-- AM2 required -->

<!-- /AM2 -->

### M3 — The baseline

**Required.** What a number is compared against. A measurement with no baseline
is a fact about one run and is not yet information.

The usual candidates, and they behave differently: a **committed baseline** in
this repository, which makes a regression fail this build before it reaches
anybody; a **previous revision** of the thing being measured, which needs the
revision recorded with the number; an **external reference** — a competitor, a
published result, a target; or **none yet**, which is a legitimate day-one answer
if you say so.

Say also what a baseline being *stale* looks like and who notices.

<!-- AM3 required -->

<!-- /AM3 -->

### M4 — Noise, and the threshold

**Required.** What makes two runs of the same thing on the same input differ,
and **how large a difference has to be before you would report it.**

This is the question that separates a measurement tool from a stopwatch. Say
what varies — machine load, scheduling, cache state, randomised seeds,
timeouts — how many runs a number is taken over and how they are combined, and
the threshold below which the tool says *no change* rather than a small number.

An agent given silence here will report the difference between two single runs
to three decimal places, and it will look authoritative.

<!-- AM4 required -->

<!-- /AM4 -->

### M5 — The environment, and what a number is not portable across

**Optional.** Hardware, parallelism, timeouts, resource limits, build
configuration — whatever a number depends on that is not the input.

Then the part worth the most: **name what makes two numbers incomparable.** A
different machine, a different build type, a different core count, a different
timeout. Whatever is on that list should be recorded beside every number, and
saying so here is what makes the agent record it.

<!-- AM5 optional -->

<!-- /AM5 -->

### M6 — What a number is not allowed to claim

**Required.** The epistemic caveat, stated so it can go on the front page rather
than three clicks in.

Measurement tools are believed more than they deserve, and by exactly the
readers least able to check them. Say plainly what a result is *not* evidence
of: that a regression is a defect, that an improvement is causal, that the
corpus is representative, that what was measured is what anybody cares about.

If a number would be reported to somebody who owns the thing measured, this
answer is what stops it being read as an accusation.

<!-- AM6 required -->

<!-- /AM6 -->

### M7 — The first number you want to see

**Optional, and the sharpest scoping question here.** The smallest end-to-end
measurement worth having on day one: one input, one quantity, one number
printed.

It pairs with the working-stub answer in the core. A measurement tool whose
day-one stub actually runs one case and prints one real number is in a
completely different state from one that arrives as scaffolding — you can be
wrong about it immediately, which is the whole point.

<!-- AM7 optional -->

<!-- /AM7 -->
