# Mimesis

A **child project** of the Eudaimonia build framework: **a collection of case
studies on writing Eunoia signatures.** Each entry follows one real episode — a
calculus, or a single rule of one, going from whatever description its author
started with into an `.eo` signature, an `.eos` semantics, and whatever answered
back downstream — and records which decisions were made in what order, where the
author was stuck, what was got wrong, and what caught it.

**The authoring setup comes later, if it comes.** That is the artifact the
ecosystem reserved this name for, and it may still be what this becomes. It is
not what this does now: a setup written before the case studies exist would be a
guess about where authors struggle, and testing that guess is precisely what the
case studies are for.

**Where it is right now.** One entry, which is also the shape the others take:
[`docs/case-study.md`](docs/case-study.md) follows a real CPC proof rule from a
published table of lemma schemes into a Eunoia signature, into Logos — where
stating the proof obligation exposed it as unsound — and back into the signature
twice. Launched 2026-09-16 by explicit maintainer instruction; nothing here has
been written first-hand yet, and every claim below about what authoring costs is
somebody else's, cited where it is used.

## The charter

**The question.** What does writing a Eunoia signature actually take — which
decisions come in what order, which of them are load-bearing, and what catches a
mistake when one is made? And, downstream of that: can somebody reach a working
signature without first reading a large existing calculus to reconstruct the
conventions?

**The method, and why this shape.** Read episodes where it really happened, one
at a time, and write each one down in enough detail that the next one can be
compared against it. Real history supplies the difficulties that actually occur
in the proportion they actually occur, which is the one thing an invented
exercise cannot — and the episodes worth reading have already been paid for by
somebody else.

**The artifact.** A growing set of case studies in a common shape, and the
ledger they accumulate into. One case study is a story; the ledger is what makes
several of them evidence.

**The goals, in order.**

1. **Accumulate case studies.** One document in `docs/` per episode, each
   naming its sources precisely enough to be re-checked and written so that it
   survives the branches it was read from. Entry one is
   [BV abstraction](docs/case-study.md); [where the next ones come
   from](#where-the-case-studies-come-from) says what qualifies and what the
   supply looks like. **This is the work, and the pace is one good entry at a
   time** — a case study that took a day to read and is wrong about somebody's
   history costs more than the one that was never written.
2. **Fix the shape, so that entries compare.** Every entry answers the same
   questions: what its author was transcribing from, what the signature had to
   say that the source did not, which authoring style was chosen and at what
   point, what the artifacts cost in lines, what was got wrong, and what found
   it. Entries that each answer a different set of questions are anecdotes, and
   anecdotes do not add up. The shape is settled *from* entries rather than
   before them, so the current draft of it is whatever the first one does.
3. **The ledger across entries.** Each difficulty classified by whose it is to
   fix: the **compiler's** (a diagnostic that named the wrong thing, or
   nothing), the **framework's** (a contract or profile fact an author had to
   discover by failing), the **documentation's** (the answer existed and was not
   findable from where the author stood), or **irreducible** (a judgement about
   the calculus that no tool can make). Counts by category *across* episodes are
   the result this project is trying to have — and the fourth category is the
   one that decides whether it has one. If nearly everything lands there,
   authoring is hard because calculi are hard, and no authoring setup helps.
