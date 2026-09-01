# How well is the ecosystem leveraging AI workflows?

The tools in this ecosystem are mostly written by agents, and there is already a
document about what that work should be aiming at: anoieu's development-vision
page, which sets out the tenets, grades every tool against them, and is the
ecosystem's authority on the subject. **It remains the authority.** Nothing here
displaces it and nothing here binds anybody.

This asks a narrower question that it does not ask. Not *is the work good* —
that page argues it, and argues that nobody may automate the answer. This one:
**is any of the work captured?** Is there, anywhere, a workflow somebody else
could run, or is every agent-assisted hour in this ecosystem driven by a prompt
that was typed once and thrown away?

That question has an answer a program can mostly find, which is why it is worth
asking separately.

## What was measured, and when

Six checkouts on one machine, read on 2026-09-01, at these commits:

| repository | commit |
| --- | --- |
| anoieu | `f1eac5b` |
| logos | `6cb59db5` |
| eudaimonia | `a93fbec` |
| dokimasia | `355edf2` |
| koine | `dfb0dd0` |
| ethos | `7f4482b7` |

The measures are greps, and they are named with each finding so anybody can
disagree with the grep rather than with the conclusion. This is a reading of one
set of working trees at one moment, not a survey of anybody's practice: what a
person actually does with an assistant is invisible here by construction, and
that limit is the whole reason the question was narrowed to what is *captured*.

## The findings

### 1. Two repositories of six capture a workflow at all

| repository | captured workflows | lines |
| --- | --- | --- |
| anoieu | 8, in `scripts/prompts/` | 1,637 |
| dokimasia | 3, in `scripts/` | 714 |
| logos | — | — |
| eudaimonia | — | — |
| koine | — | — |
| ethos | — | — |

*Measured by* looking for scripts that invoke an assistant on a prompt they
carry. Both sets have the same shape, which is the shape worth copying: a
switch chooses between two vendors, a flag prints the prompt and runs nothing, a
flag runs non-interactively, the command refuses rather than guesses, and it
hands over the terminal by default because a run is a thing somebody watches.

### 2. Every one of them is about the reporting loop, not about production

The eleven, by what they do: write a new tool's README from the name register;
adopt the shared policy; check whether adopting it took; welcome a new tool and
draft a first message to it; work another repository's correspondence topics;
answer our findings from inside the project they are about; process the reply
that came back; audit the whole ecosystem against policy — and, in dokimasia,
the same answer-and-process pair aimed at the solver it reports on.

**Not one of them writes a proof, a signature, a template, an analyzer check, or
a line of the thing its repository exists to produce.** The tools were built by
agents; the building was not captured.

Two readings, and this project exists because the difference matters. The
reporting loop is repetitive, its steps are identical every time, and its output
has to look the same coming from every project — three conditions under which
capture obviously pays. Building a tool satisfies none of them. So the workflows
may sit exactly where capture is worth it, and nowhere else, which would be good
judgement rather than a gap. Or nobody has tried, and the first hour of a new
tool's life is repetitive enough to capture and simply has not been. **Nothing
in the trees decides between those**, and finding out is what
[the interview](../interview.md) is for.

### 3. A prompt is a document, and drift from its executable copy fails the build

The best idea in the ecosystem's practice, and it is in both of the repositories
that have any.

dokimasia writes both of its outbound prompts out in full, in prose, in a
document that describes the workflow they belong to; the scripts hold copies so
nobody has to paste one. anoieu's test suite then asserts that the copies still
say what the document says, comparing whole prompt bodies rather than anchoring
part way down — which it does because a stale paragraph once survived a rewrite
of the text above it. The reasoning is worth quoting in substance: a copy that
has drifted is *worse* than no copy, because the drift is invisible from the
side that matters, which is somebody in another repository reading a prompt they
were sent.

The stronger form of the same discipline is to have one copy: a script that
*reads* its prompt from a file cannot drift from it. That is what this project
does, and it is worth being fair about why the other two do not — their scripts
are single self-contained files on purpose, so that one can be handed to
somebody and run in a checkout that has none of the rest. That is a real reason
and it costs them a test.

### 4. No agent runs unattended, anywhere

*Measured by* looking for any assistant, vendor or model named in any CI
workflow across all six repositories: **zero**, out of eight workflow files.
Every captured workflow is a command a person types.

