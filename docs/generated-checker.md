# Anatomy of a generated checker

What `scripts/new-checker.sh` produces, how to find your way around it, and
which option decided each part.

This describes the **generated project**, not this repository. For this
repository — the templates and the generator — see the *This repository*
section of the [README](../README.md).

A generated checker is standalone. It does not refer back here, owns the
compiler that regenerates it, and can be moved anywhere or made a repository of
its own.

Throughout, `<Checker>`, `<Calculus>` and `<Format>` stand for what you passed
to `--checker`, `--calculus` and `--format-name`. The examples use
`--checker Logos --calculus Cpc`, so `<Checker>` is `Logos` and `<Calculus>` is
`Cpc`.

---

## Where to start reading

In this order, when you open a checker you did not generate:

1. **`README.md`** — what it is and how to build it.
2. **`docs/calculus.md`** — what calculus it checks, what the signature must
   provide, and its profile.
3. **`install/README.md`** — how it is regenerated from the signature, and
   crucially *what regeneration overwrites and what it preserves*.
4. **`docs/development.md`** — the working loop: build, check, add a rule.
5. **`<Calculus>/`** — the package itself. Every module says in its own header
   whether it is generated or hand-written.

If you only want to know how far the work has got, two commands answer it:

```bash
scripts/rule-status.sh      # how many rules are proven
scripts/run-ci.sh hygiene   # what is still `sorry`
```

## The tree

```text
<Checker>/
  README.md                  what this checker is
  lakefile.toml              the Lake package
  lean-toolchain             the pinned Lean version
  Main.lean                  the executable: read a proof, print a verdict

  <Format>.lean              reading the input proof format --
  <Format>/Sexp.lean           an s-expression reader and a table-driven
  <Format>/Parser.lean         parser. Independent of the calculus.

  <Calculus>.lean            the calculus library root
  <Calculus>/                the calculus: 17 modules, G or H (see below)
    Proofs/Rules/            one file per rule of the signature
    Proofs/RuleSupport/      what every rule statement is written against

  <Calculus>Mini.lean        the reduced package: same signature, few rules
  <Calculus>Mini/

  install/                   regenerating the calculus from its signature
    defs/<Calculus>.eo         the Eunoia signature
    defs/<Calculus>.eos        what its symbols mean
    defs/smt.eos               the SMT-LIB semantics that is written against
    defs/profile.conf          the calculus profile
    get-eo-compiler.sh         fetch and build ethos-eoc, and ethos
    install-<calculus>.sh      compile the signature into <Calculus>/
    deps/                      the Ethos tree and the compilers (gitignored)
    README.md

  scripts/                   build.sh, build-rules.sh, rule-status.sh,
                             check-proof-hygiene.sh, check-with-ethos.sh,
                             run-ci.sh
  docs/                      calculus.md, development.md
  test/regress/              proofs, expected verdicts, and a runner
  .github/workflows/ci.yml
  .gitignore
```

## Generated or hand-written

Every module under `<Calculus>/` carries a header saying which it is. The
distinction is what makes regeneration safe.

| | meaning | on reinstall |
| --- | ------- | ------------ |
| **G** | compiled from the signature | **overwritten** |
| **H** | hand-written | **left alone** |

```text
<Calculus>/
  SmtEval.lean           G  primitives the embedding is evaluated over
  <Checker>Term.lean     G  the term datatype of the calculus
  SmtModelDefs.lean      G  what the model semantics is built from
  SmtValueOrder.lean     G  the order on values
  SmtModel.lean          G  the model semantics of SMT-LIB
  Spec.lean              G  <Calculus> <-> SMT-LIB, and satisfiability
  <Checker>.lean         G  the core checker
  Parser.lean            G  the operator table for this signature
  Api.lean               H  what the executable does with a file
  ApiChecks.lean         H  each check is the theorem component it stands for
  ApiCorrect.lean        H  the soundness theorem, about the text of a file
  Diagnostics.lean       H  where a rejected proof broke
  Proofs/
    Assumptions.lean     H  the side conditions, and deciding them
    CheckerCore.lean     H  correctness of the core, rule-agnostic
    RuleLemmas.lean      G  the dispatcher over the rules
    Checker.lean         H  the soundness theorem
    RuleSupport/         H  what rule statements are written against
    Rules/               G+H  statement generated, proof yours
```

