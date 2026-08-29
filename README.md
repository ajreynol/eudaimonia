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

The correctness development is not neutral about vocabulary. It is stated in
terms of one operator, named as a constructor of the `UserOp` enum the signature
compiles to.

| requirement | why |
| ----------- | --- |
| an operator **`and`** | The soundness statement is about the *conjunction* of a proof's assumptions, and the checker folds its proof stack with the same operator. |
| declared **`:right-assoc-nil true`** | Not decoration. The checker reads the input problem as an `and`-chain terminated by `true`, and every `:list`-premise rule depends on the nil the attribute generates. |
| **`and` sent to `SmtTerm.and`** by the semantics | A signature that declared `and` and translated it elsewhere would break soundness *silently*: nothing downstream re-checks that seam. |
| the Bool literals **`true`** / **`false`** | `false` is the refutation target — the checker's test is literally "has `false` been proven" — and `true` is the unit of the assumption chain. |

That is the whole list, and it is short because Logos worked at making it short:
`not`, `=` and `imp` were all required at some point and none are now. Two
things drove the shrinking — a conjunction is what the *statement* of soundness
needs, and everything else a calculus has is its own business.

**All four are checked**, on the compiler's output rather than on the signature
text — the name an operator compiles to need not be its spelling, and the
attribute is only visible in what it generates. `install/install-<calc>.sh`
refuses before installing anything, naming what is missing.

### The calculus profile

A second kind of question, distinct from the contract above: the contract is
what a signature *must* satisfy, while these are facts about the calculus that
describe what a checker needs, must prove, and can inherit. They are one
category and treated uniformly — each is a yes/no flag of
`scripts/new-checker.sh`, each is recorded in the generated
`install/defs/profile.conf`, and each is re-checked at install time where the
compiled output can settle it.

**None of them is a feature switch.** What a generated checker contains is
decided by the signature and by the eoc compiler. Nothing here trims anything,
and there is no eoc option that would — the only entry that changes what is
installed is `--no-parser`. The profile describes the calculus; it does not
configure it.

| question | flag | kind |
| -------- | ---- | ---- |
| Do rules discharge assumptions (`scope`, compiling to step-pop)? | `--[no-]scopes` | **derived** — the step-pop dispatch arms are emitted per rule |
| Do rules gather `:list` premises? | `--[no-]list-premises` | **derived** — the premise-list calls are emitted per rule, and the nil for the gathering operator either exists or does not |
| Is `smt.eos` Logos's SMT-LIB semantics, unmodified? | computed | **derived** — by digest |
| How many indices do operators take, at most? | `--indexed-ops N` | **derived** — an unused arity still gets an enum, but holding a placeholder `\| None`, so a real constructor is the signal |
| Should the generated parser be installed? | `--[no-]parser` | **derived**, and the only entry that is also a *choice*: `--no-parser` really does change what is installed |
| Does the calculus have algebraic datatypes? | `--[no-]datatypes` | **declared** — eoc emits the datatype machinery for every signature |
| Are any rules binder-sensitive? | `--[no-]binders` | **declared** — likewise unconditional, and a binder in the signature does not imply a rule reasoning under one |
| Does the semantics lean on a total order on values? | `--[no-]value-ordering` | **declared** — eoc emits the same `SmtValueOrder` either way |

The **derived / declared** split is not cosmetic, and it is the reason this list
is honest rather than aspirational. Three of these are declared because the
machinery they name lives in a *fixed eoc template* rather than being generated
from the signature — `plugins/lean_meta/lean_meta_checker_term.lean` declares
`Term` and `DatatypeDecl` unconditionally, for instance — so a calculus with
datatypes and one without compile to the same thing. Claiming to verify them
would be checking something that can only ever answer one way.

Indexed operators are the sharpest example that the compiler already knows more
than it acts on: the ladder is fixed at exactly three arities, an unused one is
emitted holding a placeholder constructor, and four indices cannot be expressed
at all — yet the answer is readable straight off the emitted code.

Datatypes are still worth recording, and worth targeting: about 330 lines of a
generated package mention them, none of it trimmable today. Making that
conditional is compiler work, written up for whoever does it in
**[docs/eoc-requests.md](docs/eoc-requests.md)**.

Defaults are the conservative answers. Answering wrongly does not break a build
— the calculus is whatever the signature says — it makes the documentation
wrong, which is why `install-<calc>.sh` prints declared against derived and
names any that disagree.

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
scripts/new-checker.sh --checker Aletheia --calculus Lra \
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
cd checkers/Aletheia && lake build
```

## The Eunoia compiler

Turning a signature into Lean needs `ethos-eoc`, built from
[cvc5/ethos](https://github.com/cvc5/ethos). Fetch and build it once:

```bash
scripts/get-eo-compiler.sh
```

It lands in `deps/`, which is not kept in git, and records its paths in
`deps/eoc-env.sh`.

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
scripts/get-eo-compiler.sh            # DEV_MODE as set in the script
scripts/get-eo-compiler.sh --tip      # build the branch head, resolved now
scripts/get-eo-compiler.sh --pinned   # build the recorded ETHOS_VERSION
```

A tip build still resolves to one concrete commit before doing anything, and
records it in `deps/eoc-env.sh` along with `EOC_DEV_MODE=1`. So what was built
is always *known*, even when it is not reproducible.

