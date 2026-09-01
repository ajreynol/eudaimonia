# What we are learning, and what of it is teachable

This is the register of **claims about our own practice**: things the Eunoia
ecosystem appears to be doing that are not obvious, are not widely done, and
might be worth somebody else copying — and, in the same list and on the same
footing, the things that are wrong with it.

It is not a report card. anoieu's development-vision page grades every tool
against the ecosystem's tenets, and it remains the authority on whether the work
is good. This asks a different question: **what, if anything, have we found out
that generalises?**

Two disciplines, because the failure mode of a document like this written by an
agent is a list of flattering observations:

- **Every claim carries what would falsify it.** A claim with no falsifier is a
  slogan and is marked as one.
- **The criticisms are in the same list as the discoveries**, not in a section
  at the end where they can be skipped. Several of the entries below are about
  this repository and its parent.

Measured across six checkouts on 2026-09-01: anoieu `f1eac5b`, logos `6cb59db5`,
eudaimonia `a93fbec`, dokimasia `355edf2`, koine `dfb0dd0`, ethos `7f4482b7`.
Everything below is a grep or a read over those trees.

---

## The central claim, and the correction it needs

**The claim.** The lever is infrastructure that makes it cheap to say *fill this
repository with a vision and the tooling that will let an agent maintain it with
the rigor I use elsewhere*. Rigor, on this claim, is portable, and porting it is
the thing that scales.

**The half that holds.** Rigor is portable, and the mechanism is a program
rather than a document. `policy_check.py --root <path>` runs against a
repository that is not its own and decides a set of layout claims without an
opinion; a workflow installs it pinned to a commit; six repositories have
converged on one layout and one front-page shape. The interface is tested at
home rather than trusted. That is a working demonstration that a standard can be
handed to another project as an executable rather than as a page somebody has to
read and agree with.

**The half that does not.** Rigor makes an agent-maintained repository
*legible and auditable*. It does not make it *productive*, and the evidence that
these come apart is in the tree.

> **koine** is a declared member of the ecosystem. It has four commits, four
> files, and no line of anything but Markdown and one CI workflow. Its README is
> 7.4 KB and is genuinely good: it states what the tool is for, names its two
> customers by name, refuses to invent features neither has asked for, and draws
> the boundary that makes it cheap to depend on. The tool does not exist.

Nothing went wrong there. The infrastructure worked exactly as designed and
produced, quickly, a rigorous and well-governed account of software nobody has
written. That is the shape of the risk: **agents are excellent at the
accountability half and ordinary at the other half, so infrastructure that
lowers the cost of the accountability half biases the whole system toward
well-governed emptiness.** The bias is not hypothetical and it is not confined
to koine — anoieu's own grading of itself says a stretch of work producing
thousands of lines of governance changed nothing about what its analyzer finds.

**So the defensible form of the claim is narrower**: the infrastructure makes it
cheap to bring a new repository up to a standard of *accountability*, and says
nothing about whether it has anything to be accountable for. That is still a
strong claim and still worth teaching. It is a different claim from the one that
sounds like it.

*Falsified by:* a repository launched this way that ships something a person
outside the ecosystem uses, within a month, without the launch machinery having
been edited for it. Nothing has done this yet. Until one does, the lever is
demonstrated for governance and undemonstrated for product.

---

## What looks novel

### N1 — A self-improving loop that publishes its own regression

The most developed thing in the ecosystem and the least like anything else in
it. The outbound prompt that an agent runs *inside the project a finding is
about* ends by asking for feedback on the reporting process itself: where the
time went, what a row should have carried, what was unclear or untrue, and what
is worth looking for that the analyzer does not do. That feedback comes back in
a designated field, is processed by a second workflow at home, and lands in a
postmortem log with one entry per round.

The feedback request is not the novel part; asking for feedback is cheap and
common. Three things around it are:

