# The boundary

What analysis in this ecosystem can establish, what it can establish only
through something else, and what it cannot establish at all — in one place, with
the decision procedure that follows.

**What this displaces.** The rule for this directory is that a third document
has to displace a question in the form or an hour of somebody's reading. This
claims the second, and the claim is checkable: the boundary is currently drawn
in **dozens of places across five repositories**, and where two statements of it
have been laid side by side they disagree **fourteen times** — nine within the
tree that keeps the policy, five more across the others. Knowing where the line
falls today means reading all of them and reconciling them by hand. If somebody
checks that and finds three disagreements rather than fourteen, this document
has not earned its slot and should go.

Two surveys behind it, one per group of trees, and every quotation below was
verified in place afterwards.

## What everyone already agrees on

The ecosystem has a master criterion and it is a good one:

> **The test for where a sentence belongs.** Can a program decide it from the
> tree, without an opinion? If yes it is policy: move it there and check it. If
> no it is vision, and it must never acquire a checker.

And — this is the finding that matters — **three trees independently arrived at
the same middle category and gave it three different names.** The compiler's
tree grades its passes *provable / checkable per run / needs a semantics*. The
solver-side analyzer grades invariants on a five-rung ladder ending in *only
observable on an input*. This repository grades generated files *GENERATED /
PROVEN / FINISHED / OPEN* and profile answers *derived / declared*. None cites
the others. All three name a class that is neither proved nor undecidable, and
all three call it, in effect, **checkable per run**.

Convergence from three directions is the evidence that the category is real
rather than a convenience. What is missing is a shared name and a shared rule
for what to do with something in it.

## Where the statements disagree

Fourteen, of which four matter enough to carry:

**Three different reasons are given for the same prohibition.** The vision says
*"nobody has the **authority** to settle them"*; the coherence page says
*"nobody has the **standing** to settle it"*; the same page says *"if answering
it **requires judgement**, it belongs in the vision"*; the checker's output
conjoins two of them. These come apart — a repository cannot decide its own
standing while *another tree can*, so that question is neither judgement-hard
nor authority-less. **Each reason licenses a different remedy: reword it, ask
somebody else, or never ask.** Conflating them is how a question lands on the
unchecked list and stays there, because nobody can tell which move would clear
it.

**"Never checkable" and "checkable later" are both stated categorically.** One
page: *"Nothing may ever check the vision mechanically… it is the one rule here
that forbids work rather than requiring it."* The other, on the same subject:
*"a tenet somebody works out how to check mechanically was probably a policy
convention all along, and should move."* One forbids looking for a
mechanisation; the other invites it.

**There is no slot for *deliberately unchecked*.** The two governing documents
admit exactly two dispositions for a rule no program can decide — wrong
document, or loosely worded — and both are faults. The checker's own list has
fifteen entries whose reasons include *"a claim about tone"*, *"intent; no
artifact records who asked"*, and *"encouraged and never blocking, so nothing
here checks it — by design"*. None of those is a wrong document or a loose
wording.

**And one is ours.** This repository's front page says *"a red build means
something is genuinely broken; it never means 'there is work left'"*, while
[`docs/limitations.md`](../../../docs/limitations.md) records that the shipped
tree contains bridge lemmas *"not merely unproven but **false as stated**"* —
with a green build. Both are defensible if *broken* means structurally broken,
but the front page carries no such qualifier and it is the sentence a reader
takes away. This tree already has the vocabulary to fix it — `FINISHED`, and
*a stub rather than a `sorry`* — and does not apply it here.

## The three zones

| zone | test | what a claim in it is worth |
| --- | --- | --- |
| **A — derived** | a program decides it from the artifact, without an opinion, and a second person re-runs it | as much as the program. Re-checkable without asking anybody |
| **B — attested** | the answer exists and is not the analysis's to give: it needs an artifact, an owner, expertise, consent, or a decision nobody has taken | exactly as much as the attestation, and it must name what attested |
| **C — argued** | contestable by design; the disagreement is the content | what the argument is worth to a reader. It binds nobody and may never acquire a checker |

**The correction the surveys forced on this page:** zone B is not mostly people.
The overwhelmingly common named decider on the undecidable side, across all five
trees, is **an artifact** — an input file, a digest, a full build, a corpus run,
a reconciliation sum, a branch. Explicit *only a person can decide this*
statements cluster in exactly three subjects:

- **consent** — whether somebody agreed to be analysed;
- **intent** — what a stale annotation or an ambiguous file was meant to say;
- **ownership** — which calculus, which scope, which name.

Everywhere else, these repositories go out of their way to convert a judgement
into something runnable. That is the practice worth naming, and it is the
opposite of the intuition that AI-assisted analysis should lean on human review.

## The ladder: where a check belongs

The best operational criterion in the ecosystem is not the policy/vision split.
It is the solver-side analyzer's ladder, which keys the *home* of a check to
what its invariant is **decidable from**:

