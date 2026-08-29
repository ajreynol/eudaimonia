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

`scripts/new-checker.sh --help` lists the rest. Then build what it wrote:

```bash
cd checkers/Aletheia && lake build
```

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

```text
<Checker>/
  lakefile.toml        the package: the <Calculus> library and the <checker> executable
  lean-toolchain       the pinned Lean version
  Main.lean            the executable: read a proof, report a verdict
  <Calculus>.lean      the root of the library
  <Calculus>/          the calculus: terms, proof rules, semantics, correctness
    Basic.lean         a placeholder, until a signature is compiled in
  signature/           what the calculus is, and what it means
    <Calculus>.eo      the Eunoia signature
    <Calculus>.eos     what its symbols mean
  README.md
```

A signature or semantics file you do not name is written as a commented stub to
fill in, so the project has the file either way and says in it what it is for.
That is the expected state before a calculus has been settled on: the project
still builds and the executable still runs, and both say what is missing.

## Repository layout

```text
config.sh              the settings a run reads
scripts/new-checker.sh the generator
templates/             what it renders, one file per generated file
checkers/              where runs write, ignored by git
```

Templates are plain files with `@CHECKER@`, `@CALCULUS@`, `@EXE@` and
`@TOOLCHAIN@` substituted in. Adding a file to a generated project means adding
a template and one `render` line in the script.

## Status

What is here is the build infrastructure: a run generates a Lake project that
builds clean and an executable that runs, with the calculus stubbed out.

Compiling a Eunoia signature into Lean — what `install/` does in Logos, using
the `ethos-eoc` compiler from [cvc5/ethos](https://github.com/cvc5/ethos) — is
not part of this yet, and neither is the signature-independent proof
infrastructure Logos carries in its `Logos/` library. Those are the next steps,
and how much of Logos can be reused verbatim in them is still open.
