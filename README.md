# Eudaimonia

The **Eudaimonia build framework**: a framework for building verified proof
checkers for SMT, in the shape of
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

**A proof is never read through your operators.** Assumptions reach the checker
as a list and commands as a command list, both structural, so nothing about how
a signature spells its symbols can change how a run behaves. The contract is
about *stating* what a run establishes, not about performing it, and it comes
down to one operator — named as a constructor of the `UserOp` enum the signature
compiles to.

**Always required:**

| requirement | why |
| ----------- | --- |
| a binary operator **`and`** | The conclusion is that the *conjunction* of a proof's assumptions is unsatisfiable. `argListAssumes` folds the input list into that conjunction, and the checker layer folds its proof stack the same way. Nothing on the path from file text to verdict names it. |
| **`and` sent to `SmtTerm.and`** by the semantics | A signature that declared `and` and translated it elsewhere would still compile and still check proofs, and the conclusion would be about the wrong formula. Nothing downstream re-checks this seam. |
| the Bool literals **`true`** / **`false`** | `false` is the refutation target — the checker's test is "has `false` been proven" — and `true` is what an empty assumption list stands for. Both are Eunoia builtins, so no signature has to declare them. |

**Required only if rules gather `:list` premises with `and`:**

| requirement | why |
| ----------- | --- |
| `and` declared **`:right-assoc-nil true`** | Such a rule builds its premise list through `__eo_nil`, and the arm returning `true` for `and` exists only because of the attribute. Without it those rules go `Stuck`. |

This second one is *not* a core requirement. With a plain binary `and` the input
list, the refutation test and the SMT translation are byte-identical; what
changes is that the parser stops accepting n-ary `(and a b c)`, which is surface
syntax. A calculus with no `:list`-premise rules needs no nil, and
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

## Requirements

