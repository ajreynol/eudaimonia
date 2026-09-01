# The interview, answered

**This is the worked example**, not a plan anybody is carrying out. It is here
for the same reason the specification directories downstairs are: so the
machinery can be pointed at something real without anybody first having to
invent a tool.

```bash
bin/launch check examples/answered.md
bin/launch prompt examples/answered.md
```

It was created with `--with measurement`, so it also shows what a supplement
looks like merged in: the `M` questions at the bottom are not part of the core
form and only appear because this tool's output is numbers.

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
`mytool`. **Not in the register, deliberately** — this is the worked example
that ships with the launcher, not a tool anybody is building, and a placeholder
name is the honest label for that.

A real launch names a word from the register and says which entry it took, so
the agent writes that entry's account of it rather than inventing one.
<!-- /A1 -->

### Q2 — What it is, in two sentences

**Required.** What the tool is, and what question it answers. Present tense,
about what will exist, not about what it might grow into. This is the front-page
paragraph, so write it as you want it read.

What it *refuses* to answer is asked separately, twice and for different
reasons: Q3 asks what a successful run does not establish, and Q5 asks what the
tool will not do. Keep this one to the positive claim.

<!-- A2 required -->
A command that reads a Eunoia signature and a corpus of proofs, and reports
which of the signature's rules no proof in that corpus ever uses. It answers:
what part of this calculus is specified and never exercised?
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
Coverage of a calculus is currently a thing people assert. This makes it a
number, over one signature and one corpus, and refuses to generalise past the
corpus it was given.

The first consumer is the roadmap of the repository that owns the calculus: it
takes a list of rule names, one per line on stdout, and nothing else. That
format is the deliverable — prose about coverage is not, and a version of this
that only prints a report has not started.

A clean run establishes that every rule in the signature appeared in the corpus
that was read. It establishes nothing about a corpus nobody has collected, and
nothing about whether an unused rule is wrong.
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
Nothing does it directly, and two things do it badly.

The reference checker will tell you, per proof, which rules it applied — so a
shell loop over a corpus plus `sort -u` is the incumbent, and it is what people
actually run. It is slow, it needs the checker built, and it silently drops
rules whose proofs fail to parse, which is exactly the population you care
about.

The calculus template reports rule *status* — proven, stubbed — which is a
different question that is easy to mistake for this one. Do not reimplement it
and do not import it.
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
- It does not run the checker, and does not care whether a proof is valid.
- It does not collect corpora. Point it at one.
- It does not rank rules by importance. Used and unused is the whole output.
- **The larger question it will be read as answering, and does not:** whether
  the calculus has rules that are unnecessary. An unused rule may be untested,
  unreachable, or simply not exercised by whatever proofs somebody had. This
  tool cannot tell those apart and must say so on the front page.
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
- `mytool cover <signature.eo> <corpus-dir>` — a **working stub**: parses the
  signature, lists every rule name, and prints them all as unused. Wrong, and
  it runs end to end from the first command, which is the point.
- `mytool rules <signature.eo>` — **working**: the rule names, one per line.
  This is the piece the stub is built out of, so it costs nothing extra.
- `tests/` with one signature of four rules, one corpus of two proofs, and the
  expected output committed.
<!-- /A7 -->

### Q8 — Language, toolchain and build

**Optional.** The language, the version, how it is built and how it is run. If
there is a version to pin, pin it here — an agent choosing a toolchain version
on your behalf will choose whatever it saw most of.

Leave empty if the repository is documents for now.

<!-- A8 optional -->
Python 3.11, no dependencies outside the standard library, run as
`python3 -m mytool`. No packaging, no virtualenv, no lock file until something
needs one.
<!-- /A8 -->

### Q9 — Tests and evidence

**Optional.** What the first test is, and what it establishes. If the tool makes
claims about somebody else's program, say whether their output is to be recorded
from a real run and committed, rather than written from memory.

