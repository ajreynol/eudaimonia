# Eudaimonia

A template for building verified proof checkers for SMT, in the shape of
[Logos](https://github.com/cvc5/logos).

## The name

*Eudaimonia* (Greek εὐδαιμονία, from *eu-* "good" and *daimōn* "spirit") is
Aristotle's word for the highest human good: not pleasure or good fortune, but
**flourishing** — living well by fulfilling one's characteristic activity
excellently. It is the end that other ends are pursued for the sake of, and it
is reached through the exercise of reason, which for Aristotle is what the
activity characteristic of a human being consists in.

The name follows Logos, whose own name is the Greek λόγος: reason, and the
account one gives of a thing.

## What this is

Logos is a proof checker for one calculus: CPC, the calculus cvc5 emits proofs
in. Its soundness is proven in Lean against a formal semantics of SMT-LIB.

Eudaimonia is that arrangement with the calculus taken out. It generates a
checker for whatever calculus you name, so the signature and the semantics are
yours to supply rather than fixed in advance. Three things are yours to choose:

- the **checker**, which is the Lake project — its directory, its package and
  its executable,
- the **calculus** it checks proofs in, which is the Lean library inside it,
- the **Eunoia signature** (`.eo`) defining that calculus, and the
  **semantics** (`.eos`) saying what its symbols mean.

The two names are separate because a checker is a checker *of* a calculus, and
the layout a run generates is `<checker>/<calculus>/` for that reason.

Logos is the reference this is modeled on and nothing more: it is not what a
run generates, and no part of it is vendored here. The default names in
`config.sh` are placeholders — `MyChecker` and `MyCalculus` — chosen so that a
generated project is never mistaken for an existing checker.

## What a calculus must provide

The template generalizes *the calculus*, not the proof format. A signature it
can generate a checker for has to meet the framework where it stands, in two
ways.

### The signature contract

The correctness development is stated in terms of one operator of the calculus,
named as a constructor of the `UserOp` enum the signature compiles to.

**Always required:**

| requirement | why |
| ----------- | --- |
| a binary operator **`and`** | The soundness statement is about the *conjunction* of a proof's assumptions. The checker walks the input problem as `(and F rest)` and folds its proof stack the same way. |
| **`and` sent to `SmtTerm.and`** by the semantics | A signature that declared `and` and translated it elsewhere would still compile and still check proofs, and the conclusion would be about the wrong formula. Nothing downstream re-checks this seam. |
| the Bool literals **`true`** / **`false`** | `false` is the refutation target — the checker's test is "has `false` been proven" — and `true` terminates the assumption chain. Both are Eunoia builtins, so no signature has to declare them. |

**Required only if rules gather `:list` premises with `and`:**

| requirement | why |
| ----------- | --- |
| `and` declared **`:right-assoc-nil true`** | Such a rule builds its premise list through `__eo_nil`, and the arm returning `true` for `and` exists only because of the attribute. Without it those rules go `Stuck`. |

This second one is *not* a core requirement. With a plain binary `and` the
assumption chain, the refutation test and the SMT translation are byte-identical;
what changes is that the parser stops accepting n-ary `(and a b c)`, which is
surface syntax. A calculus with no `:list`-premise rules needs no nil, and
`examples/hello` is one.

`install/install-<calc>.sh` checks all of this against the compiler's output
before installing anything — the name an operator compiles to need not be its
spelling, and the attribute is only visible in what it generates. The
conditional requirement is checked conditionally: it fails only when the
compiled core gathers premises with `and` and no nil exists for it.

### The calculus profile

Distinct from the contract: the contract is what a signature *must* satisfy,
while these are facts about the calculus that describe what a checker needs,
must prove, and can inherit. Each is a flag of `scripts/new-checker.sh`,
recorded in the generated `install/defs/profile.conf`, and re-checked at install
time where the compiled output can settle it.

**These flags describe the calculus; they do not configure it.** What a checker
contains is decided by the signature and by the compiler. `--no-parser` is the
one that changes what is installed.

| question | flag | kind |
| -------- | ---- | ---- |
| Do rules discharge assumptions (`scope`, compiling to step-pop)? | `--[no-]scopes` | **derived** — the step-pop dispatch arms are emitted per rule |
| Do rules gather `:list` premises? | `--[no-]list-premises` | **derived** — the premise-list calls are emitted per rule, and the nil either exists or does not |
| How many indices do operators take, at most? | `--indexed-ops N` | **derived** — the compiler emits `UserOp<n>` only for an arity the calculus uses, so the highest one present is the answer |
| Is `smt.eos` Logos's SMT-LIB semantics, unmodified? | computed | **derived** — by digest |
| Should the generated parser be installed? | `--[no-]parser` | **derived**, and the one entry that is also a choice |
| Does the calculus have algebraic datatypes? | `--[no-]datatypes` | **declared** — the machinery is emitted for every signature, so nothing distinguishes the answers |
| Are any rules binder-sensitive? | `--[no-]binders` | **declared** — likewise unconditional, and a binder in the signature does not imply a rule reasoning under one |
| Does the semantics lean on a total order on values? | `--[no-]value-ordering` | **declared** — the same `SmtValueOrder` is emitted either way |

**Derived** answers are checked against the compiled signature and any
disagreement is reported. **Declared** ones are taken on trust, because the
machinery they name is emitted unconditionally — a calculus with the feature and
one without compile to the same thing, so claiming to verify them would be
checking something that can only answer one way.

Making those conditional is compiler work, set out in
**[docs/eoc-requests.md](docs/eoc-requests.md)**.

### The proof format is fixed

Only the calculus varies. Every checker this generates:

- is a **Eunoia** signature: rules are Eunoia rules, with side conditions as
  Eunoia programs and computed premises. A rule shape Eunoia cannot express is
  out of scope.
- accepts **Ethos s-expression proofs** — `assume`, `step :rule :premises`,
  `declare-const`. Which rules exist is yours; the shape of a proof is not.
  Alethe, DRAT/LRAT or any non-Eunoia certificate needs a different front end.
- is verified against **SMT-LIB model semantics**. A calculus over something
  that is not SMT-LIB needs a replacement `smt.eos`, which is the hardest part
  of the specification rather than a flag.
- uses a **deep embedding with untyped rules**: one `Term` type, rules as
  syntactic manipulations. The calculus is not typed at the Lean level.
- answers one question: **is this a refutation?** `correct` means the
  assumptions are unsatisfiable. Not equivalence, not model finding.
- keeps an **unverified parser** in the trusted base, deliberately, and does not
  check the proof against an original input problem.

If your calculus is a Eunoia signature over SMT-LIB, this is the right tool. If
it is not, the honest answer is that it is not.

## Usage

Edit `config.sh`, then generate:

```bash
scripts/new-checker.sh
```

Or give the settings on the command line, which override that file:

```bash
scripts/new-checker.sh --checker Apodeixis --calculus Lra \
  --signature ~/sigs/Lra.eo --semantics ~/sigs/Lra.eos
```

A specification is three files, and `--spec` names them at once by convention
(`<Calculus>.eo`, `<Calculus>.eos`, `smt.eos`). `examples/cpc` is a worked one —
a snapshot of what Logos compiles — so the generator can be pointed at something
real:

```bash
scripts/new-checker.sh --checker Logos --calculus Cpc --spec examples/cpc
```

`scripts/new-checker.sh --help` lists the rest. Then build what it wrote:

```bash
cd checkers/Apodeixis && lake build
```

## The Eunoia compiler

Turning a signature into Lean needs `ethos-eoc`, built from
[cvc5/ethos](https://github.com/cvc5/ethos). **It lives in the generated
checker, not here** — a checker owns the compiler that regenerates it, so it
stays self-contained:

```bash
cd checkers/<Checker>
install/get-eo-compiler.sh      # once
install/install-<calc>.sh       # signature -> Lean
```

It lands in that project's `install/deps/`, which is not kept in git, and
records its paths in `install/deps/eoc-env.sh`.

> **Currently in development mode.** The script builds the *head* of
> `ethosEoc3`, resolved at run time, rather than a fixed commit. That build is
> **not reproducible**: two runs on different days build different compilers,
> and a checker generated now cannot be regenerated identically later. This is
> temporary — see [Leaving development mode](#leaving-development-mode).

The Eunoia compiler is developed on the **`ethosEoc3`** branch of cvc5/ethos;
that is where the latest one is. `main` lags it, and its `driver.py` lacks two
options this template is built on:

| option | what building from `main` would give up |
| ------ | --------------------------------------- |
| `--calc-name` | the calculus name becomes the user's to choose, instead of being derived from the signature's file name |
| `--smt-semantics` | the SMT-LIB semantics is the user's to supply — the third of the three files a specification is |

So `main` is not an option today: it would cost exactly the two things that
make this a template. The script does not take the branch on faith — it checks
whatever it fetched for those options before building, so a commit without them
fails there, naming the missing option, rather than failing later inside a
compile.

### Choosing a commit

Two modes, set by `DEV_MODE` in the script and overridable per run:

```bash
install/get-eo-compiler.sh            # DEV_MODE as set in the script
install/get-eo-compiler.sh --tip      # build the branch head, resolved now
install/get-eo-compiler.sh --pinned   # build the recorded ETHOS_VERSION
```

A tip build still resolves to one concrete commit before doing anything, and
records it in `install/deps/eoc-env.sh` along with `EOC_DEV_MODE=1`. So what was
built is always *known*, even when it is not reproducible.

### Leaving development mode

A tip build ends by printing the two lines to paste back:

```
DEV_MODE=0
ETHOS_VERSION="<the commit it just built>"
```

Pinning what was just built changes nothing about the compiler — only whether
the next run is allowed to move. Do this before anyone else relies on the
generated checker.

### Ethos is already there

Building the compiler also builds **ethos** itself — the reference proof checker
for Eunoia, from the same source tree.

- **It reads your signature directly.** No Lean, nothing generated, so it works
  from the first day of writing a `.eo`.
- **It gives the checker a second opinion.** `scripts/check-with-ethos.sh` asks
  both the same question, using ethos's `--require-proof-of-false`, and
  compares. `scripts/run-ci.sh` runs it as the `ethos` group.

Ethos is not verified, so agreement proves nothing. It catches a compiled
calculus that has drifted from the signature it came from.

One asymmetry the cross-check accounts for: ethos has no SMT-LIB semantics and
cannot distinguish `correct` from `incomplete`, so accepting a proof the checker
calls `incomplete` is agreement, not disagreement.

`install/get-eo-compiler.sh --no-ethos` skips building it.

### Starting a new calculus

```bash
scripts/new-checker.sh --checker Demo --calculus Logic --dummy-rule --mini
cd checkers/Demo
install/get-eo-compiler.sh
install/install-logic.sh
scripts/build.sh
test/regress/run.sh
```

`--dummy-rule` writes a **working** starter instead of a commented stub: a
signature with one rule (`contra` — from a formula and its negation, derive
`false`), its semantics, and five regression proofs covering every verdict. The
result builds in about 12 seconds and passes its own tests, so a new calculus
begins by *changing something that works* rather than filling in blanks.

`examples/hello` is the same thing as a specification directory, if you would
rather start from `--spec`.

### Development scaffolding

Two options are about what the generated project *contains*, rather than about
the calculus:

```bash
scripts/new-checker.sh --mini              # also generate <Calculus>Mini
scripts/new-checker.sh --hygiene-ci        # CI rejects `sorry` from day one
```

**`--mini`** generates a second package: the same signature compiled with a
handful of rules and no parser, refreshed by
`install/install-<calc>.sh --mini`. On the CPC example it builds in **8 seconds
against 83**, from 2,130 lines against 20,350. A proof about the checker does
not depend on how many rules the calculus has, so it can be developed there and
moved. Which rules it keeps comes from `--mini-rules`, or from a `mini-rules`
file in the specification directory — as `examples/cpc` has.

**`--hygiene-ci`** decides whether `scripts/check-proof-hygiene.sh` runs in CI
from the first commit. It greps for `sorry`, `admit` and `axiom`, builds
nothing, and exists to stop an unproven rule landing silently — which matters
because CI cannot afford to build every proof. Off by default: a checker
scaffolded from a large signature starts with one `sorry` per rule and would be
red from the start. Turn it on for a small calculus proved as it grows, or once
the stubs are discharged.

## Where a run writes

By default, under `checkers/` in this repository, which is **not kept in git**.
Everything a run writes is reproducible from `config.sh` and `templates/`, so
there is nothing there worth committing, and trying the generator out or
working on the templates leaves nothing behind.

A checker you intend to develop is a different matter: it will accumulate
hand-written Lean — in Logos the per-rule correctness proofs live inside the
generated package — and that belongs in a repository of its own rather than in
the generator's. Generate it there:

```bash
scripts/new-checker.sh --checker Apodeixis --out ~/apodeixis
```

A generated project is self-contained and does not refer back to this one, so
it can also simply be moved.

Regenerating over an existing project needs `--force`. It deletes the project
directory and writes it again, so everything under it goes, hand-written Lean
and build cache included: nothing is preserved across a regeneration. Logos
keeps per-rule proofs across a reinstall and this does not, which is a gap to
close once there are proofs to keep.

## Design principles

Two commitments, and a tradeoff between them that is the user's to resolve.

### Everything ships compiling

A generated checker builds from the first command, before anything is proven.
`warningAsError` is deliberately not set on the calculus library, so a `sorry`
is a warning and a file containing one still compiles.

That makes the build a signal about *structure* rather than about progress.
A red build means something is genuinely broken; it never means "there is work
left". What is unproven is reported by `scripts/check-proof-hygiene.sh` and
`scripts/rule-status.sh`, which is where you should look.

Four kinds of file, and every one says which it is in its own header:

| | compiles? | `sorry` of its own? | you edit it? |
| --- | --- | --- | --- |
| **GENERATED** | yes | no | never — the next install overwrites it |
| **PROVEN** | yes | no | never |
| **FINISHED** | yes | no, but it depends on one | never |
| **OPEN** | yes | **yes** | **yes** — that `sorry` is the work |

`ApiCorrect.lean` is the case that makes the distinction worth having. It states
soundness about the text of a proof file and derives it from
`Proofs/Checker.lean`. It compiles, it has no `sorry` of its own, and it is
finished — you will not edit it — but it is not proven, because what it rests on
is not.

### Minimal design imposed on your checker

The template decides as little as it can about how *your* proofs are organised.

Logos is the reference, and it is tempting to copy more of it than is wise.
Where Logos has made a choice that a different checker might reasonably make
differently — what a rule must prove, how premise evidence is packaged, what
counts as an extra invariant — the template leaves the decision open rather than
shipping Logos's answer as though it were forced.

The rule of thumb: **port facts, not structure.**

- `Proofs/TypeDefaults.lean` is a *fact* about the generated model — an
  inhabited, well-formed type has a typed canonical default. It constrains
  nothing about how you write your proofs, so it is ported and proven.
- `RuleSupport/Contract.lean` in Logos defines `StepRuleProperties`: what a rule
  is obliged to establish. That is *structure*. Porting it would fix your
  checker/rule contract before you have written a rule, so the template leaves
  `Proofs/RuleSupport/Support.lean` open with a description of what it must
  supply.

### The tradeoff

These pull against each other, and neither answer is right in general.

Porting more from Logos means less to write, and a checker whose shape you
inherited. Porting less means more to write, and a checker that is yours. A
project reproducing CPC closely wants the first; one whose calculus is genuinely
different wants the second, and would find inherited structure actively in the
way.

The template currently sits toward the second, and says so where it matters:
each `OPEN` file describes what belongs in it and what Logos put there, so
adopting Logos's answer is always available and never assumed. Where that
balance should sit is a decision for whoever is building the checker, and
changing it means changing the templates rather than working around them.

## What a run generates

A checker whose **development infrastructure is initialized**, not just a Lake
package: the compiler that regenerates it, the scripts that build and check it,
its own regression suite, and documentation about its own calculus. The shape is
Logos's.

```text
<Checker>/                 <- the generated project, standalone
  <Calculus>/                the calculus: 23 modules + one file per rule
  <Calculus>Mini/            the reduced package        (--mini)
  <Format>/                  reading the proof format   (--format-name)
  install/                   signature, semantics, and the compiler
  scripts/ docs/ test/       build, check, document, regress
  Main.lean lakefile.toml lean-toolchain README.md
```

**[docs/generated-checker.md](docs/generated-checker.md)** is the full anatomy:
every file, how to navigate a checker you did not generate, which module is
compiled from the signature and which is yours to write, and a table mapping
each `new-checker.sh` option to what it decided.

**[docs/logos-experience-report.md](docs/logos-experience-report.md)** goes
through every `sorry` a generated checker contains and what the same obligation
cost Logos — a verified checker for a 591-rule calculus. Generated projects link
back to it rather than carrying a copy, since it describes Logos rather than any
one calculus.

A generated checker does not refer back to this repository. It owns its own copy
of the compiler setup, so it can be moved anywhere or made a repository of its
own.

### Trying it end to end

```bash
scripts/new-checker.sh --checker Logos --calculus Cpc --spec examples/cpc
cd checkers/Logos
install/get-eo-compiler.sh
install/install-cpc.sh
scripts/build.sh
test/regress/run.sh
```

That compiles the CPC signature into 9 signature-wide modules and 591 rule
stubs, builds them, and runs the regression proofs:

```
  ok hello.proof                              incomplete
  ok malformed.proof                          error
  ok no-refutation.proof                      incorrect
```

The generated Lean is byte-identical to what Logos carries, modulo the header
naming which installer wrote it. `scripts/run-ci.sh` passes.

Any signature reachable on the machine can be compiled instead, including one
sitting in a tree of includes:

```bash
install/install-cpc.sh ~/cvc5/proofs/eo/cpc/Cpc.eo
```

That also **records** it — flattening the tree into `install/defs/Cpc.eo` as
one self-contained file — so the checker carries the signature it was built
from and can be regenerated without that tree.

### What a fresh checker can and cannot say

It parses the Eunoia proof format, runs the calculus, and reports one of three
verdicts — and all three are reachable for the right reasons, because the side
conditions in `Proofs/Assumptions.lean` are real rather than stubbed. A term is
translatable when the semantics gives it a type, so `incomplete` means what it
says:

```
  ok hello.proof         correct      two contradictory assumptions, refuted
  ok no-refutation.proof incorrect    nothing derived
  ok stuck-step.proof    incorrect    a step the checker gets stuck on, localized
  ok unmodeled.proof     incomplete   a sort constructor the semantics has no counterpart for
  ok malformed.proof     error        the parser rejects it
```

A rejection says *where*: `incorrect` replays the proof and names the command
that got stuck — `the checker became stuck at step @p3 (proof command 2)` —
and `incomplete` names what the semantics does not model.

What it cannot say is that any of this is *proven*. `Proofs/Checker.lean` holds
the soundness theorem and it is a `sorry`, as is every rule, so `correct` reports
that the checks passed rather than that the assumptions are provably
unsatisfiable.

The two are separate axes. `ApiCorrect.lean` already states correctness about the
text of a proof file and derives it from `Proofs/Checker.lean`, so discharging
that one theorem closes the gap with no other file changing.
`scripts/rule-status.sh` is where progress shows, not the verdict.

## This repository

Eudaimonia itself — the generator and its templates. Not to be confused with
what a run *produces*, which is
[docs/generated-checker.md](docs/generated-checker.md).

```text
config.sh                  the settings a run reads
scripts/new-checker.sh     the generator
templates/                 what it renders, one file per generated file
  pkg/                       the calculus package
  eunoia/                    the proof-format library
  starter/                   the --dummy-rule signature and its proofs
  install/ scripts/          the checker's installer and dev scripts
  docs/ ci/ test/            its documentation, CI workflow and test layout
examples/cpc/              a worked specification: CPC, as Logos compiles it
examples/hello/            the smallest one that works: one rule, five proofs
docs/generated-checker.md  the anatomy of what a run produces
docs/logos-experience-report.md
                           every `sorry` a generated checker has, and what the
                           same obligation cost Logos
docs/eoc-requests.md       what a template needs from the eoc compiler
checkers/                  where runs write, ignored by git
TODO.md                    what Logos has that a generated checker still needs
```

Templates are plain files with `@CHECKER@`, `@CALCULUS@`, `@FORMAT@`, `@EXE@`,
`@CALCLOWER@`, `@MINI@` and `@TOOLCHAIN@` substituted in. Adding a file to a
generated project means adding a template and one `render` line in the
generator.

## Status

**In development mode**: the Eunoia compiler is built from the head of
`ethosEoc3` rather than a pinned commit, so builds are not reproducible. See
[Leaving development mode](#leaving-development-mode).

What is here is the build infrastructure, the shape of a checker, and the
compiler that will fill it in: a run generates a Lake project that builds
clean, an executable that runs, and every module a checker needs as a stub
describing what belongs in it. `scripts/get-eo-compiler.sh` builds `ethos-eoc`.
What does not exist yet is the step between them — driving the compiler over a
signature and installing the Lean it publishes over the stubs.

After that: the signature-independent parser library, the core correctness
proof, and the per-rule proofs (591 files in Logos).

**[TODO.md](TODO.md)** sets all of it out, item by item, against the Logos
files each item corresponds to.

---

## How this repository is maintained

**Eudaimonia is written by an AI agent under human supervision.** Claude does
the work — the scripts, the templates, the Lean, the documentation and the
measurements in it — and a human directs, reviews and decides.

That is worth stating for two reasons.

**What to trust.** Claims here are meant to be checked rather than believed, and
most carry the measurement that produced them: a line count, a diff between two
packages, a build that passed. Where something is untested it says so. Treat an
unsupported claim as a defect and report it.

**What to expect.** The design has changed direction more than once, and the
history of that lives in [TODO.md](TODO.md) and
[docs/eoc-requests.md](docs/eoc-requests.md) rather than in this file. Several
findings here came from an agent being wrong in a way that testing caught —
which is the process working, but it means the documents are a record of
reasoning, not a specification handed down.

Nothing generated by this repository is verified by virtue of being generated.
The soundness of a checker it produces rests on proofs a person still has to
write, and on the trusted base described above.
