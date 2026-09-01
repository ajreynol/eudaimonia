# The interview

**What this is.** A form. You answer it, and a launcher assembles your answers
into a prompt for an agent that sets up your new repository. It is the
specification of a launch, the way a signature and its semantics are the
specification of a checker downstairs — and like that one, it is the part you
bring and nothing else can supply.

**Why a form rather than a conversation.** Because the answers are the record. A
repository set up by an agent from a prompt somebody typed once has no account
of what it was asked for, so when the result is wrong there is no way to tell
whether the instruction was wrong or the agent was. A filled-in interview is
that account, and it costs a copy of one file to keep.

**This form is agnostic**, and deliberately: nothing in it assumes what kind of
tool you are building. Questions that only make sense for one *kind* of tool
live in `supplements/` — a directory beside this file in the launcher — and are
merged in when you ask for them,
so the core never grows a question most launches would skip.

```bash
bin/launch supplements                    # what exists, and when each applies
bin/launch new <name> --with measurement  # core + that supplement, in one file
```

**How to use it.**

```bash
bin/launch new <name>       # copies this file to answers/<name>.md
$EDITOR answers/<name>.md   # answer it
bin/launch check <name>     # what is still unanswered
bin/launch prompt <name>    # the assembled prompt, and nothing else
bin/launch run <name> --target <dir>
```

**How to answer.** Write between the two markers under each question. Leave the
markers alone — they are how the launcher finds your answer.

```
<!-- A0 optional -->
this line is the answer
<!-- /A0 -->
```

Questions marked **required** must be answered or `run` refuses. Questions
marked **optional** may be left empty, and an empty one is dropped from the
prompt rather than sent as a blank — an agent handed an empty heading will fill
it in, which is the failure this whole file exists to prevent.

**No relative links in this file.** It is copied into `answers/` and is read
from wherever the copy lands, so a link that resolves here resolves nowhere
else. Name paths in backticks and say what they are relative to.

**Question numbers are stable.** Append; do not renumber. An answered interview
is a record, and two of them should be comparable a year apart.

**What the agent will not do**, whatever you write here: create a repository, an
organisation or a remote; push; commit; or touch credentials. It writes files
into a directory you already made and leaves them staged for you to read. If
what you want needs one of those, do it yourself first and point the launch at
the result.

---

## What the tool is

### Q1 — The name, and where it is registered

**Required.** Give the name the repository will have, and say where it is
recorded. The ecosystem keeps a register of reserved names with an etymology and
a line of scope for each; a name that is in it comes with an account somebody
already argued for, and the agent is told to use that account rather than invent
one.

If your name is not in the register, say so explicitly and say why — a
descriptive non-Greek name is allowed where the thing is a program rather than
an account, and it is much better to declare that than to have an agent write a
Greek etymology for a word that has none.

**A bad answer** is a name with no second sentence. **A good one** names the
word, where the entry is, and what you take the scope in that entry to be.

<!-- A1 required -->

<!-- /A1 -->

### Q2 — What it is, in two sentences

**Required.** What the tool is, and what question it answers. Present tense,
about what will exist, not about what it might grow into. This is the front-page
paragraph, so write it as you want it read.

What it *refuses* to answer is asked separately, twice and for different
reasons: Q3 asks what a successful run does not establish, and Q5 asks what the
tool will not do. Keep this one to the positive claim.

<!-- A2 required -->

<!-- /A2 -->

### Q3 — The vision statement

**Required.** What the work is aiming at, in a paragraph somebody could
disagree with. This is the one answer the agent is told to treat as
authoritative and to quote rather than paraphrase.

Two things worth putting in it, because they are what the ecosystem's own
development vision asks a new tool for and both are cheap now and expensive
later:

- **Name the first consumer.** The tool, the repository, the job or the person
  that will read this tool's output, and the exact artifact it takes. A tool
  with no nameable consumer is being built for its author, and an agent will
  happily keep building it for its author indefinitely.
- **Say what a successful run does not establish.** Not what the tool declines
  to do — that is Q5 — but what a clean result is *not evidence of*. A tool
  whose caveat is three clicks in has not published it.

<!-- A3 required -->

<!-- /A3 -->

### Q4 — What already answers this, and why it is not enough

**Required**, and *nothing does* is a complete answer if it is true.

Name the incumbent: the tool, the script, the paper, the spreadsheet or the
habit that answers this question today. Then say what is wrong with it — too
slow, too manual, wrong granularity, unmaintained, answers a nearby question
instead.

This is the mirror of naming the consumer, and it is here because it is the
question an agent cannot answer for you and will not think to ask. Given
silence, it will build the conventional version of your tool, which is usually
the incumbent with a new name. Naming the incumbent is also what tells the agent
what *not* to reimplement.

**If the honest answer is that you have not looked**, write that. It is a better
input than a guess, and it tells whoever reads this later how much weight the
rest of the interview can carry.

<!-- A4 required -->

<!-- /A4 -->

### Q5 — Out of scope

**Required.** An explicit list of what this tool will not do. Every item you
write is a file the agent will not create and a section it will not add.

Include **the larger question a reader will assume you are answering.** That is
usually the most valuable line in the whole interview: it is the claim your
front page will be read as making unless it says otherwise.

A perfunctory list beats an empty one. Silence here is filled with the
conventional thing, every time.

<!-- A5 required -->

<!-- /A5 -->

### Q6 — One repository, or the first of several