This is load-bearing rather than incidental. The reporting discipline requires a
person to carry a finding across a repository boundary; correspondence between
tools is written by machine and carried by hand; and creating a repository is
stated as a break in the chain that must have a person in it, on the grounds
that a workflow able to notice a gap, argue for a tool, take a name and write
its README must not also be able to publish it. The absence in CI is the same
decision seen from the automation side, and this project inherits it — nothing
here runs on a push, on a schedule, or unattended.

### 5. There is no per-assistant context file anywhere, and adding one is forbidden

*Measured by* looking for the conventional agent-instruction files at the root
of each repository: **zero across all six**. The shared policy names this
directly and refuses it — a repository that grows one entry-point file per tool
that might read it has replaced a convention with a directory listing.

The bet is that the ordinary documents are the context: the front page, the
policy, the vision, the workflow documents. It is an unusual bet — the industry
default is the opposite — and it is **untested**. Nothing anywhere measures
whether an agent handed only those documents produces work that complies with
them. The one place it looks measurable is the joining workflow, whose prompt is
checked against the policy, but what that checks is that the prompt matches the
document, not that the output matches either.

### 6. The largest claim about what any of this bought is not in the record

logos carries a 98-line file holding an estimate that its proof development —
some 658,000 proof lines, 591 rule modules, over about four and a half calendar
months — would have taken on the order of 25 expert person-years without
generative AI. In the checkout read, the file is **untracked**.

Take the estimate for what it is: a model's answer to a question about its own
contribution, which is close to the weakest form of evidence available, and it
is offered here as an artifact rather than as a number to rely on. What is
checkable is the second half — the ecosystem has no record of the question. This
is the single largest claim anybody has made about what these workflows are
worth, and it is sitting in a working tree.

*The honest caveats*, both of which could overturn this: it was read from one
working tree, so it may be committed elsewhere; and a file may be deliberately
local, which the ecosystem has a suffix convention for and this file does not
use. It is recorded here as an observation about the record, not as a finding
against anybody, and it has not been through the reporting workflow that a
finding would have to go through.

### 7. Two kinds of machinery are called by one name

eudaimonia's generator is a function of its inputs: reinstalling from a
signature reproduces the package byte-for-byte, and a CI group exists to prove
it on every push. anoieu's and dokimasia's prompts reproduce nothing and cannot.

Both live in `scripts/`. Both are described as the repository's machinery. **No
document anywhere distinguishes them** — and the distinction is the whole of
what a reader needs in order to know how far to trust an output. A reader who
has learned that this ecosystem's tooling regenerates its results
byte-for-byte will carry that expectation into a directory where it is not true
and nothing will correct them.

Working out that distinction precisely, for one case, is what
[the analogy document](analogy.md) is.

## What follows

Three things, in the order they are worth doing, and none of them is a
recommendation to anybody — this is a child project with no standing to make
one, and each of these is work for whoever owns the tree it touches.

1. **Find out whether the first hour is capturable.** That is this project's
   own job and the reason it exists. The test is somebody answering the
   interview for a tool nobody here thought of, and the machinery needing no
   change.
2. **Say which machinery reproduces and which does not**, wherever both kinds
   sit in one directory. One line in a script header would do it.
3. **Commit the question, not the answer.** Whatever the productivity estimate
   is worth, the prompt that produced it and the date it was asked are the parts
   that would let somebody ask it again in a year and compare.

## What this is not

- **Not authoritative.** anoieu's development-vision page governs this subject
  and this does not. Where the two disagree, that page is what the ecosystem
  agreed to and this is a second reading of a narrower question.
- **Not a set of findings.** A claim about somebody else's work reaches them
  through a reporting discipline — confirmed, reproduced small, carried by a
  person — and nothing here has been through any of it. Nothing here has been
  sent to anybody.
- **Not evenly evidenced.** Everything above is a grep over text. What a person
  actually does with an assistant, how many attempts a result took, and what was
  thrown away are all invisible from here, and they are most of the subject.
- **Not a ranking.** Four of the six repositories have no captured workflow and
  that is not a mark against them; a repository that produces a proof
  development does not obviously have anything to capture. Where a measure fits
  a project badly, that is a fact about the measure.
- **Not current for long.** It is a reading of six trees on one day, pinned to
  the commits named above. Re-run the greps before relying on a number.