4. **One episode of our own.** Propositional resolution — [why that
   one](#the-calculus-we-write-ourselves) — from rule descriptions to
   `scripts/new-checker.sh --spec`, an install, and a regression suite covering
   every verdict the framework has, written up as an entry like any other. Its
   one advantage over the read ones is decisive and is why it is on the list:
   the stumbles are recorded **as they happen** rather than reconstructed from
   what somebody committed afterwards.
5. **Only then, the route and what could be mechanized.** Which ledger entries
   are a scaffold, a lint, a compiler diagnostic or a request in
   [`docs/eoc-requests.md`](../../docs/eoc-requests.md); which are a person's
   judgement; and what order the decisions come in for an author starting today.
   A route generalized from one episode is an anecdote with numbered steps, so
   this waits on goal 3 having something to say. Requests leave through the
   parent, carried by a person; nothing here files one.

**The wishue (stretch goal).** Somebody who has never read CPC takes a page of
rule descriptions to a generated checker that passes its own regression suite in
an afternoon, and what got them there is the route the ledger produced rather
than its author sitting beside them.

**What is out of scope.**

- **Soundness, and every claim in its neighbourhood.** A signature whose proof
  tests pass is a signature that accepts and rejects the proofs it was shown. It
  is not a sound calculus, the rules have not been justified, and a freshly
  generated checker's soundness proofs are unfinished by construction — the
  parent's [limitations](../../docs/limitations.md#nothing-is-proven-yet) say so
  and this project repeats it rather than working around it. **Helping an author
  mistake acceptance for soundness is this project's characteristic way of doing
  harm**, and any output that reads that way is a defect in the output.
- **Designing anybody's calculus.** An author brings the rules. Mimesis reads
  and eventually helps express them, and a route that quietly steers authors
  toward the rules that are easy to write in Eunoia has changed the subject.
- **Writing the history of anybody's project.** A case study follows one episode
  of signature authoring and stops there. It is not a narrative of a repository,
  not a survey of somebody's commits for its own sake, and not a verdict on how
  anybody works. Where reading turns up something still wrong in a live tree,
  that is a finding and leaves through the parent in a person's hands — never
  through an entry here.
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
  belongs to somebody else is taken as a subject. Case studies are read from
  public history, and choosing a textbook calculus for goal 4 is part of how
  this project stays clear of the rest.
- **Teaching SMT-LIB, or Lean.** The `.eos` side says how a symbol lands in a
  semantics that already exists. Explaining that semantics is not this.
- **Taking the name.** The register that reserves `mimesis` is in kanon's tree
  and nothing here edits it. See [the name](#the-name).

## Where the case studies come from

**What qualifies.** An episode in which a Eunoia signature, or a piece of one,
was written *and something answered back* — a proof obligation somebody had to
state, a generated checker, a producer's own checker, a test suite, a second
implementation. The answering-back is what turns an anecdote into evidence: it is
the moment a mistake stops being invisible, and an episode without one cannot say
which of the author's choices were wrong. The first entry is the shape of that:
what made it worth reading is not that a signature was written but that a Lean
proof was later stated about it.

**What the supply looks like.** Not the constraint. On cvc5's trunk, **75
commits touched CPC's Eunoia signature in the twelve months to 2026-09-16**, 19
of them in the last three; the Logos checkout read for the first entry carried
**83 remote branches**, many of them per-rule proof efforts. How many of those
pair a signature change with somebody stating an obligation about it is exactly
what a survey would have to establish, and no entry here claims a proportion
before one has been done.

**Nearer sources, and first-hand ones.** This framework's own history is
material too — [`TODO.md` §4f](../../TODO.md#4f-starting-from-something-that-works)
records a second calculus exposing three bugs CPC could not — and
[goal 4](#the-calculus-we-write-ourselves) is an episode written from the inside.

**What does not qualify.** Unpublished work, on the terms
[`tools/apodeixis`](../apodeixis/README.md#the-gate) set for itself. Episodes
whose only record is somebody's memory, unless that person writes it down and it
is theirs to give. And episodes read so thinly that the entry would be a
paraphrase of a commit message: an entry earns its place by reading the diffs.

## The calculus we write ourselves

[Ynoia's listing][work] leaves the first example calculus to the launch charter,
so this section is that decision — now attached to goal 4 rather than to the
first thing this project does.

| | what the author must do | covered before this? |
| --- | --- | --- |
| a side condition that computes | write a Eunoia **program** that removes the resolved literals and returns the resolvent | **no.** Neither starter has a program, and it is where authors are most likely to write something that compiles and means the wrong thing |
| `:list` premises and a nil | `or` declared `:right-assoc-nil`, premises gathered through it | `examples/scoped` has this for `and`; nothing has it for the operator the calculus is *about* |
| the refutation target | none — the empty clause **is** `false`, which is exactly what the checker tests for | nothing has needed an encoding, and this one still does not, which keeps goal 4 about authoring |
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
explicitly refuses. The working rule for goal 4: the reference calculus is the
**reviewer's** oracle, consulted after a difficulty is logged and never before.
An entry in the ledger that cannot say what the author tried before looking is
worth nothing.

**What "rule descriptions" means here.** The prose form a calculus arrives in —
premises, conclusion, side conditions, in a paper's or a textbook's notation.
Writing those down for resolution is the first task of goal 4, and it is done
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
| the `bv_abstraction` episode in the Logos and cvc5 trees, read in [`docs/case-study.md`](docs/case-study.md) | the only finished instance in reach of the whole loop — signature written, compiled, proved, corrected, simplified — and the measurements this project would otherwise have had to wait a year to take: where the dropped side condition came from, what the matching style cost, and what deleting three cases refunded |
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
written down instead, per difficulty: what the author was trying to express, what
the language or the framework wanted instead, what resolved it, what it cost in
lines downstream where that is visible, and which of
[goal 3's](#the-charter) four categories it falls in. **Counts by category across
episodes are the result** — with the entries under them, so that a reader who
disagrees with a classification can go and read the case it came from.

**One entry is not a measurement**, and this project's own numbers should be read
that way until there are several. What the first entry supports is that the
questions are answerable, not that any proportion holds.

**What a negative result looks like**, so that it cannot be quietly avoided
later: the difficulties keep landing in *irreducible*; or each episode's friction
turns out to be about its own calculus and nothing transfers between entries; or
an author working from the manual and `--dummy-rule` alone gets there anyway.
Any of the three retires this project with a note, and the note is more useful to
the ecosystem than a route nobody needed.

## Is there a paper in this?

**Not now, and saying so is cheaper than discovering it later.** The policy asks
every child project to state whether a paper exists, what the plan is, or that
there is nothing in it worth writing up, and today the honest answer is the
third: one case study is a reading of two branches, and a reading is not a
result.

**What would change that** is stated so that it can be checked rather than
hoped for: enough entries that counts by category mean something, drawn from
episodes nobody chose to flatter the conclusion, with at least one written
first-hand. That would be a claim about what authoring a calculus in a
solver-facing language costs — which is the question ynoia's account leaves
open, and which nobody has measured. Until then, the entries are worth reading
and are not a paper.

## The name

*Mimesis* (Greek **μίμησις**, "imitation") is Aristotle's word for learning by
representing — the way a craft is picked up from worked instances before it can
be stated as a rule. It names this project because the proposal is that somebody
learns to express a calculus in Eunoia from instances worked in front of them,
**not** by being handed an existing signature to copy: imitation of the *doing*,
not of the artifact. A case study is that word taken literally — the doing of
somebody who has already done it, set down in enough detail to be imitated and
argued with. If it turns out that the fastest route to a new signature
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

**The register of entries.** Each case study is one row; the ledger of
[goal 3](#the-charter) will be another document once there is more than one
entry to cross.

| document | what it is for |
| --- | --- |
| [`docs/case-study.md`](docs/case-study.md) | **Case study: BV abstraction.** One CPC rule from a paper's lemma schemes to a Eunoia signature, into Logos as 11,168 lines of Lean, the unsoundness the proof found there, and what seven lines of signature were worth in proof lines. Read from two development branches on 2026-09-16, and written so that it stands if they are rebased away |

## Endings

Three endings, and a person picks.

- **Folded** into the parent, which is the likeliest: what the ledger establishes
  becomes part of what [Starting a new
  calculus](../../README.md#starting-a-new-calculus) documents, the mechanisms
  goal 5 identifies become requests or flags somebody else owns, and this
  directory goes away. A child project that succeeds at making its parent easier
  to start with has no reason to survive the change.
- **Graduates** into its own repository, if the entries show the subject is
  Eunoia rather than this framework — a collection of case studies about writing
  signatures belongs somewhere an author who is not using eudaimonia can find
  it, and the register entry changes to say so.
- **Retired in place**, with a line saying what was learned. [The
  measurement](#the-measurement) names the two results that lead here, and
  neither is a failure of the work.

Going quiet is not one of them. A directory that has not moved and that nobody
is standing behind is a claim nobody is defending, and the honest form of that is
a retirement note.

*Started 2026-09-16 by the maintainer, in an explicit instruction, with the
example calculus of [goal 4](#the-calculus-we-write-ourselves) chosen in the same
conversation — which is the decision the policy reserves for a person, and the
one ynoia's entry says a launch charter owes. **The charter was reoriented the
same day, by the same route:** it had led with writing one calculus ourselves,
and the maintainer set accumulating case studies as the main goal for now. That
is a scope decision, so it is recorded here rather than absorbed silently.
Nothing has been delivered, so nothing above is an exception the policy would ask
this project to name, and the island is stated as fact rather than as
intention.*

[policy]: https://github.com/ajreynol/kanon/blob/main/docs/policy.md#child-projects
[work]: https://github.com/ajreynol/kanon/blob/5545d5cd20578ec890100810aa59165bb782c6e1/tools/ynoia/tools.md#mimesis--helping-authors-write-signatures-from-scratch
[why]: https://github.com/ajreynol/kanon/blob/5545d5cd20578ec890100810aa59165bb782c6e1/tools/ynoia/why-eunoia.md#mimesis--helping-authors-write-signatures-from-scratch
[names]: https://github.com/ajreynol/kanon/blob/5545d5cd20578ec890100810aa59165bb782c6e1/tools/ynoia/names.md#reserved-for-an-intended-launch
[manual]: https://github.com/cvc5/ethos/blob/main/user_manual.md
[agility]: https://github.com/cvc5/ethos/blob/main/docs/README.md#part-i--the-challenge-to-the-user