**Optional.** If this is meant to be one tool, leave it empty and the agent will
build one tool.

If it is the first of a family — several tools around one subject, sharing a
corpus, a format or a reporting path — say so and say what the others are
likely to be. It changes what belongs at the top level, whether anything should
be factored out on day one, and whether the shared part deserves its own name
now or later. The default answer is **one**: factoring for tools that do not
exist yet is the most expensive guess available.

<!-- A6 optional -->

<!-- /A6 -->

---

## What the repository contains on day one

### Q7 — The initial tools

**Required.** What should exist in the repository when the launch finishes. Be
concrete: name the executables, the entry points, the directories. "A CLI called
`foo` that reads X and prints Y", not "some tooling".

Say for each whether it should be a **working stub** — something that runs end
to end on a trivial input from the first command — or a **placeholder** that
states what belongs there and does nothing. The first is almost always the right
answer: a project that begins by changing something that works is in a different
state from one that begins by filling in blanks.

If the honest answer is "nothing yet, just the README", write that. It is a
legitimate answer and the naming workflow's default, and the agent is told not
to argue with it.

<!-- A7 required -->

<!-- /A7 -->

### Q8 — Language, toolchain and build

**Optional.** The language, the version, how it is built and how it is run. If
there is a version to pin, pin it here — an agent choosing a toolchain version
on your behalf will choose whatever it saw most of.

Leave empty if the repository is documents for now.

<!-- A8 optional -->

<!-- /A8 -->

### Q9 — Tests and evidence

**Optional.** What the first test is, and what it establishes. If the tool makes
claims about somebody else's program, say whether their output is to be recorded
from a real run and committed, rather than written from memory.

<!-- A9 optional -->

<!-- /A9 -->

---

## What to take from the Eunoia ecosystem

### Q10 — What to adopt, and what to leave

**Required**, and "nothing" is a complete answer. This is the question the
launcher exists for: everything below already exists, works, and is somebody
else's to maintain, and the cost of adopting a piece of it is real.

Say **yes**, **no**, or **later** to each, and add anything not listed.

| | what it is | what adopting it costs |
| --- | --- | --- |
| **the repository policy** | the shared arrangement — where files go, what the front page must say, how a child project behaves — checked by a program another repository runs in its own CI | one workflow file, a pinned commit, and a layout you did not choose |
| **the membership declaration** | the front-page paragraph saying the repository follows that policy | it is a public commitment, and the check goes red when you drift |
| **the discussion channel** | a standing correspondence file for questions and proposals between tools, with a response gate at the top | a file to keep, and an obligation to answer |
| **the reporting workflow** | how a finding about somebody else's work is confirmed, reproduced small, carried by a person, and closed with a verdict | the discipline is the point and it is not free |
| **the shared reporting machinery** | the protocol implemented once rather than once per member | a dependency on a young repository |
| **the calculus template** | bring a signature, get a proof checker and the scaffolding of its proofs | only relevant if your tool checks proofs |
| **the proof checker and its compiler** | the reference implementation, and the compiler that turns a signature into Lean | a build dependency, pinned to a commit |
| **the analyzer** | reads signatures and reports findings | it is a tool you would run, not a thing to vendor |

**Say `no` generously.** A new tool with a clear purpose and no policy is worth
more than a compliant one with nothing to say, and the ordering is deliberate:
knowing what you are building is what makes the rest of it decidable. Adopting
the policy later is one command; unpicking a layout you never wanted is not.

**If your subject is outside the ecosystem**, say so here, because it changes
what the reporting rows mean. The ecosystem distinguishes projects it *includes*
from projects it *serves* — the solver is the second kind, outside and the
reason the rest exists — and a tool pointed at one of those is reporting
outward, to maintainers who did not ask and are under no obligation. Two things
follow that the table does not capture: nothing crosses a repository boundary by
machine, a person carries it; and a member already runs a findings loop against
the solver, so the pattern exists and is worth reading before inventing a second
one. Name the project your findings are *about*, and who you expect to read one.

<!-- A10 required -->

<!-- /A10 -->

### Q11 — Who runs the work

**Optional.** People, agents, or both — and under what supervision. This decides
one paragraph the ecosystem's policy asks every front page to end with, and it
decides how everybody else reads the tool: a project run by people is read as
somebody's considered choices, and one run by agents is read as work that has
not been vetted by a person at the level of internal design. Getting this
paragraph wrong in either direction misleads.

Leave empty and the agent is told to state the honest default — that the
repository was set up by an agent from this interview, and that who maintains it
is undecided.

<!-- A11 optional -->

<!-- /A11 -->

---

## Bounds on the launch

### Q12 — What the agent must not do

**Optional.** Anything beyond the standing refusals. Files not to create,
directories not to touch, conventions not to import, opinions not to have. This
list is passed through verbatim and the agent is told it outranks everything
else in the prompt.

The standing refusals, which you do not need to repeat: no repository, no
remote, no push, no commit, no credentials, and nothing written outside the
target directory.

<!-- A12 optional -->

<!-- /A12 -->

### Q13 — The target directory

**Optional.** Where the repository is, if you already know. `--target` on the
command line overrides whatever is written here.

It must exist before a launch runs. Creating it is yours — that is the step the
ecosystem's policy deliberately places behind a person, because a workflow that
could notice a gap, argue for a tool, take a name, write its README *and*
publish it would have no person in it anywhere.

<!-- A13 optional -->

<!-- /A13 -->
