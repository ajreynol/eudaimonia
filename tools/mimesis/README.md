# Mimesis

A **child project** of the Eudaimonia build framework: an authoring setup for
somebody who has a calculus in mind and no Eunoia signature yet. It is about the
hours before a generated checker exists — getting from rule descriptions to an
`.eo` signature, an `.eos` semantics, and proof tests that accept and reject the
right things.

**Where it is right now.** The charter, and one worked example read from
somebody else's history: [`docs/case-study.md`](docs/case-study.md) follows a
real CPC proof rule from a published table of lemma schemes into a Eunoia
signature, into a checked Lean proof that found it unsound, and back into the
signature twice. Launched 2026-09-16 by explicit maintainer instruction; no
signature has been written *here*, no measurement of this project's own has been
taken, and every claim below about what authoring costs is somebody else's,
cited where it is used.

## The charter

**The question.** Can somebody who has a calculus in mind, and has never written
Eunoia, reach a signature that compiles, that accepts the proofs it should and
rejects the proofs it should — without reading a large existing calculus first
to reconstruct the conventions?

**The artifact.** A **route** and the **worked examples** that establish it: one
small calculus taken from its author's rule descriptions to an installed,
exercised checker, with every place the author was stuck written down at the
moment it happened. The record of the stumbles is as much the deliverable as the
signature; a signature by itself proves only that somebody who already knew how
could do it again.

**The goals, in order.**

1. **One calculus, end to end, with the friction recorded.** Propositional
   resolution — [why that one](#why-propositional-resolution-is-first) — from
   rule descriptions to `scripts/new-checker.sh --spec`, an install, and a
   regression suite covering every verdict the framework has. The signature is
   the easy half. The half that is the point is the log: what the author wanted
   to say, what Eunoia wanted instead, and what unstuck them.
2. **The friction ledger.** One entry per stumble, each classified by whose it
   is to fix: the **compiler's** (a diagnostic that named the wrong thing, or
   nothing), the **framework's** (a contract or profile fact an author had to
   discover by failing), the **documentation's** (the answer existed and was not
   findable from where the author stood), or **irreducible** (a judgement about
   the calculus that no tool can make). The fourth category is the one that
   decides whether this project has a result: if nearly everything lands there,
   authoring is hard because calculi are hard, and no authoring setup helps.
3. **The route, written down.** The order the decisions actually come in —
   contract, then profile, then rules, then semantics, then the tests that make
   a verdict mean something — in a form a second author can follow without this
   project's author sitting beside them. Written *after* goal 1, from what the
   log says the order was, not from what it ought to have been.
4. **A second author, which is the test that matters.** Somebody who did not
   write goal 1 takes a *different* small calculus through the route, and the
   ledger records where the route failed them. Goal 1 measures the framework;
   only goal 4 measures the route, because the author of a route is the one
   person it cannot be wrong for.
5. **What could be mechanized.** Which ledger entries are a scaffold, a lint, a
   compiler diagnostic or a request in
   [`docs/eoc-requests.md`](../../docs/eoc-requests.md), and which are a
   person's judgement. Requests leave through the parent, carried by a person;
   nothing here files one.

**The wishue (stretch goal).** Somebody who has never read CPC takes a page of
rule descriptions to a generated checker that passes its own regression suite in
an afternoon, and what got them there is the route rather than its author.

**What is out of scope.**

- **Soundness, and every claim in its neighbourhood.** A signature whose proof
  tests pass is a signature that accepts and rejects the proofs it was shown. It
  is not a sound calculus, the rules have not been justified, and a freshly
  generated checker's soundness proofs are unfinished by construction — the
  parent's [limitations](../../docs/limitations.md#nothing-is-proven-yet) say so
  and this project repeats it rather than working around it. **Helping an author
  mistake acceptance for soundness is this project's characteristic way of doing
  harm**, and any output that reads that way is a defect in the output.
- **Designing anybody's calculus.** The author brings the rules. Mimesis helps
  express them, and a route that quietly steers authors toward the rules that
  are easy to write in Eunoia has changed the subject.
