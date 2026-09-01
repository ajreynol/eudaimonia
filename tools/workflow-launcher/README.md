# Workflow Launcher

A **child project** about the first hour of a new tool's life: what somebody has
to decide before a repository exists, and whether handing those decisions to an
agent as a filled-in form produces a better starting point than handing it a
name and a paragraph.

It is the Eudaimonia build framework read one level up. Eudaimonia takes a
calculus you bring and gives you a project that checks proofs in it. This takes
a *vision* you bring and gives you a project that pursues it — same staging,
same templating, and a renderer that is an agent rather than `sed`, which is
where the interesting differences are.
[docs/analogy.md](docs/analogy.md) is that comparison stage by stage, and it is
maintained as the thing this project is *for*, not as a decoration on it.

## The charter

**The question.** Is rigor portable? The bet this ecosystem is running is that
infrastructure making it cheap to say *fill this repository with a vision and
the tooling that lets an agent maintain it with the rigor I use elsewhere* is
the lever that matters. That bet has a demonstrated half and an undemonstrated
half — rigor does transfer, and what it has so far produced is repositories that
are accountable rather than repositories that ship. This project is where the
distinction is written down, and the launch is how it gets tested.

**The goals, in order.**

1. Keep the register of **what we are finding out and what of it is teachable**
   — the practices here that are not obvious and might be worth somebody else
   copying, and, in the same list, what is wrong with them.
   [docs/ai-workflows.md](docs/ai-workflows.md).
2. Keep [interview.md](interview.md): the questions a new tool has to answer
   before anybody writes a line of it, in a form an agent can read.
3. Keep the machinery that turns an answered interview into a prompt and hands
   it to an agent — [bin/launch](bin/launch) — so that the answer to *what did
   you actually run* is a file rather than a memory.
4. Keep the analogy to the build system downstairs current, in both directions:
   what transfers, and what cannot.

**The stretch goal.** That somebody starts a real repository this way and the
result is better than what they would have typed — measured by what the first
week of that repository needed corrected, against `init_eo` as the baseline.

**What is out of scope.**

- **Creating anything outward-facing.** A launch never creates a repository, an
  organisation or a remote, never pushes, never commits, and never touches
  credentials. It writes into a directory a person already made, and leaves the
  work staged. This is the one boundary that is not a preference: the ecosystem's
  repository policy places repository creation behind a person precisely because
  a workflow that can name a gap, argue a tool should exist, take a name and
  write its README must not also be able to publish it.
- **Running an agent in CI.** Nothing here runs on a push, on a schedule, or
  unattended. Every command is one a person types.
- **Naming things.** The register of ecosystem names is anoieu's and stays
  anoieu's; the interview asks which name you took and where it is recorded, and
  refuses to invent one.
- **Replacing `init_eo`.** That command owns the naming step and does it well.
  The interview points at it rather than reimplementing it.
- **Deciding whether a tool should exist.** The interview is answered by a
  person who has already decided.
- **Anything after the first hour.** No maintenance, no scheduled audit, no
  ongoing relationship with what a launch produced. It hands over and stops.

## The name

*Workflow launcher* is descriptive and it is not Greek, which is a departure
from the ecosystem's convention — the register asks for a Greek word that
describes what a tool does to its subject, and holds that a name whose
explanation is a stretch means the scope is not settled yet. That is exactly the
state this is in, so a working name is the honest label rather than a borrowed
etymology.

The convention is not being waived. A Greek name is owed before this graduates
anywhere, and the candidate worth arguing about is **oikistes** (οἰκιστής) — the
founder a Greek city sent out to establish a colony, who carried fire from the
mother city's hearth and then governed nothing. That is the shape of the thing:
it hands over a beginning and has no further authority over what grows. Taking
it means an entry in the register, which is a decision for a person and has not
been made.

## An island

Nothing in Eudaimonia links here, imports from here, or runs anything here. This
directory is not on any build path, not in any CI job, not in any generated
document, and nothing anywhere breaks if it is deleted — deleting it is the
test. It reads whatever it likes and writes only inside itself and into a target
directory a person names on the command line.

**It has no responsibilities.** Nothing depends on it, it owes nobody an
artifact, it carries no findings ledger against anybody else's tree, and it has
no correspondence channel — a child project is addressed through the repository
that carries it, because a thing that may be retired next week should not be
creating obligations.

It is expected to develop here for the time being and may be promoted to a
repository of its own later. That decision is a person's, and until it is made
this stays self-contained on purpose: everything it needs is in this directory,
so promotion is a move rather than an extraction.

## What it maintains

Three things, and the first two are the point.

