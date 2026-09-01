# The interview, answered

**This is the worked example**, not a plan anybody is carrying out. It is here
for the same reason the specification directories downstairs are: so the
machinery can be pointed at something real without anybody first having to
invent a tool.

```bash
bin/launch check examples/answered.md
bin/launch prompt examples/answered.md
```

The tool it describes is deliberately called `mytool` and is deliberately not
in the ecosystem's name register — a placeholder, chosen so that what this
renders is never mistaken for a repository somebody is about to create. Note
what that costs the answer to the first question, and that the honest answer is
to say so rather than to reach for a Greek word.

Everything below this line is the form as `bin/launch new` copies it, with the
answer slots filled.

---

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
`mytool`. **Not in the register, deliberately** — this is the worked example
that ships with the launcher, not a tool anybody is building, and a placeholder
name is the honest label for that.

A real launch names a word from the register and says which entry it took, so
the agent writes that entry's account of it rather than inventing one.
<!-- /A1 -->

### Q2 — What it is, in two sentences

**Required.** What the tool is, and what question it answers. Present tense,
about what will exist, not about what it might grow into.

Then the harder half: **the question it does *not* answer.** Usually it is the
larger one a reader will assume, and a front page that does not name it is one
that will be read as claiming it.

<!-- A2 required -->
A command that reads a Eunoia signature and reports which of its rules no
proof in a given corpus ever uses. It answers: what part of this calculus is
specified and never exercised?

It does **not** answer whether an unused rule is wrong, unnecessary, or merely
unreached by the corpus somebody happened to have. Every one of those looks
identical from here.
<!-- /A2 -->

### Q3 — The vision statement

**Required.** What the work is aiming at, in a paragraph somebody could
disagree with. This is the one answer the agent is told to treat as authoritative
and to quote rather than paraphrase, so write it as you want it to appear.

Two things worth putting in it, because they are what the ecosystem's own
development vision asks a new tool for and both are cheap now and expensive
later:

- **Name the first consumer.** The tool, the repository, or the job that will
  read this tool's output, and the exact artifact it takes. A tool with no
  nameable consumer is being built for its author, and an agent will happily
  keep building it for its author indefinitely.
- **Say what a successful run does not establish.** The caveat belongs on the
  front page, not three clicks in.

<!-- A3 required -->
Coverage of a calculus is currently a thing people assert. This makes it a
number, over one signature and one corpus, and refuses to generalise past the
corpus it was given.

The first consumer is the roadmap of the repository that owns the calculus: it
takes a list of rule names, one per line on stdout, and nothing else. That
format is the deliverable — prose about coverage is not, and a version of this
that only prints a report has not started.

A clean run establishes that every rule in the signature appeared in the corpus
that was read. It establishes nothing about a corpus nobody has collected, and
the front page says so above the fold.
<!-- /A3 -->

### Q4 — Out of scope

**Optional, and the most useful optional answer here.** An explicit list of what
this tool will not do. Every item you write is a file the agent will not create
and a section it will not add.

<!-- A4 optional -->
- It does not run the checker, and does not care whether a proof is valid.
- It does not collect corpora. Point it at one.
- It does not rank rules by importance. Used and unused is the whole output.
<!-- /A4 -->

---

## What the repository contains on day one

### Q5 — The initial tools

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

<!-- A5 required -->
- `mytool cover <signature.eo> <corpus-dir>` — a **working stub**: parses the
  signature, lists every rule name, and prints them all as unused. Wrong, and
  it runs end to end from the first command, which is the point.
- `mytool rules <signature.eo>` — **working**: the rule names, one per line.
  This is the piece the stub is built out of, so it costs nothing extra.
- `tests/` with one signature of four rules, one corpus of two proofs, and the
  expected output committed.
<!-- /A5 -->

### Q6 — Language, toolchain and build

**Optional.** The language, the version, how it is built and how it is run. If
there is a version to pin, pin it here — an agent choosing a toolchain version
on your behalf will choose whatever it saw most of.

Leave empty if the repository is documents for now.

<!-- A6 optional -->
Python 3.11, no dependencies outside the standard library, run as
`python3 -m mytool`. No packaging, no virtualenv, no lock file until something
needs one.
<!-- /A6 -->

### Q7 — Tests and evidence

**Optional.** What the first test is, and what it establishes. If the tool makes
claims about somebody else's program, say whether their output is to be recorded
from a real run and committed, rather than written from memory.

<!-- A7 optional -->
One case, committed: the four-rule signature, the two-proof corpus, and the
expected list of two unused rules. The corpus is real proofs recorded from a
run of the reference checker, not proofs written by hand to make the test pass.
<!-- /A7 -->

---

## What to take from the Eunoia ecosystem

### Q8 — What to adopt, and what to leave

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

<!-- A8 required -->
- the repository policy — **later**. There is nothing to comply about on day
  one and adopting it early would decide a layout before the tool has a shape.
- the membership declaration — **later**, with the policy.
- the discussion channel — **no**. Nothing to correspond about.
- the reporting workflow — **later**, and only if this starts making claims
  about somebody else's tree. Reporting a coverage number is not that.
- the shared reporting machinery — **no**.
- the calculus template — **no**. This does not check proofs.
- the proof checker and its compiler — **no**. Reading a signature for rule
  names does not need the compiler, and taking the dependency to avoid writing
  a small parser would be the expensive way round.
- the analyzer — **no** as a dependency. It already parses signatures, so the
  overlap is worth a conversation later, not a dependency now.
<!-- /A8 -->

### Q9 — Who runs the work

**Optional.** People, agents, or both — and under what supervision. This decides
one paragraph the ecosystem's policy asks every front page to end with, and it
decides how everybody else reads the tool: a project run by people is read as
somebody's considered choices, and one run by agents is read as work that has
not been vetted by a person at the level of internal design. Getting this
paragraph wrong in either direction misleads.

Leave empty and the agent is told to state the honest default — that the
repository was set up by an agent from this interview, and that who maintains it
is undecided.

<!-- A9 optional -->
Set up by an agent from this interview. Who maintains it afterwards is
undecided, and the front page should say exactly that rather than guess.
<!-- /A9 -->

---

## Bounds on the launch

### Q10 — What the agent must not do

**Optional.** Anything beyond the standing refusals. Files not to create,
directories not to touch, conventions not to import, opinions not to have. This
list is passed through verbatim and the agent is told it outranks everything
else in the prompt.

The standing refusals, which you do not need to repeat: no repository, no
remote, no push, no commit, no credentials, and nothing written outside the
target directory.

<!-- A10 optional -->
- Do not write a CI workflow. There is nothing worth gating yet.
- Do not add a documentation index or a `docs/` directory. One README.
- Do not add packaging metadata.
- Do not invent an etymology for the name.
<!-- /A10 -->

### Q11 — The target directory

**Optional.** Where the repository is, if you already know. `--target` on the
command line overrides whatever is written here.

It must exist before a launch runs. Creating it is yours — that is the step the
ecosystem's policy deliberately places behind a person, because a workflow that
could notice a gap, argue for a tool, take a name, write its README *and*
publish it would have no person in it anywhere.

<!-- A11 optional -->

<!-- /A11 -->