**The loop's own cost is measured, and the measurement says it is losing.** A
standing rule holds that every round leaves the prompts clearer and *shorter*. A
table in the postmortem records prompt length by round: 60 → 54 → 56 → 59 for
the outbound prompt, 39 → 63 → 63 → 67 for the follow-up. Three rounds, three
increases, and the log says so in those words, names which addition paid for
itself and which did not, and carries a named removal candidate that is
"two rounds overdue."

A self-improving process is a common claim. **A self-improving process that
keeps a metric on itself, reports the metric going the wrong way, and does not
quietly retire the metric is rare**, and it is the part to teach.

**Every rule in the loop names the incident that produced it**, on the grounds
that a rule with no incident behind it is a preference. The table of standing
rules has a *from* column. Several entries read "standing" — those are the
preferences, and they are visibly marked as such rather than dressed as
findings.

**A person approves every prompt change**, because a template that rewrites
itself from its own experience drifts with nobody agreeing to the direction.
This is the correct answer to the obvious failure of a process-feedback loop and
it is stated as a rule with its reason attached.

*Falsified by:* the prompt-size table being deleted, or the rule being weakened
to match the numbers rather than the numbers being brought to the rule.

### N2 — The loop has one participant, and calling it mutual overstates it

Filed here rather than under what is wrong, because the correction is more
interesting than the defect.

Feedback runs one way. The far-end agent tells us how to report better; nothing
tells the far end how to respond better. The clearest case is the round where
nineteen rows came back with ten declined and none of the declines pushed back
on — a process defect that arguably sat at the far end, and the fix was *we ask
for confirmation*. Every process improvement to date has been absorbed by the
side that raised the finding.

That is probably correct behaviour: you have no standing over somebody else's
process, and claiming some would be the fastest way to lose a correspondent. But
it means the accurate description is **an agent-run tool that improves its own
outbound process from the replies it receives** — which is true, narrower, and
still unusual — rather than agents critiquing each other's processes, which is
not what exists.

*Falsified by:* one instance of the far end changing how it works because of
something we sent, that we did not have to fix on our side instead.

### N3 — Publishing the coverage gap on every run

The policy checker prints, on every invocation, every rule it **cannot** decide,
with the honest reason: *intent; no artifact records who asked*; *a claim about
tone, not about the tree*; *absence of an action cannot be observed here*.
Twelve such entries today against nineteen checks.

Nearly every quality gate silently implies that its coverage is its scope, and a
green tick is read as *checked* by exactly the readers least able to know
better. Publishing the uncheckable list on every run costs one array and
inverts that. It is the cheapest idea in the system and the most portable — it
needs no policy, no ecosystem and no agent to be worth copying.

*Falsified by:* nothing; this one is a mechanism rather than a claim. The
question is whether anybody reads it, and nobody has measured that.

### N4 — Refusing to automate the judgement half, and drawing the line mechanically

The governing split is that a program checks policy and never checks vision,
because a checker returning a verdict on *is this tool fruitful* would
manufacture an authority that does not exist. What makes this more than a
sentiment is the test that comes with it: *can a program decide it from the tree
without an opinion?* If yes it is policy, move it and check it; if no it must
never acquire a checker. The asymmetry is stated to run both ways — a judgement
somebody works out how to check mechanically was probably policy all along.

The transferable part is that the boundary is **decidable and movable**, rather
than a standing claim about what machines may judge.

*Falsified by:* a check appearing that decides a vision question, or a policy
rule sitting undecidable for several rounds with nobody moving it.

### N5 — Speculative work is quarantined by construction, and may not borrow credibility

Work about a tool that does not exist goes in a subdirectory of the parent,
where it reads whatever it likes, writes only inside itself, imports nothing and
is imported by nothing, and **is not advertised** — no row on the front page, no
line in the documentation index. The stated reason is not secrecy. It is a
refusal to borrow the host tool's credibility for work that has not earned any
of its own, because a speculative account carrying an established tool's name is
read as that tool's position and withdrawing the impression later costs more
than the work is worth.

The deletion test is what makes it real: if removing the directory changes what
the tool does or what CI says, it was never an island.