| | |
| --- | --- |
| [docs/ai-workflows.md](docs/ai-workflows.md) | **The findings register.** What this ecosystem is doing that looks novel, what of it generalises past this ecosystem, and — on the same list rather than in a section at the end — what is wrong with it. Every claim carries what would falsify it, because the failure mode of a document like this written by an agent is a list of flattering observations. anoieu's development-vision page grades the tools and remains the authority on whether the work is good; this asks the different question of what has been found out. |
| [interview.md](interview.md) | **The form.** What this is, and what a person has to settle before a repository exists: the name and where it is registered, the vision, the initial tools, the toolchain, which ecosystem machinery to adopt and which to leave, how the work will be run, and what the agent must not do. Eleven questions, five of them required. |
| [bin/launch](bin/launch) and [prompts/](prompts) | **The machinery.** Assemble the answers into a prompt, show it, and — separately, explicitly — hand it to an agent in a directory somebody already made. An informal install: the same stage as compiling a signature, with none of the guarantees. |

## The analogy, in one table

| | Eudaimonia | here |
| --- | --- | --- |
| what you bring | a signature and its semantics | an answered interview |
| the settings | [`config.sh`](../../config.sh) | [`launcher.conf`](launcher.conf) |
| the generator | [`scripts/new-checker.sh`](../../scripts/new-checker.sh) | [`bin/launch`](bin/launch) |
| what it renders | [`templates/`](../../templates), one file per generated file | [`prompts/`](prompts), one file per stage |
| what does the writing | `sed`, substituting `@CHECKER@` and four others | an agent, over a prompt with `@NAME@` and three others substituted the same way |
| the install | a pinned compiler, fetched and built | a person running one command and watching |
| the check | reinstalling reproduces the package byte-for-byte, and CI proves it | a second agent reads the result against the interview, and a person reads both |
| what a run produces | a checker for one calculus | a repository for one tool |
| in CI | six configurations, each running its own CI, in about 105 seconds | **nothing** |

The last two rows are where the analogy stops being flattering, and
[docs/analogy.md](docs/analogy.md) is mostly about them. A template rendered by
`sed` is a function; a prompt handed to an agent is not, and every guarantee
Eudaimonia advertises rests on the difference.

## Running it

Nothing is installed and nothing is built. `bin/launch` is a shell script.

```bash
tools/workflow-launcher/bin/launch new mytool     # copy the interview to answers/mytool.md
$EDITOR tools/workflow-launcher/answers/mytool.md # answer it
tools/workflow-launcher/bin/launch check mytool   # what is still unanswered
tools/workflow-launcher/bin/launch prompt mytool  # the assembled prompt, and nothing else
```

Then, once a person has created the target directory:

```bash
tools/workflow-launcher/bin/launch run mytool --target ~/mytool
tools/workflow-launcher/bin/launch review mytool --target ~/mytool
```

`run` is the only command that spends anything, and it refuses more than it
accepts: no target, a target that is not a directory, a target inside this
repository, a target that already has files without `--force`, or an interview
with a required answer missing, and it stops. `prompt` is the default way to
work — see exactly what would be sent, decide, then send it.

There is a worked example, so none of this needs a tool invented first — the
counterpart of the specification directories the generator downstairs ships:

```bash
tools/workflow-launcher/bin/launch check  tools/workflow-launcher/examples/answered.md
tools/workflow-launcher/bin/launch prompt tools/workflow-launcher/examples/answered.md
```

```bash
tools/workflow-launcher/bin/launch stages         # the catalogue: what each prompt is for
tools/workflow-launcher/bin/launch --help
```

## Layout

| path | what it holds |
| --- | --- |
| `interview.md` | the form: the questions, why each is asked, and the answer slots |
| `launcher.conf` | where a launch writes, which agent command to use, and the defaults |
| `bin/launch` | assemble, check, show, run, review |
| `prompts/setup.md` | the setup prompt — what an agent is told to build |
| `prompts/review.md` | the review prompt — read the result against the interview, change nothing |
| `examples/answered.md` | the worked example: an interview filled in, so the machinery can be pointed at something real |
| `answers/` | filled-in interviews, not kept in git; `answers/README.md` says why |
| `docs/` | the analogy and the research summary, indexed by `docs/README.md` |

## Where to read next

- [docs/analogy.md](docs/analogy.md) — the build system downstairs and this one,
  stage by stage: what transfers, what does not, and what a launch cannot
  promise as a result.
- [docs/ai-workflows.md](docs/ai-workflows.md) — the research summary: what is
  captured across the ecosystem, what is retyped, and what is not in the record
  at all.
- [interview.md](interview.md) — the form itself, which is also the clearest
  statement of what this thinks a new tool has to decide.
