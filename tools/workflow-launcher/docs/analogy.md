# The analogy

Eudaimonia is a build system for constructing projects. This is the same
arrangement one level of abstraction up: a build system for constructing the
*repositories* projects live in. The staging is deliberately the same, because
the staging is the part that transfers. What does not transfer is everything
that follows from one of them having a compiler in the middle and the other
having a model.

This document is maintained as the thing this child project is for. If it goes
stale, the project has stopped doing its job.

## The stages, side by side

| | Eudaimonia | here |
| --- | --- | --- |
| **the specification you bring** | a signature (`.eo`), its semantics (`.eos`), and the SMT-LIB semantics they are read against | an answered [interview](../interview.md) |
| **the settings** | [`config.sh`](../../../config.sh) — names, the calculus profile, the scaffolding switches | [`launcher.conf`](../launcher.conf) — the agent command, the target, the refusals |
| **the generator** | [`scripts/new-checker.sh`](../../../scripts/new-checker.sh) | [`bin/launch`](../bin/launch) |
| **what it renders** | [`templates/`](../../../templates) — one file per generated file, `.in` suffixed | [`prompts/`](../prompts) — one file per stage |
| **the substitution** | `@CHECKER@`, `@CALCULUS@`, `@FORMAT@`, `@EXE@`, `@CALCLOWER@`, `@MINI@`, `@TOOLCHAIN@` | `@NAME@`, `@TARGET@`, `@SOURCE@`, `@ANSWERS@` |
| **the multi-line value** | substituted after rendering, because a line-oriented replacement cannot carry one | the same, and for the same reason: `@ANSWERS@` is spliced from a file |
| **the worked example** | [`examples/hello`](../../../examples/hello), the smallest specification that works | [`examples/answered.md`](../examples/answered.md), the smallest interview that renders |
| **the install** | `install/get-eo-compiler.sh` fetches and builds a compiler pinned to a commit; `install/install-<calc>.sh` runs it over the signature | `bin/launch run` hands the assembled prompt to an agent, in a directory a person made |
| **the build** | `scripts/build.sh` | whatever the new repository turns out to build with — not ours, and named in the interview rather than decided here |
| **the check** | `scripts/run-ci.sh`: build, modules, regress, ethos, regeneration | `bin/launch review`: a second agent reads the result against the interview, and a person reads both |
| **where output goes** | `checkers/`, not kept in git | the target directory, which is not in this tree at all |
| **in CI** | six configurations generated, each running its own CI, about 105 seconds on every push | nothing |

The Eudaimonia column is read off that project's own front page and the
generator's option table rather than re-measured here — including the 105
seconds, which is its claim about its own suite.

Read down the first eight rows and the two are the same system. Read the last
four and they are not the same kind of thing at all.

## Where the analogy holds

**Both are staged, and the stages are separately runnable.** Generate, install,
build, check — you can stop after any of them and look at what you have. That is
the property worth copying, and it is why `prompt` is a command here rather than
a flag: the assembled prompt is an artifact you can read before anything acts on
it, the way a generated project is a directory you can read before anything
builds it.

**Both keep the specification outside the tool.** A checker is a function of a
signature the framework does not own; a repository is a function of an interview
the launcher does not own. In both cases the framework's job is to be the part
that does not change when the specification does, and in both cases the honest
test is whether somebody else's specification works without editing the
framework.

**Both refuse to overwrite work.** `new-checker.sh` regenerates scaffolding and
refuses when it finds something a run cannot put back — discharged rule proofs,
above all. `bin/launch` refuses a target that already has files in it unless it
is told the files are meant to be built on. The failure being avoided is the
same one: a tool that is cheap to re-run quietly destroying the expensive thing.

**Both put the irreversible step behind its own command.** Downstairs that is
`install/get-eo-compiler.sh`, which fetches a source tree and spends minutes
building it, and it is separate from generation because it costs something.
Here it is `run`, and it is separate for a stronger reason — see the boundary
below.

**Both templates are plain text with a substitution table**, so adding a stage
means adding a file and one line, and nothing has to learn a template language.