### Leaving development mode

A tip build ends by printing the two lines to paste back:

```
DEV_MODE=0
ETHOS_VERSION="<the commit it just built>"
```

Pinning what was just built changes nothing about the compiler — only whether
the next run is allowed to move. Do this before anyone else relies on the
repository.

### Ethos is already there

Building the compiler also builds **ethos** itself — the reference proof checker
for Eunoia, from the same source tree. That matters more than it sounds:

- **It reads your signature directly.** No Lean, nothing generated. So from the
  first day of writing a `.eo` you can check proofs against it, long before the
  Lean development can say anything at all.
- **It gives the generated checker a second opinion.**
  `scripts/check-with-ethos.sh` asks both the same question — with ethos's
  `--require-proof-of-false` — and compares. `scripts/run-ci.sh` runs it as the
  `ethos` group.

Ethos is *not* verified, so agreeing with it proves nothing. What it is good at
is catching a compiled calculus that has drifted from the signature it came
from, which is the failure a generated checker is most exposed to.

One asymmetry the cross-check knows about: ethos has no SMT-LIB semantics, so it
cannot see the difference between `correct` and `incomplete`. Accepting a proof
the generated checker calls `incomplete` is agreement, not a disagreement.

`install/get-eo-compiler.sh --no-ethos` skips building it.

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
scripts/new-checker.sh --checker Aletheia --out ~/aletheia
```

A generated project is self-contained and does not refer back to this one, so
it can also simply be moved.

Regenerating over an existing project needs `--force`. It deletes the project
directory and writes it again, so everything under it goes, hand-written Lean
and build cache included: nothing is preserved across a regeneration. Logos
keeps per-rule proofs across a reinstall and this does not, which is a gap to
close once there are proofs to keep.

## What a run generates

A checker whose **development infrastructure is initialized**, not just a Lake
package: the compiler that regenerates it, the scripts that build and check it,
and documentation about its own calculus. The shape is Logos's.

```text
<Checker>/
  install/                 regenerating <Calculus> from its signature
    defs/<Calculus>.eo     the Eunoia signature
    defs/<Calculus>.eos    what its symbols mean
    defs/smt.eos           the SMT-LIB semantics that is written against
    get-eo-compiler.sh     fetch and build the Eunoia compiler
    install-<calc>.sh      compile the signature into <Calculus>/
    README.md              what regeneration overwrites, and what it preserves
  scripts/                 build.sh, check-proof-hygiene.sh, run-ci.sh
  docs/                    calculus.md, development.md
  test/regress/            proofs to check, the verdict each should get, and a
                           runner; populated from <spec>/test/ if it has one
  .github/workflows/ci.yml
  .gitignore
  lakefile.toml
  lean-toolchain
  Main.lean
  <Calculus>.lean
  Eunoia.lean
  Eunoia/                  reading the Eunoia proof format: hand-written,
                           calculus-independent, ~1,080 lines
  <Calculus>/              the package: 17 modules, G generated and H hand-written
    ...
    Proofs/Rules/          one file per rule: statement generated, proof yours
  README.md
```

Every module under `<Calculus>/` carries a header saying whether it is
generated from the signature — and so overwritten by a reinstall — or
hand-written and left alone. `Proofs/Rules/` is both: the compiler emits a
rule's statement with `sorry`, the proof goes in that same file, and a reinstall
preserves it.

A generated checker does not refer back to this repository. It owns its own
copy of the compiler setup, so it can be moved anywhere or made a repository of
its own.

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

A rejection says *where*, not just that it rejected. `incorrect` replays the
proof and names the command that got stuck — `the checker became stuck at step
@p3 (proof command 2)` — which is the difference between a usable diagnostic and
a verdict on a thousand-step derivation. `incomplete` names what the semantics
does not model.

What a fresh checker cannot say is that any of this has been *proven*.
`Proofs/Checker.lean` holds the soundness theorem and it is a `sorry`, as is
every rule. So `correct` reports that the checks passed, not that the
assumptions are provably unsatisfiable.

Those are separate axes and are reported separately on purpose. Everything above
the theorem is already wired to it — `ApiCorrect.lean` states correctness about
the *text* of a proof file and derives it from `Proofs/Checker.lean` — so
discharging that one theorem closes the gap with no other file changing.
`scripts/rule-status.sh` is where progress shows, not the verdict.

## Repository layout

```text
config.sh                  the settings a run reads
scripts/new-checker.sh     the generator
scripts/get-eo-compiler.sh fetches and builds the Eunoia compiler, pinned
templates/                 what it renders, one file per generated file
  pkg/ install/ scripts/  the checker's package, installer and dev scripts
  docs/ ci/ test/         its documentation, CI workflow and test layout
docs/eoc-requests.md       what a template needs from the eoc compiler
examples/cpc/              a worked specification: CPC, as Logos compiles it
checkers/                  where runs write, ignored by git
deps/                      the Ethos tree and ethos-eoc, ignored by git
TODO.md                    what Logos has that a generated checker still needs
```

Templates are plain files with `@CHECKER@`, `@CALCULUS@`, `@EXE@` and
`@TOOLCHAIN@` substituted in. Adding a file to a generated project means adding
a template and one `render` line in the script.

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