The reason this matters more in an agent-run ecosystem than elsewhere is a rate
argument. Speculative work is what agents produce most readily and most
plausibly, and the binding constraint on it is a person's ability to triage. A
convention that keeps it *visible, committed, and structurally unable to be
mistaken for the product* is a triage mechanism, not a filing rule.

*Falsified by:* a child project's conclusions being cited as the parent's
position by somebody outside, despite the quarantine.

### N6 — A named exception beats an unnamed one

When a child project becomes genuinely useful it starts breaking the island
rules, because being useful means being depended on. The system's answer is not
to forbid that and not to ignore it: the project stays where it is and its
README must state what it delivered, **which of the rules have stopped being
true of it**, and that the promotion decision is open and with whom. The checker
enforces the shape — an island break with no declared exception is a failure; an
island break with one is printed and passed.

*A named exception is a decision somebody made and can defend; an unnamed one is
drift.* That sentence generalises well past this ecosystem and past AI, and it
is the best governance idea in the system.

*Falsified by:* an exception block that has sat unchanged while the project's
couplings kept growing — the mechanism converting into a permanent waiver.

### N7 — The safety argument is about composition, not capability

The best-reasoned paragraph in the ecosystem, and the one most worth taking
outside it. On why creating a repository must have a person in it: the workflow
can notice a gap, argue that a tool should exist, audit that argument against a
standard it also maintains, take a name from a register it also maintains, and
write the new tool's README. **Every one of those steps is defensible. The
composition is not** — if it could also create the repository, the whole path
from an idea to a public artifact under somebody's account would run with no
person in it anywhere.

Almost all discussion of agent autonomy is about individual capabilities. This
locates the risk in the *closure* of a capability set, and then places the break
at the step that is irreversible and outward-facing rather than at the step that
is most alarming. That is a better analysis than the subject usually gets, and
it is why this project refuses to create a repository.

*Falsified by:* the break being routed around in practice — a launch that ends
with a person mechanically approving something they did not read, which is the
same composition with a rubber stamp in it.

### N8 — Two registers of address, chosen by a declared fact

Every front page must end with a note saying how the repository's development is
currently run, and **that note decides how the ecosystem addresses it.** A
project run by people gets an observation and no imperative, because a person
made choices for reasons that need not be visible in the tree. A project run by
agents gets an instruction and no apology, because there is nobody to offend, no
accumulated judgement to defer to, and hedging is expensive at the rate an agent
produces work.

Deliberate etiquette design for a mixed human-and-agent ecosystem, keyed on a
fact the addressee declares rather than on a guess. I have not seen this
anywhere else.

*Falsified by:* the register being chosen by impression rather than by the
declared note — which the policy anticipates and forbids, so the falsifier is
that the forbidding stopped working.

### N9 — The prompt is a document; drift from its executable copy fails the build

A workflow is written out in prose in a document, the scripts hold copies so
nobody has to paste one, and a test asserts the copies still say what the
document says — comparing whole bodies rather than anchoring part way down,
because a stale paragraph once survived a rewrite of the text above it. A copy
that has drifted is worse than no copy, since the drift is invisible from the
side that matters: somebody in another repository reading a prompt they were
sent.

The stronger form is to have one copy — a script that reads its prompt from a
file cannot drift from it — which is what this project does and which is free.
Both repositories that hold the weaker form hold it for a real reason: their
scripts are single self-contained files that can be handed to somebody and run
in a checkout that has none of the rest.

*Falsified by:* the test being narrowed to a substring match, which is how this
class of check usually dies.

---

## What is wrong

### W1 — The system diagnoses precisely and does not treat

The ecosystem's own test of whether a tool is worth anything is that *something
outside it behaves differently because it exists*. By that test, and by its own
account: no other repository runs the analyzer, nothing anywhere consumes its
machine output, and the two fuzzer findings against the reference checker have
not been filed. Its own grading calls the low mark "a description of avoidance
rather than of difficulty" and says the machinery has been finished for a while.

