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

### Required builtins

The correctness development is not neutral about vocabulary. It is stated in
terms of specific operators, referenced as constructors of the `UserOp` enum
the signature compiles to, so a signature that does not declare them under
these names does not merely lose a feature — the core proofs stop typechecking.

| symbol | arity | why the core needs it |
| ------ | ----- | --------------------- |
| `and` | binary | The soundness statement is about the *conjunction* of a proof's assumptions. The assumption term is literally `(and A rest)`, and the state invariants are stated over it. |
| `imp` | binary | Discharging an assumption — `scope` — yields an implication, so the state invariants are stated over it too. |
| `not`, `eq` | binary | The shared lemma base the rule proofs draw on. |
| `Bool` | type | The checker's guard: every assumption and every proven term must have EO type `Bool`. |
| `true`, `false` | literals | What a proof is checked to entail, and what a refutation reaches. |

Declaring an operator with the right *name* is necessary but not sufficient: it
must also **mean** what the SMT-LIB semantics says it means. A signature whose
`and` is not conjunction will compile and then fail to prove.

Everything else about the vocabulary is yours. The embedding supplies the rest
of the structure — `Apply`, `UOp`, `Stuck`, `Type`, the Eunoia list — and the
signature supplies the theory.

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
  test/regress/            proofs to check, and the verdict each should get
  .github/workflows/ci.yml
  .gitignore
  lakefile.toml
  lean-toolchain
  Main.lean
  <Calculus>.lean
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
```

That compiles the CPC signature into 8 signature-wide modules and 591 rule
stubs, and builds them. The generated Lean is byte-identical to what Logos
carries, modulo the header naming which installer wrote it.

Any signature reachable on the machine can be compiled instead, including one
sitting in a tree of includes:

```bash
install/install-cpc.sh ~/cvc5/proofs/eo/cpc/Cpc.eo
```

That also **records** it — flattening the tree into `install/defs/Cpc.eo` as
one self-contained file — so the checker carries the signature it was built
from and can be regenerated without that tree.

A signature or semantics file you do not name is written as a commented stub to
fill in, so the project has the file either way and says in it what it is for.
That is the expected state before a calculus has been settled on: the project
still builds and the executable still runs, and both say what is missing.

## Repository layout

```text
config.sh                  the settings a run reads
scripts/new-checker.sh     the generator
scripts/get-eo-compiler.sh fetches and builds the Eunoia compiler, pinned
templates/                 what it renders, one file per generated file
  pkg/ install/ scripts/  the checker's package, installer and dev scripts
  docs/ ci/ test/         its documentation, CI workflow and test layout
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