## Where it breaks

These are the important half, and none of them is a defect to be fixed. They
are what changes when the renderer stops being a function.

**1. The renderer is not a function.** `sed` over a template gives the same
answer twice. An agent does not. Eudaimonia's CI includes a `regeneration`
group that reinstalls from the signature and asserts the package comes back
byte-for-byte, and that check is the reason a generated checker can be described
as *a function of its specification*. There is no such check here and there
cannot be. Two launches from the same interview produce two different
repositories, both plausibly correct, and no comparison between them means
anything.

The consequence is about what may be claimed, not about what may be built:
`bin/launch` does not use the word *generate* about itself anywhere, because the
word carries that guarantee in the tree next door.

**2. There is no pinned artifact in the middle.** Downstairs, the thing that
turns a specification into code is a compiler at a named commit, fetched and
built by the project that uses it, with the semantics file it was pinned
alongside — and moving that pin is a script of its own because the two have to
move together. Here the thing in the middle is a model. Its version is not
ours to record in a way that would let anybody reproduce anything, and pretending
otherwise by writing a version string into a config file would be worse than
saying nothing.

**3. The output has no test on day one.** A generated checker builds, runs, and
gets known verdicts on committed regression proofs before anybody has written a
line of it — that is what makes *everything ships compiling* possible as a
design principle. A launched repository has no tests, because its tests are
among the things being launched. The review stage exists to put *something* in
that slot, and a second agent reading prose against prose is a much weaker thing
than a build that either passes or does not. It is not offered as equivalent.

**4. CI cannot be the check, and the reason is not cost.** Nothing here runs on
a push. Three reasons, in increasing order of how much they decide it: an agent
run costs money per invocation and CI runs on every push; the result is
nondeterministic, so a red build would not mean what a red build has to mean;
and the step at the end of this pipeline is the creation of a public artifact
under somebody's account.

That last one is why the boundary is where it is.

## The boundary

The ecosystem's repository policy places the creation of a repository behind a
person, and the argument it gives is specifically about a workflow of this
shape. Such a workflow can notice a gap, argue that a tool should exist, audit
that argument against a standard it also maintains, take a name from a register
it also maintains, and write the new tool's README. Each of those steps is
defensible on its own. The composition is not: if it could also create the
repository, the whole path from an idea to a public artifact under somebody's
account would run with no person in it anywhere.

So the break is placed at the repository, because that is the step that is
irreversible and outward-facing — it publishes under a name people trust, it is
visible immediately and permanently enough that deleting it is not undoing it,
and it arrives with a place to put secrets and a runner that will execute
whatever is put there.

Everything in [`bin/launch`](../bin/launch) that looks like paranoia follows
from this and from nothing else:

- it never creates the target directory, and dies saying so;
- it refuses a target that is inside this repository;
- it refuses a non-empty target unless told the contents are meant to be built
  on;
- the prompt it assembles tells the agent, above everything else in the prompt
  including the interview, not to create a repository, a remote or a commit, and
  to stop and say so rather than do the nearest allowed thing;
- and `prompt` — print it, run nothing — is the command the documentation leads
  with.

None of that is enforcement. An agent handed the prompt can do whatever it can
reach, and this arrangement is a set of defaults and a stated intent, not a
sandbox. The boundary that is real is the one made of a person creating the
repository, and the machinery is arranged so that the person is still there.

## What this predicts

If the analogy is a good one, two things should follow, and neither has been
tested.

**The interview should behave like a signature.** A signature that does not meet
the framework where it stands fails at install time with a message naming what
is missing, rather than producing a checker that is quietly about the wrong
formula. The equivalent here is that an interview with a required question left
empty should stop the launch, which it does — and that an interview which is
*answered but underdetermined* should be visible as such, which it is not.
That is the gap worth working on next.

**The framework should not need editing for somebody else's tool.** The test is
somebody answering the interview for a tool nobody here thought of, and the
prompt needing no change. Until that has happened at least twice the
generalisation is a claim rather than a finding, and this document should keep
saying so.