That paragraph has been written. It has not been acted on. **A system that names
its failures precisely and does not fix them has substituted diagnosis for
treatment**, and this is a specifically agent-shaped failure, because writing the
diagnosis is the part an agent does well and enjoys. The quality of the
self-criticism in this ecosystem is genuinely unusual and it is currently
functioning as a substitute for the work rather than as a spur to it.

*The check:* count the entries in this ecosystem's various *outstanding* lists
that have survived more than one round. Seven suggestions from the far end,
none yet built. A removal from a prompt, two rounds overdue.

### W2 — There is no governance budget, and governance is the cheapest thing to produce

The front page has a clutter budget. Nothing else does. The policy is 941 lines;
the captured workflows are 1,637; there are separate documents for vision,
coherence, reporting policy, reporting workflow, postmortem, discussion and the
record — and the round that produced most of that introduced two silent defects
into the fuzzer, one of which would have let CI pass while verifying nothing.

The asymmetry is the mechanism: an agent can produce a well-argued page in
minutes, and every page is individually defensible. Nothing prices the total.
The one rule aimed at this — *every further page has to displace a check, a
finding, or an hour of somebody's reading* — is a rule with no counter attached,
which is the same failure the prompt-size table exists to fix in the other half
of the system. **The prompt-size table should have a document-count sibling.**

This entry is about this project too. It arrived with a README, two documents, a
form, an example and a script, and the honest question is which check or finding
it displaced. The answer today is none.

### W3 — The founding number is unfalsifiable and untracked

The implicit justification for the whole enterprise is a claim that the proof
development would have cost on the order of 25 expert person-years without
generative AI, against roughly four and a half months of elapsed time. It is a
model's estimate of its own contribution — close to the weakest form of evidence
available — and in the checkout read it is an untracked file in a working tree.

Two problems, and the second is worse. It is not in the record, so nobody can
ask the question again in a year and compare. And **nobody has said what would
change if it were wrong by a factor of five.** A number that no decision depends
on is not doing work, and this one is being asked to justify a great deal.

*The fix is cheap:* commit the question and the date, not the answer.

### W4 — The recursion has no floor

Count the layers. A solver is the thing anyone outside cares about, and it is
marked *served* — outside the ecosystem. A proof checker checks its proofs. A
Lean development verifies the checker. A template generalises the development. A
child project audits where the development's weight sits. Another asks whether
the ecosystem's arrangement earns its machinery. Another re-describes the
language as a specification. And now this one, which is a build system for
repositories, carrying a document about how well the ecosystem uses agents.

Every layer is individually justified and most of them are good. The ratio is
still the thing to look at: **work about the work now substantially outweighs
work on the thing at the bottom**, and each new layer is cheaper to add than the
last, because the infrastructure for adding layers is what has been getting
better.

This is the strongest argument against the central claim on this page, and it is
an argument against this project's existence in its current form. The lever is
real. What it has mostly been levering so far is more lever.

*Falsified by:* the ratio moving. It is measurable — lines of tool against lines
about tools, per repository, per month — and nobody measures it.

### W5 — Correctness of the loop's verdicts is not measured

39 findings open and 43 closed, against three projects, is real output and the
best evidence in the system that any of this produces something. What is not
measured anywhere is **how many of the closures were right.** The postmortem
records that three rows sat closed on a fix that never landed and that a verdict
was recorded that was never true; a standing list of desired properties says a
closed row's verdict should be re-derivable and marks that as the highest-value
gap, not checked.

So the loop measures its throughput and its prompt size, and does not measure
its error rate — which is the only number that says whether the process
improvements are improvements.

---

## What this project owes

Nothing on this page has been sent to anybody, and none of it has been through
the reporting discipline a claim about somebody else's work has to go through.
The criticisms above are about trees this repository can read, several of them
about this repository and its parent, and they are written here because this is
where speculative work is supposed to live.

The one thing this project can do that nobody else is positioned to: **the
launch is the experiment.** Every claim on this page about whether rigor
transfers is currently supported by repositories that were set up by people who
already knew all of it. A repository launched from an answered interview by
somebody who has read none of these documents is the first real test, and the
outcome to watch is not whether it complies. It is whether it ships anything.