`Proofs/Rules/` is both, and is the one place where that matters: the compiler
emits a rule's statement with `sorry` for its proof, the proof goes in that same
file, and a reinstall **preserves** it. So a rule new to the signature arrives
as a stub, and a rule whose statement changed keeps its old proof and therefore
fails to build — which is the signal that a proof needs attention.

### Two names that are not what they look like

`<Checker>.lean` and `<Checker>Term.lean` are named after the **checker**, not
the calculus, because that is what they are: the core checking machinery and the
term datatype it runs on. With `--checker Logos --calculus Cpc` they are
`Cpc/Logos.lean` and `Cpc/LogosTerm.lean` — the same names Logos itself uses.
With `--checker Hello --calculus Hello` they are `Hello/Hello.lean` and
`Hello/HelloTerm.lean`.

The compiler emits both under the fixed name `Logos`, whatever you called your
checker, and the installer renames them and rewrites the imports. If you see
`Logos` in a checker of yours that is not called Logos, that rename did not
happen.

## Which option produced what

| option | what it decides |
| ------ | --------------- |
| `--checker NAME` | the project directory, the Lake package, the executable (lowercased), and `<Calculus>/<Checker>.lean` + `<Checker>Term.lean` |
| `--calculus NAME` | the calculus library: `<Calculus>.lean` and `<Calculus>/` |
| `--format-name NAME` | the format library: `<Format>.lean`, `<Format>/Sexp.lean`, `<Format>/Parser.lean`. Defaults to `Eunoia` |
| `--toolchain VERSION` | `lean-toolchain` |
| `--out DIR` | where the project is written. Defaults to `checkers/` in this repository, which is not kept in git |
| `--signature` / `--semantics` / `--smt-semantics` | `install/defs/*` |
| `--spec DIR` | all three of the above at once, plus `test/` → `test/regress/`, `mini-rules` → `MINI_RULES`, and `profile` → `install/defs/profile.conf` |
| `--dummy-rule` | with no signature given, a **working** starter instead of commented stubs: a one-rule signature, its semantics, and five regression proofs covering every verdict |
| `--mini` | `<Calculus>Mini.lean`, `<Calculus>Mini/`, and a second `lean_lib` |
| `--mini-rules "A B"` | which rules that package keeps (`MINI_RULES` in the install script) |
| `--hygiene-ci` | whether `hygiene` is among the default groups of `scripts/run-ci.sh` |
| profile flags (`--[no-]scopes`, `--[no-]list-premises`, `--[no-]datatypes`, `--[no-]binders`, `--[no-]value-ordering`, `--indexed-ops N`, `--[no-]parser`) | `install/defs/profile.conf`, which the installer re-checks against the compiled signature |

Two things are decided *after* generation, by the install script rather than by
the generator:

- **`install/install-<calculus>.sh --mini`** is what actually compiles the
  reduced package. `--mini` at generation time creates it; this fills it in.
- **`install/get-eo-compiler.sh`** carries `DEV_MODE`, which decides whether the
  Eunoia compiler is pinned or follows the development branch. It is a constant
  in that script, not a generator option — see the README.

## What is not there

- **No git repository.** A generated project ships a CI workflow but is not
  itself a repo; run `git init` if you want one.
- **No LICENSE**, though `<Format>/Sexp.lean` is vendored under Apache 2.0 and
  its header refers to one. Fix that before distributing a checker.
- **No proofs.** Every rule is a `sorry`, the soundness theorem in
  `<Calculus>/Proofs/Checker.lean` is a `sorry`, and
  `<Calculus>/Proofs/RuleSupport/Support.lean` — which every rule statement is
  written against — is a stub. The scaffolding is complete; the development is
  not.
