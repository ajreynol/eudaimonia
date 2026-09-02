# Autarkeia

**The state of an ecosystem in which the development of a verified proof
checker for SMT can be automated in a single prompt.**

That sentence is the whole of the definition. Everything below it is either
evidence for where we actually are, or a rule about what the word may not be
used for.

## The name

*Autarkeia* (Greek αὐτάρκεια, from *autos* "self" and *arkein* "to suffice") is
Aristotle's second test for the final good: it must be αὔταρκες —
self-sufficient, such that nothing further need be added to it. The name follows
Eudaimonia, which is the end that test is applied to.

What would be self-sufficient is neither the checker nor the framework. It is
**the development**: the state in which nothing further need be supplied by hand
between the prompt and a checker whose obligations are discharged.

**The objection, which is real and is kept here rather than answered.**
αὐτάρκεια names *lacking nothing*, not *labour saved*, and self-sufficiency in
modern ears reads as isolation — which cuts against the ecosystem's first tenet,
that a tool evolves to be fruitful to another tool as quickly as possible. An
ecosystem in autarkeia would be more use to outsiders, not less; the word does
not say so and has to be told. Chosen by the maintainer on 2026-09-02 with that
objection on the record.

It names a **state**, not a tool, so nothing here takes a name from anoieu's
register. If the word ever names a program, adding the line there is a person's
edit in somebody else's tree.

## The ceiling this is written under