<!-- A9 optional -->
One case, committed: the four-rule signature, the two-proof corpus, and the
expected list of two unused rules. The corpus is real proofs recorded from a
run of the reference checker, not proofs written by hand to make the test pass.
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
- the repository policy — **later**. There is nothing to comply about on day
  one and adopting it early would decide a layout before the tool has a shape.
- the membership declaration — **later**, with the policy.
- the discussion channel — **no**. Nothing to correspond about.
- the reporting workflow — **later**, and only if this starts making claims
  about somebody else's tree. Reporting a coverage number is not that.
- the shared reporting machinery — **no**.
- the calculus template — **no**. This does not check proofs. See the incumbent
  answer: its rule-status report is the thing not to reimplement.
- the proof checker and its compiler — **no**. Reading a signature for rule
  names does not need the compiler, and taking the dependency to avoid writing
  a small parser would be the expensive way round.
- the analyzer — **no** as a dependency. It already parses signatures, so the
  overlap is worth a conversation later, not a dependency now.

The subject is inside the ecosystem: the signature is ours, and nothing here
reports outward to anybody.
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
Set up by an agent from this interview. Who maintains it afterwards is
undecided, and the front page should say exactly that rather than guess.
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
- Do not write a CI workflow. There is nothing worth gating yet.
- Do not add a documentation index or a `docs/` directory. One README.
- Do not add packaging metadata.
- Do not invent an etymology for the name.
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
Two counts and one list. Primary is **the list**: the names of rules that
appear in the signature and in no proof in the corpus, one per line.

The counts are `rules in signature` and `rules covered`, both integers. There
is no percentage and there will not be one — a coverage percentage over a
corpus nobody chose is the number most likely to be quoted and least likely to
mean anything.
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
A directory of `.proof` files given on the command line. **Not committed and
not fetched** — the corpus is the user's, and this tool has no opinion about
which one is right.

The test corpus, which is two proofs, *is* committed, and it exists to test the
tool rather than to measure anything.

A corpus is whatever the directory held at the moment of the run, so it is
growing by default. Every run records the file count and the corpus path
beside its output for that reason.
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
**None yet, deliberately.** The first version compares nothing: it reports the
list for one signature and one corpus, and that is the whole output.

A baseline becomes meaningful once somebody runs it twice on the same corpus
across two signature revisions, and the right form then is a committed baseline
in the repository that owns the calculus, not here. Do not build one now.
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
**None: this measurement is deterministic.** The same signature and the same
corpus give the same list every time, because nothing is timed and nothing is
sampled.

That is worth stating rather than leaving implicit, because it is what makes
the threshold question empty here and it is the reason a single run is enough.
If a future version ever times anything, this answer stops being true and the
threshold question becomes real.
<!-- /AM4 -->

### M5 — The environment, and what a number is not portable across

**Optional.** Hardware, parallelism, timeouts, resource limits, build
configuration — whatever a number depends on that is not the input.

Then the part worth the most: **name what makes two numbers incomparable.** A
different machine, a different build type, a different core count, a different
timeout. Whatever is on that list should be recorded beside every number, and
saying so here is what makes the agent record it.

<!-- AM5 optional -->
Irrelevant to the number: no timing, no parallelism, no resource limits.

What two results are **not** comparable across: a different corpus, a different
signature revision. Both are recorded beside every run.
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
A rule appearing in the unused list is **not** evidence that it is wrong,
unnecessary, dead, or untested. It is evidence of one thing only: no proof in
the corpus that was read applied it.

The likeliest cause is that nobody has generated proofs exercising it, which is
a fact about the corpus and not about the calculus. This belongs on the front
page above the fold, and a report that omits it will be read as a list of rules
to delete.
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
One signature, four rules, two proofs, and the two-line list of the rules those
proofs did not use. Printed by `mytool cover` on the day the repository is
created.
<!-- /AM7 -->