- **Proving anything in Lean**, closing a generated checker's obligations, or
  saying what a checker establishes. That is the parent's, and
  [`tools/hermeneia`](../hermeneia/README.md) and
  [`tools/noesis`](../noesis/README.md) are where the neighbouring questions
  live.
- **Changing the framework.** No template edit, no new flag, no script in
  `scripts/`. What this project learns about `--dummy-rule` or the signature
  contract is a finding, and a finding travels through the parent's ordinary
  discipline in a person's hands.
- **Becoming a tool.** Not a signature generator, not an editor mode, not a
  wizard. If a mechanism turns out to be worth building, goal 5 says so and
  somebody else builds it somewhere it can be depended on.
- **Somebody else's unpublished calculus.** The gate
  [`tools/apodeixis`](../apodeixis/README.md#the-gate) wrote for itself applies
  here with nothing removed: published material only, in the form its authors
  published it, and collaboration asked for by a person before a calculus that
  belongs to somebody else is taken as a subject. Choosing a textbook calculus
  for goal 1 is partly how this project stays clear of that.
- **Teaching SMT-LIB, or Lean.** The `.eos` side says how a symbol lands in a
  semantics that already exists. Explaining that semantics is not this.
- **Taking the name.** The register that reserves `mimesis` is in kanon's tree
  and nothing here edits it. See [the name](#the-name).

## Why propositional resolution is first

[Ynoia's listing][work] leaves the first example calculus to the launch charter,
so this section is the decision rather than a preference.

| | what the author must do | covered before this? |
| --- | --- | --- |
| a side condition that computes | write a Eunoia **program** that removes the resolved literals and returns the resolvent | **no.** Neither starter has a program, and it is where authors are most likely to write something that compiles and means the wrong thing |
| `:list` premises and a nil | `or` declared `:right-assoc-nil`, premises gathered through it | `examples/scoped` has this for `and`; nothing has it for the operator the calculus is *about* |
| the refutation target | none — the empty clause **is** `false`, which is exactly what the checker tests for | nothing has needed an encoding, and this one still does not, which keeps goal 1 about authoring |
| the semantics | `or` and `not` land pointwise on their SMT-LIB counterparts; `smt.eos` is untouched | as in `examples/hello`, deliberately: a first example that also replaces the SMT-LIB semantics would be measuring a different, much harder thing |
| whose work it is | textbook, and older than everyone involved | the reason it is first. No permission question, no misreadable public record of somebody's calculus straining |

**The first surprise is already visible**, and it is the kind of thing the
ledger exists for: a resolution calculus is about `or`, and the contract still
requires it to declare a binary `and` and to send it to `SmtTerm.and`, because
what a checker concludes is about the conjunction of the proof's assumptions.
Nothing in the calculus's own rules uses it. An author who has not read the
contract meets this as an install-time failure, and where they meet it is a
measurement rather than an anecdote.

**The risk this choice carries, stated now.** CPC has resolution rules, and
`examples/cpc` is in this tree. An author who reaches for them has stopped doing
the experiment — the question is whether a signature can be written *from rule
descriptions*, and an existing signature is the input the name of this project
explicitly refuses. The working rule for goal 1: the reference calculus is the
**reviewer's** oracle, consulted after a difficulty is logged and never before.
An entry in the ledger that cannot say what the author tried before looking is
worth nothing.

**What "rule descriptions" means here.** The prose form a calculus arrives in —
premises, conclusion, side conditions, in a paper's or a textbook's notation.
Writing those down for resolution is the first task of goal 1, and it is done
before any Eunoia is written, so that the route has a real starting point rather
than a remembered one.

## What it builds on, and where

The [child-project policy][policy] asks a child to build on what its parent
learned and to say where — which is also the reason to run this inside a working
tool rather than in a repository of its own: the tool has evidence. Each row
is somebody else's measurement, and this project starts from it rather than
re-deriving it.

| source | what mimesis takes from it |
| --- | --- |
| [`--dummy-rule` and `examples/hello`](../../README.md#starting-a-new-calculus) | the starting point an author changes: a working one-rule calculus, its semantics, and five proofs covering every verdict, building in about 12 seconds. The route begins here rather than at a blank file |
| [`examples/scoped`](../../examples/scoped/Scoped.eo) | the two profile answers `hello` does not reach — assumption discharge and `:list` premises — already written small |
| [the signature contract](../../README.md#the-signature-contract) | the three things every signature must satisfy and the one seam nothing downstream re-checks: `and` translated somewhere other than `SmtTerm.and` compiles, checks proofs, and concludes about the wrong formula. An authoring route that does not make this loud is unsafe |
| [the calculus profile](../../README.md#the-calculus-profile) | which facts about a calculus are derived from the compiled output and which are taken on trust — the declared ones are where an author's mistake survives |
| [`docs/generated-checker.md`](../../docs/generated-checker.md#what-a-fresh-checker-can-and-cannot-say) and [`docs/limitations.md`](../../docs/limitations.md#nothing-is-proven-yet) | what a passing test suite does and does not establish, in the parent's own words |
| [`TODO.md` §4f](../../TODO.md#4f-starting-from-something-that-works) | that a second calculus paid for itself immediately — three bugs CPC could not expose, all invisible while CPC was the only test. The best evidence in this tree that writing a small calculus from scratch is worth somebody's time |
| [`docs/eoc-requests.md`](../../docs/eoc-requests.md) | the standing list of what the compiler makes harder than it needs to be, written from the CPC side. Goal 5's output is the same kind of item written from an author's side |
| the compiler tree's [challenge to the user][agility] | the prior art, and the one this project must not duplicate. It names what is hard before either file exists, on the `.eo` side, and on the `.eos` side — four things to hold in your head at once, and four unwritten levels that make the same three characters mean four things |
| the `bv_abstraction` episode in the checker and solver trees, read in [`docs/case-study.md`](docs/case-study.md) | the only finished instance in reach of the whole loop — signature written, compiled, proved, corrected, simplified — and the measurements this project would otherwise have had to wait a year to take: where the dropped side condition came from, what the matching style cost, and what deleting three cases refunded |
| the Eunoia [user manual][manual] | the reference: 2,362 lines organised by feature, with worked examples and two deliberately *incorrect* ones. It is the account that already exists, and it is the authority on what the language is |

**Where the gap is, stated against those last two rather than around them.** The
manual is organised by feature and stops at the language; the agility map is
organised by rigidity and stops at the compiler. Neither is wrong and neither is
a route: an author's first question is not *what does `:right-assoc-nil` do*, it
is *which of these decisions do I make first, and what tells me I got it wrong*.
And the framework's own path — signature, semantics, profile, install, verdicts
— is downstream of both documents and described in neither. **If a careful
reading of those two plus `--dummy-rule` turns out to get an author there, this
project's answer is that no authoring setup is warranted**, and saying so is a
result rather than a failure. Ynoia's entry sets the same test; this charter
does not weaken it.

## The measurement

A project whose output is "authoring is hard" has measured nothing. What is
written down instead, per stumble: what the author was trying to express, how
long they were stuck, what they tried, what resolved it, and which of goal 2's
four categories it falls in. Counts by category are the result — with the ledger
under them, so a reader who disagrees with a classification can see the entry.

**What a negative result looks like**, so that it cannot be quietly avoided
later: most entries land in *irreducible*, or the second author of goal 4 gets
through on the manual and the starter alone. Either one retires this project
with a note, and the note is more useful to the ecosystem than a route nobody
needed.

## The name

*Mimesis* (Greek **μίμησις**, "imitation") is Aristotle's word for learning by
representing — the way a craft is picked up from worked instances before it can
be stated as a rule. It names this project because the proposal is that somebody
learns to express a calculus in Eunoia from examples worked in front of them,
**not** by being handed an existing signature to copy: imitation of the *doing*,
not of the artifact. If it turns out that the fastest route to a new signature
is to open CPC and edit it, the name is wrong and so is the project.

The etymology and the scope are the ecosystem's rather than this directory's:
both were written in [ynoia's account][why] before there was anything to attach
them to, and the register carries `mimesis` under *reserved for an intended
launch*, recorded on 2026-09-16 as an intention of the maintainer's. **This
directory has not taken the name.** A name is claimed when a person adds a line
to [the register][names] saying where it lives, that file is in kanon's tree, and
nothing here edits it. A reader who finds the entry still reading *not started*
should read that as an edit that is owed, and the edit it is owed is *started, in
eudaimonia at `tools/mimesis`*.

## An island

Mimesis follows the ecosystem's [child-project policy][policy]. It reads the
parent, its neighbours and the compiler's tree, and writes only inside
`tools/mimesis/`. Nothing in Eudaimonia links here, imports from here, or runs
anything here; this directory is on no build path, in no CI job and in no
generated document, and deleting it changes none of them — deleting it is the
test.

It runs the parent's scripts the way any user would, from a checkout, and writes
what they produce **outside this directory**: a generated checker belongs in
`checkers/`, which is not kept in git, or in a repository of its own. A
specification written here is committed here; a checker built from it is not.

**It has no responsibilities and no correspondence channel.** A child project is
addressed through the repository that carries it. It answers nothing on
eudaimonia's behalf, it opens no conversation with the compiler's maintainers or
anybody else's, and a ledger entry that wants to be a request stays a ledger
entry until a person carries it.

## It is additive, never authoritative

**The [user manual][manual] is the authority on what Eunoia is, and the
compiler's output is the authority on what a signature means.** A route written
here governs nothing. Where this project's account of how to write a signature
disagrees with either, the existing one is right and the disagreement is this
project's finding to explain.

That is not modesty about the value of a second account — two independent
descriptions disagree exactly where the artifact is unclear, and those
disagreements are the point. But a route that resolved every disagreement in its
own favour would be overstepping, and one that resolved every disagreement in
the incumbent's favour would have become a paraphrase of the manual with fewer
readers. Both failures are worth watching for.

## What is written down

| document | what it is for |
| --- | --- |
| [`docs/case-study.md`](docs/case-study.md) | One rule, both sides: `bv_abstraction` from a paper's lemma schemes to a Eunoia signature to 11,168 lines of Lean, the unsoundness the proof found, and what seven lines of signature were worth in proof lines. Read from two development branches on 2026-09-16, and written so that it stands if they are rebased away |

## Endings

Three endings, and a person picks.

- **Folded** into the parent, which is the likeliest: the route becomes part of
  what [Starting a new calculus](../../README.md#starting-a-new-calculus)
  documents, the mechanisms goal 5 identifies become requests or flags somebody
  else owns, and this directory goes away. A child project that succeeds at
  making its parent easier to start with has no reason to survive the change.
- **Graduates** into its own repository, if goal 4 shows the route is about
  Eunoia rather than about this framework — in which case it belongs somewhere
  an author who is not using eudaimonia can find it, and the register entry
  changes to say so.
- **Retired in place**, with a line saying what was learned. [The
  measurement](#the-measurement) names the two results that lead here, and
  neither is a failure of the work.

Going quiet is not one of them. A directory that has not moved and that nobody
is standing behind is a claim nobody is defending, and the honest form of that is
a retirement note.

*Started 2026-09-16 by the maintainer, in an explicit instruction, with the first
example calculus chosen in the same conversation — which is the decision the
policy reserves for a person, and the one ynoia's entry says a launch charter
owes. Nothing has been delivered, so nothing above is an exception the policy
would ask this project to name, and the island is stated as fact rather than as
intention.*

[policy]: https://github.com/ajreynol/kanon/blob/main/docs/policy.md#child-projects
[work]: https://github.com/ajreynol/kanon/blob/5545d5cd20578ec890100810aa59165bb782c6e1/tools/ynoia/tools.md#mimesis--helping-authors-write-signatures-from-scratch
[why]: https://github.com/ajreynol/kanon/blob/5545d5cd20578ec890100810aa59165bb782c6e1/tools/ynoia/why-eunoia.md#mimesis--helping-authors-write-signatures-from-scratch
[names]: https://github.com/ajreynol/kanon/blob/5545d5cd20578ec890100810aa59165bb782c6e1/tools/ynoia/names.md#reserved-for-an-intended-launch
[manual]: https://github.com/cvc5/ethos/blob/main/user_manual.md
[agility]: https://github.com/cvc5/ethos/blob/main/docs/README.md#part-i--the-challenge-to-the-user