| if the invariant is… | it belongs as… | who maintains it |
| --- | --- | --- |
| decidable from types or constants at compile time | a static assertion | the subject, free, forever |
| decidable from the subject's own tables at startup | a runtime assertion where the table is built | the subject, free, forever |
| a property of one function's syntax | a lint pass | the subject, one nightly run |
| a property of the whole call graph | a whole-program query | the subject, one nightly run |
| only observable on an input | a corpus run | us |

With the rule attached: **"a check here that could have been an assertion in the
subject is a design failure, not a feature."**

Generalised, that is the answer to *what would improve the workflow*: **the
question is not whether something is checkable, but how far upstream it can be
checked** — because the further up, the cheaper, the more permanent, and the
less it belongs to us. An invariant we enforce from outside somebody's tree is
one we will maintain forever and they will never see.

## A check that cannot fail is not a check

The single most transferable finding, and it has been rediscovered **four
times, independently, in four trees**, which is why it belongs on this page
rather than in any of them:

- a profile check *"grepped for `DatatypeDecl`, which declares unconditionally —
  so it could only ever answer `yes`"*, and was retracted;
- a trusted-base measure that *"returns the same answer for every seed measures
  nothing"*, demoted from default and made to print a warning;
- a modularity harness given **a canary — a declaration that must be rejected —
  so the harness cannot degrade into a no-op that always passes**;
- a partition held not by discipline but by arithmetic: *"the partition must sum
  to the layer total… and exits non-zero if it does not."*

Same discovery four times: **the failure mode of a check is not being wrong, it
is being vacuous**, and vacuity is silent. A green tick from a check that cannot
fail is worse than no check, because it reads as coverage.

The rule that follows: **every check ships with something that makes it fail** —
a canary, an injected error, a reconciliation sum, or a discrimination test
showing it gives different answers on different inputs. This is cheap, it is
mechanical, and only two of the four trees do it deliberately.

## The decision procedure

Given a question you want answered, in order:

1. **What is it decidable from?** Types, a table at startup, one function's
   syntax, the whole graph, or only an input? That answers *where the check
   belongs*, which matters more than whether we could write it. If it belongs
   upstream, the deliverable is a patch to them, not a tool here.
2. **Can a program decide it without an opinion?** → zone A. Write the check —
   and write the thing that makes it fail, in the same commit.
3. **Is there an answer that is not ours to give?** → zone B. Name **what would
   attest it**: an input, a digest, a build, an owner's sentence. An artifact if
   at all possible; a person only for consent, intent, or ownership.
4. **Would two informed people disagree, and is that the interesting part?** →
   zone C. Argue it, and never put a tick against it.
5. **If none fits, the question is malformed** — usually two questions.

**The one-line test:** *a claim is worth what a reader can do with it without
asking you.* Zone A: re-run it. Zone B: check the attestation. Zone C: disagree
with it. A claim a reader can do none of those with is not a finding.

## What is doable — with evidence

From one session, self-reported and therefore weak, but the direction is not
subtle. **Mechanical checks caught roughly ten defects that reading did not**:
three citations of a rule by number, an unadopted gate clause, a matcher
producing 982 matches from 105 claims, a crash on a pipe, an inventory's first
revision producing no events, a calibration miss with a named cause, a
classifier that filed a 750-line program as neither code nor prose, and a
subject definition contradicting the inventory it should have been derived from.
**Unaided reading caught two**: a stale figure superseded later in the same
file, and a name collision between a placeholder and a project.

Every one of the ten is zone A and was found in seconds. That is the argument
for spending effort on checks rather than on review — and not an argument that
review is worthless, since the two reading caught were things no program would
have been written to look for.

## What is not doable

- **Whether an evolution went well.** No ground truth; calibration measures only
  whether detectors find what a person would name; the real test — somebody who
  knows the subject learning something — cannot be self-administered.
- **Measuring work-about-work as currently specified.** The register's entry
  names its falsifier as *lines of tool against lines about tools, per
  repository, per month*, and says nobody measures it. It has now been measured
  and **the falsifier does not operationalise**: the third bucket is not small,
  generated lines count as authored, and two implementations of the same crude
  classifier disagreed by sixty per cent. The numbers are in the entry.
- **Whether a check was narrowed honestly.** Already stated elsewhere: the
  enforced half is that a change inventing a false positive fails the build; the
  unenforced half is everything after.
- **Intent, and actions that did not happen.** Both are on the unchecked list
  for the right reason, and neither is fixable by rewording.
- **Whether a statement proven is the statement wanted.** Named exactly by the
  audit of the proof development: a source scan establishes that no proof gap
  was found, *"not a claim that the statement proven is the statement one
  wanted, and it does not and cannot check that."*
- **Whether these practices generalise.** One adopter is not five, and every
  repository here was set up by people who already knew the practices.

## What this cannot check about itself

It was assembled by reading, and reading is zone B — two passes over five
repositories, and a missed statement would weaken the central claim invisibly.
The quotations were verified in place; the *counts* — dozens of statements,
fourteen disagreements — were not independently re-derived, and they are what
the displacement claim rests on.

It also grades documents written in the same style, in the same week, by the
same process, about a subject it is part of. The shared reporting position
applies and is worth repeating: nobody can calibrate our coverage, including us.