anoieu keeps [`docs/science-fiction.md`](https://github.com/ajreynol/anoieu/blob/main/docs/science-fiction.md):
the furthest that ecosystem allows itself to plan, on the rule that above the
line nothing gets an artifact — no board row, no name reserved, and **no rule
whose justification is a state of the world we are not in**. That page binds
anoieu and says so.

This document is above that line by its own admission. It takes the discipline
without the jurisdiction:

- **It carries no rule.** Nothing here may be cited as a reason to do a piece of
  work or to refuse one. [`TODO.md`](../TODO.md) is where work is decided, and
  no item there says *autarkeia*.
- **It claims no progress toward the state.** A distance nobody has measured
  cannot be shortened, and *closer than last month* is the sentence this section
  exists to prevent.
- **It has no date and no percentage.** Neither is available, and inventing one
  would make the rest of the page look like the same kind of thing.

The gap it names is real and is measured below; what is forbidden is treating
the measurement as a trajectory.

## The definition, word by word

Four words are load-bearing.

**single prompt** — one instruction, not one command.
`scripts/new-checker.sh --checker Demo --calculus Cpc --spec examples/cpc` is
already a single command, and what it does is much smaller: it writes a project
that compiles, from a specification somebody else wrote. Under autarkeia what
the prompt names is the calculus and what it is for, and the signature, the
semantics, the profile and the proofs are downstream of it.

**automated** — unattended, not assisted. Under a constraint anoieu has already
written down about coding with prompts: a prompt is not a build script, because
the same prompt does not produce the same tree twice. *Automated* here can mean
**re-attemptable** and never *reproducible*, and a claim of the second is a
defect wherever it appears, including here.

**verified** — the whole of the distance. A generated checker's `correct`
verdict means *the checks passed*, not *this has been proven*. It ships
compiling, its obligations are `sorry`, and two files —
`Proofs/CheckerCore.lean` and `Proofs/RuleSupport/Support.lean` — state their
obligations as empty propositions specifically so that nothing closes them by
accident. Autarkeia is about that gap and about nothing else: a checker that
generated faster, or generated more Lean, would not be closer.

**ecosystem** — not *framework*, and this is the useful half of the term. Most
of the distance is in trees this repository does not own. The largest single win
available is seeding the checker layer from Logos rather than describing it,
which is blocked on upstream and is item 5 of
[`eoc-requests.md`](eoc-requests.md), the top of that list. The calculus
profile's three **declared** flags stay declared for as long as the compiler
emits their machinery unconditionally. And a calculus over something that is not
SMT-LIB needs a replacement `smt.eos`, which is the hardest part of a
specification rather than a flag.

## Where we actually are

**The floor is a single command, and it is checked on every push.** A run
generates a checker that builds — six option configurations generated, built and
run against their own CI suite, plus a generate-install-build-check smoke test
on macOS. `examples/cpc` is a real specification of a 591-rule calculus, and the
framework generates against it.

**The ceiling of that floor is that nothing generated is proven**, and the price
of proving one is the only calibration anybody has. Logos paid it once, by hand,
for CPC; [`logos-experience-report.md`](logos-experience-report.md) is the
inventory, stub by stub:

| obligation | lines in Logos, `Cpc` / `CpcMini` |
| --- | ---: |
| the support layer every rule statement is written against | 352,795 |
| one proof per rule of the signature | 279,000 across 591 files |
| translation type preservation | 33,453 / 5,141 |
| type preservation | 17,691 / 4,234 |

The two-column rows are the more informative ones: they separate what a cost
follows — the signature and its theories, or the rule count.

**The prompt half exists in miniature, one level up.**
[`tools/workflow-launcher`](../tools/workflow-launcher) turns an answered
interview into a prompt and hands it to an agent in a directory a person already
made, so that *what did you actually run* is a file rather than a memory. It is
an island, it stops after the first hour, and it proves nothing about this
state. What it shows is that the shape — a form, a rendered prompt, a staged
result a person reads — is buildable at a scale where nothing has to be proven.

## The distance, in named parts

Not a plan, and not ordered. What would have to stop being true.

1. **"The correctness development — the user's, not the framework's."** That is
   the title of section 3 of [`TODO.md`](../TODO.md),
   written as a scope decision rather than as a limitation. Autarkeia is exactly
   the state in which that title is false.

2. **Nothing stops work going backwards.** `sorry` is a warning rather than an
   error and `hygiene` is not a default CI group — both correct, because a fresh
   checker is nothing but `sorry` and a suite red by construction says nothing.
   The consequence is that a `sorry` can be added, a statement weakened or a rule
   stranded with every CI group still green. TODO section 7 records the ratchet
   as worth wanting and not yet worth specifying, because *what to count* is the
   unsolved half. **Unattended work without a ratchet is the failure mode, not
   the goal.**

3. **Nobody knows whether the rule proofs have shapes.** If the compiler emitted
   a proof sketch per shape instead of a bare `sorry`, the 591-file problem would
   change character. That is speculative and stays speculative until somebody has
   proven enough rules by hand to see the shapes. Nobody has.

4. **The trusted base does not shrink.** The parser stays unverified by design
   and nothing relates a proof's assumptions to an original SMT-LIB problem. So
   autarkeia is **not** the state in which a generated checker is trustworthy —
   only the state in which producing one costs a prompt. Whoever reads the term
   the first way has been misled, and it will usually have been us who misled
   them.

5. **The framework has never been driven at a calculus it was not designed
   around.** Every calculus it has generated for was chosen or written by
   somebody who knew the shape it had to fit. `tools/apodeixis` exists to fix
   that against Alethe and is gated: nothing has been rendered or run, and
   nothing will be until the Alethe maintainers have been asked and have agreed.
   Until some such run happens, *whatever calculus you name* is a claim tested
   against a family.

## What would count as reaching it

A test rather than a mood, in two steps — and the second is not the first scaled
up.

**The checkable one, and it is small.** One prompt, no human intervention
between it and a built checker for `examples/hello` — one rule, `contra` — with
no `sorry` anywhere in it and its trusted base stated in its own README. Nothing
about that is out of reach in principle, nobody has done it, and doing it once
would settle more than any argument on this page.

**The one in the definition.** The same, for a calculus specified by other
people for another checker, at a rule count where the person who asked cannot
read the proofs. That is where the interesting problem is and where every honest
doubt lives: at 591 rules, the reviewer's job is the one nobody has designed.

**What would show the term is wrong.** Hello scale passing, and teaching nothing
about 591 — a gap of kind rather than of degree, which is the objection anoieu
makes about scale in its own upper-bound page. Then the word names two states
rather than one and needs splitting or dropping.

## What the word may not be used for

- **No claim of it on the front page.** Pointing at this page from the README is
  fine; stating the target there as though a run delivered it is not. The front
  page is where somebody decides whether to spend a week, and a target that a
  run does not reach costs that person the week and costs us the reader.
- **Nothing is verified by virtue of being generated.** The README's closing
  sentence already says so; the existence of this page raises what it is worth.
- **No *single prompt* claim while the prompts are not recorded.** Ours are not.
  The launcher writes the prompt it assembles; nothing records the prompts this
  repository is actually developed with. anoieu carries the same gap as `F1` in
  its ethics register, raised before either of us wrote a page about it.
- **No rule, check, CI job or template change justified by this page**, and no
  use of it to refuse work. One instance of either is grounds for deleting the
  file rather than amending it.

## Why say it at all

Because this framework may have users, and a user deciding whether to spend a
week needs to know what the project is *for* beyond what it currently does.
*Generates a Lake project that compiles* is true, unattractive, and does not
distinguish this from a template. What distinguishes it is the target.

Three things the term buys, and the third is the one worth something to somebody
outside:

- **It gives the gap a shape.** Five named parts, most of them in other people's
  trees, each with the evidence that produced it.
- **It makes declining cheap.** Somebody who reads this and decides the target is
  not one they want has been served better than somebody who finds out at the
  first `sorry`.
- **It is attemptable.** Hello scale is an afternoon, and the result is reportable
  whichever way it goes. A target with a test invites a contribution that a
  roadmap item does not.

**And the cost, so that the trade is visible: review moves rather than shrinks.**
If a prompt produced a 300,000-line development, a reviewer reads the prompt
*and* the tree, because the second does not follow from the first. That is more
reading, not less — the opposite of what *a single prompt* is usually sold as,
and worth knowing before wanting it.