| | |
| --- | --- |
| **Lean** | via [elan](https://github.com/leanprover/elan), which installs the toolchain `lean-toolchain` pins. Nothing else needs Lean installed globally |
| **A C++17 compiler and cmake ≥ 3.12** | the Eunoia compiler is built from source |
| **GMP development headers** | `libgmp-dev` on Debian and Ubuntu, `gmp` on Homebrew |
| **python3, git, tar** | and either `curl` or `wget` |

`install/get-eo-compiler.sh` checks for these before it builds anything and
names what is missing; `scripts/build.sh` checks for `lake`.

### Platforms

| | |
| --- | --- |
| **Linux** | what CI runs on every push — six configurations, each built and checked |
| **macOS** | a generate-install-build-check smoke test runs on `macos-latest` alongside it |
| **Windows** | not supported directly. WSL behaves as Linux |

Both are covered by CI rather than assumed. The scripts avoid the usual
divergences deliberately — no bash 4 features, so Apple's bash 3.2 is fine;
`sed -i.bak` rather than GNU's `sed -i`; `nproc` with a `sysctl` fallback; and
an md5 helper that takes `md5sum`, `md5` or `openssl` depending on which exists.

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
(`<Calculus>.eo`, `<Calculus>.eos`, `smt.eos`). A signature may be a tree of
`(include ...)`s laid out however its author chose; the whole closure is copied
in, structure intact. `examples/cpc` is a worked specification — a snapshot of
what Logos compiles — so the generator can be pointed at something real:

```bash
scripts/new-checker.sh --checker Demo --calculus Cpc --spec examples/cpc
```

`scripts/new-checker.sh --help` lists the rest. Then build what it wrote:

```bash
cd checkers/Demo && lake build
```

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

### Where a run writes, and what else you can ask for

`--out` decides where a checker is written; the default is `checkers/` here,
which is not kept in git. A checker you mean to develop belongs in a repository
of its own. `--mini` generates a reduced package that builds in seconds rather
than minutes, and `--hygiene-ci` decides whether CI rejects `sorry` from day
one.

[Anatomy of a generated checker](docs/generated-checker.md) has the full option
table, what each one produces, and what regenerating over an existing checker
does and refuses to do.

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

A generated checker is **pinned**: `DEV_MODE=0`, and `ETHOS_VERSION` names the
commit. Two runs a month apart build the same compiler, and a checker can be
regenerated identically later.

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

A tip build still resolves to one concrete commit before doing anything and
records it, so what was built is always known — but it is a way to try
something, not the default.

### Advancing the pin

The commit is not the whole pin. `install/defs/smt.eos` is a **snapshot** of
that commit's `tools/eoc/semantics/smt.eos`, handed back to the compiler with
`--smt-semantics` so the generated Lean does not move when the compiler does.
The Eunoia semantics format is still changing, so a snapshot taken at one commit
will not generally parse against another: the two have to move together.

`scripts/bump-eoc.sh` moves them together.

```bash
scripts/bump-eoc.sh --dry-run     # what would change
scripts/bump-eoc.sh               # advance to the head of ethosEoc3
scripts/bump-eoc.sh --commit <sha>
```

It rewrites `ETHOS_VERSION`, refreshes `examples/*/smt.eos` and
`examples/cpc/Cpc.eos` from that commit, and updates the digest the calculus
profile reports `logos-smt` from. Then run `scripts/run-ci.sh`: the semantics
moving means what the compiler generates may have moved, and anything shipped
*proven* — `ModelWf.lean`, `Proofs/{TypeDefaults,TypePredicates,Canonicity}.lean`
— is proven against the model that semantics generates.

It is modelled on `scripts/bump-eoc-version.py` in Logos, which does the same
for a single package. The difference is what each pins: Logos ships no
`smt.eos` and tracks the compiler's own, so it synchronizes `Cpc.eos` alone.

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
  checker/rule contract before you have written a rule, so
  `Proofs/RuleSupport/Support.lean` ships as a **stub** instead: the hypotheses
  a rule is *given* are defined for real, so rule statements are not vacuous;
  the obligations it must *establish* are deliberately unprovable, so rules
  compile but none can be closed except with `sorry`.

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

## What a run produces

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

End to end, against the CPC example — 9 signature-wide modules and 591 rule
stubs:

```bash
scripts/new-checker.sh --checker Demo --calculus Cpc --spec examples/cpc
cd checkers/Demo
install/get-eo-compiler.sh
install/install-cpc.sh
scripts/build.sh
scripts/run-ci.sh
```

`run-ci.sh` passes: the package builds, every module compiles, the regression
proofs get the verdicts they should, ethos agrees with all of them, and
reinstalling from the signature reproduces the package byte-for-byte.

The result reports one of three verdicts, and a rejection says *where* —
`incorrect` names the command that got stuck, `incomplete` names what the
semantics does not model. What it cannot say is that any of this is **proven**:
`Proofs/Checker.lean` holds the soundness theorem and it is a `sorry`. Those are
separate axes, and `scripts/rule-status.sh` is where progress shows, not the
verdict.

## This repository

Eudaimonia itself — the generator and its templates. Not to be confused with
what a run *produces*, which is
[docs/generated-checker.md](docs/generated-checker.md).

```text
config.sh                  the settings a run reads
scripts/new-checker.sh     the generator
scripts/run-ci.sh          generate every configuration and run its own CI
templates/                 what it renders, one file per generated file
  pkg/                       the calculus package
  eunoia/                    the proof-format library
  starter/                   the --dummy-rule signature and its proofs
  install/ scripts/          the checker's installer and dev scripts
  docs/ ci/ test/            its documentation, CI workflow and test layout
examples/cpc/              a worked specification: CPC, as Logos compiles it
examples/hello/            the smallest one that works: one rule, five proofs
examples/scoped/           adds assumption discharge and `:list` premises
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

A run produces a **working checker**, end to end: `new-checker.sh` writes the
project, `install/get-eo-compiler.sh` builds the Eunoia compiler, and
`install/install-<calc>.sh` compiles the signature into Lean over the stubs.
The result builds clean, runs, parses the Eunoia proof format, and reports one
of three verdicts. CPC — 591 rules — generates, installs, and builds.

What is not done is the correctness development: the checker layer, and the
per-rule proofs. See [What is not there](#what-is-not-there) below and
**[TODO.md](TODO.md)**, which sets it out item by item against the Logos files
each corresponds to.

### What CI guarantees

`scripts/run-ci.sh` generates a checker for **six option configurations** and,
for each, runs **that project's own `scripts/run-ci.sh`** — not a bespoke script
written to pass. What is tested is what a user gets. It then generates and
installs CPC. The whole suite is about **105 seconds**, so it runs on every push.

Each generated project's CI is five groups:

| group | what it establishes |
| ----- | ------------------- |
| `build` | the library and the executable build |
| `modules` | **every module the package ships compiles** — `sorry` and all. One exclusion: `Proofs/RuleLemmas.lean` |
| `regress` | the regression proofs get the verdicts they should — all three, plus a parse error |
| `ethos` | **the same proofs, cross-checked against ethos** — the reference Eunoia checker, an independent implementation, built from the same tree |
| `regeneration` | reinstalling from the signature reproduces the package **byte-for-byte** |

Two of those are stronger than they look. `ethos` is a differential check: a
verdict is not just what our Lean says, it is what our Lean and an independent
checker both say. `regeneration` means the package is genuinely a function of
its specification — drift between the signature and the Lean is caught rather
than accumulating.

And because `modules` compiles everything, **a red build means something is
broken, not that something is unfinished.** That is what makes the suite usable
as a signal at all: unfinished is the normal state of a checker under
development, so it cannot be what failure means.

The six configurations cover the option surface that changes what is written:
signature source, `--mini`, `--dummy-rule`, `--theorems none`, a theorem subset,
`--format-name` and `--no-parser`.

### What is incorporated from Logos

Logos is a verified checker for a 591-rule calculus, and the parts of it that
generalize are copied in **complete and proven**, not restated as stubs:

| | |
| --- | --- |
| `ApiChecks.lean` | each executable check tied to the theorem component it stands for |
| `Api.lean`, `Diagnostics.lean` | what the executable does with a file, and where a rejected proof broke |
| `ModelWf.lean` | what a well-formed model gives you, proven against the generated `model_wf` |
| `Proofs/Assumptions.lean` | the side conditions, and deciding them |
| `Proofs/TypeDefaults.lean`, `Proofs/TypePredicates.lean` | ported from Logos's proof-modularity work: an inhabited well-formed type has a typed canonical default, and type inhabitation and value canonicity |
| `Proofs/Canonicity.lean` | evaluating a literal gives a value in normal form |
| `Proofs/Invariants/Extra.lean` | the calculus-specific seam, `True` for a calculus that needs nothing |

**55 declarations, 1,044 lines, zero `sorry`.** A generated checker starts with
that rather than with an empty file and a description.

The rule for what gets copied is **port facts, not structure**: a fact about the
generated model constrains nothing about how you write your proofs, so it is
ported; a *contract* — what a rule is obliged to establish — is a design
decision your calculus should own, so it is not. That is why
`Proofs/RuleSupport/Support.lean` is a stub rather than a copy of Logos's
`Contract.lean`, and why its obligations are deliberately unprovable: a stub
that could be closed by `trivial` would let 591 rules report as proven having
proven nothing.

Upstream modularity work is tracked and adopted as it lands, and pushed for
where it is missing. Logos's `modularity2` made `Proofs/CheckerState.lean`
identical between a 591-rule package and a 5-rule one — 1,463 lines that had
differed by 145 — which is precisely what makes a file inheritable by a
generated checker rather than maintained per calculus. `docs/eoc-requests.md`
is the running list of where that work still has to happen upstream, ranked.

### What is not there

A generated checker ships **compiling**, not proven: the correctness development
is the outstanding work, and `Proofs/CheckerCore.lean` and
`Proofs/RuleSupport/Support.lean` are the stubs it starts from. Both define the
hypotheses a proof is given for real, and leave what it must establish as
propositions nothing can prove by accident.

**[docs/limitations.md](docs/limitations.md)** has the detail, and
[TODO.md](TODO.md) the plan.

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
