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

The full set of artifacts Logos's `install/install-cpc.sh` produces, plus the
hand-written modules it leaves alone — every one a stub describing what belongs
in it and which Logos file it corresponds to:

```text
<Checker>/
  lakefile.toml            the package: the <Calculus> library and the <checker> executable
  lean-toolchain           the pinned Lean version
  Main.lean                the executable: read a proof, report a verdict
  <Calculus>.lean          the root of the library
  <Calculus>/
    SmtEval.lean           G  the primitives the embedding is evaluated over
    <Checker>Term.lean     G  the term datatype of the calculus
    SmtModelDefs.lean      G  what the model semantics is built from
    SmtValueOrder.lean     G  the order on values
    SmtModel.lean          G  the model semantics of SMT-LIB
    Spec.lean              G  calculus <-> SMT-LIB, and satisfiability
    <Checker>.lean         G  the core checker
    Parser.lean            G  the operator table for this signature
    Api.lean               H  what the executable does with a file
    ApiChecks.lean         H  each check is the component it stands for
    ApiCorrect.lean        H  the theorem, about the text of a file
    Diagnostics.lean       H  why a run came back incomplete
    Proofs/
      Assumptions.lean     H  the side conditions, and deciding them
      CheckerCore.lean     H  correctness of the core, rule-agnostic
      RuleLemmas.lean      G  the dispatcher over the rules
      Checker.lean         H  the soundness theorem
      Rules/               G+H  one file per rule: statement generated, proof yours
  signature/
    <Calculus>.eo          the Eunoia signature
    <Calculus>.eos         what its symbols mean
    smt.eos                the SMT-LIB semantics that is written against
  README.md
```

**G** is generated from the signature and overwritten by a regeneration; **H**
is hand-written and left alone. Each file says which it is in its own header,
because that distinction is what makes regeneration safe. `Proofs/Rules/` is
both: the compiler emits each rule's statement with `sorry`, the proof goes in
that same file, and a reinstall then preserves it.

A signature or semantics file you do not name is written as a commented stub to
fill in, so the project has the file either way and says in it what it is for.
That is the expected state before a calculus has been settled on: the project
still builds and the executable still runs, and both say what is missing.

## Repository layout

```text
config.sh              the settings a run reads
scripts/new-checker.sh the generator
templates/             what it renders, one file per generated file
examples/cpc/          a worked specification: CPC, as Logos compiles it
checkers/              where runs write, ignored by git
TODO.md                what Logos has that a generated checker still needs
```

Templates are plain files with `@CHECKER@`, `@CALCULUS@`, `@EXE@` and
`@TOOLCHAIN@` substituted in. Adding a file to a generated project means adding
a template and one `render` line in the script.

## Status

What is here is the build infrastructure and the shape of a checker: a run
generates a Lake project that builds clean, an executable that runs, and every
module a checker needs as a stub describing what belongs in it. None of the
content exists.

The largest missing piece is the one everything waits on — compiling a Eunoia
signature into Lean, which is what `install/` does in Logos using the
`ethos-eoc` compiler from [cvc5/ethos](https://github.com/cvc5/ethos). After
that: the signature-independent parser library, the core correctness proof, and
the per-rule proofs (591 files in Logos).

**[TODO.md](TODO.md)** sets all of it out, item by item, against the Logos
files each item corresponds to.
