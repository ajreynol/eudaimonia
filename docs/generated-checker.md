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
3. **[The Logos experience report](logos-experience-report.md)** — every `sorry`
   the checker contains, in reading order, with what the same obligation cost
   Logos. It lives here rather than in the generated project, since it describes
   Logos rather than any one calculus.
4. **`install/README.md`** — how it is regenerated from the signature, and
   crucially *what regeneration overwrites and what it preserves*.
5. **`docs/development.md`** — the working loop: build, check, add a rule.
6. **`<Calculus>/`** — the package itself. Every module says in its own header
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
  <Calculus>/                the calculus: 23 modules, G / F / H (see below)
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

## Finished, open, generated

A file in a generated checker is one of three things, and every file says which
in its own header.

| | meaning | you edit it? |
| --- | ------- | ------------ |
| **GENERATED** | the compiler writes it from your signature | never — the next install overwrites it |
| **FINISHED** | copied in complete by the generator | never — there is nothing missing |
| **OPEN** | work you have to do, in that file | **yes** |

**A `sorry` in a dependency does not make a file open.** This is the distinction
that matters, and it is easy to get backwards.

A file is *finished* when you will not need to edit it. That is a statement
about the file, not about whether it builds. `ApiCorrect.lean` is finished: it
states soundness about the text of a proof file and derives it from
`Proofs/Checker.lean`. It will not build until that theorem is discharged — and
that is not a defect in `ApiCorrect.lean`, and no reason to open it.

A file is *open* when it contains a `sorry`, or a gap, **that is yours to close
there**. `Proofs/NonVacuity.lean` is open: the `sorry` in it is the work.

So the question to ask of a red build is not "which file failed" but "which
*open* file is still open". `scripts/rule-status.sh` and
`scripts/run-ci.sh hygiene` answer that; the build does not.

### Why the distinction earns its keep

Without it, a generated checker looks like it has far more work in it than it
does. Almost everything that fails to build in a fresh checker fails because
something downstream of it is open — not because it is unfinished. Counting
build errors would suggest dozens of files need attention; counting *open* files
gives the real number, which is six plus the rules.

It also names a goal precisely. `Proofs/Checker.lean` is **open and should be
finished**: it is byte-identical between Logos's two packages, names no rule and
no operator, and is a proof about a stack machine rather than about a calculus.
Getting it to arrive finished — carrying a `sorry` only in what it depends on —
is the single largest improvement available, and is item 5 of
[eoc-requests.md](eoc-requests.md).

```text
<Calculus>/
  SmtEval.lean            G  primitives the embedding is evaluated over
  <Checker>Term.lean      G  the term datatype of the calculus
  SmtModelDefs.lean       G  what the model semantics is built from
  SmtValueOrder.lean      G  the order on values
  SmtModel.lean           G  the model semantics of SMT-LIB
  Spec.lean               G  <Calculus> <-> SMT-LIB, and satisfiability
  <Checker>.lean          G  the core checker
  Parser.lean             G  the operator table for this signature
  Proofs/RuleLemmas.lean  G  the dispatcher over the rules

  Api.lean                F  parse, then the three checks
  ApiChecks.lean          F  each check is the theorem component it stands for
  ApiCorrect.lean         F  soundness about the text of a file
  Diagnostics.lean        F  where a rejected proof broke
  Proofs/Assumptions.lean F  the side conditions, and deciding them
  Proofs/Checker.lean     F* the soundness theorem -- not calculus-specific

  ModelWf.lean                     H  what a well-formed model gives you
  Proofs/Invariants/Extra.lean     H  ** the calculus-specific seam **
  Proofs/TypePreservation.lean     H  a typed term has a well-formed type
  Proofs/TranslationTypePreservation.lean
                                   H  ** cannot be inherited **
  Proofs/NonVacuity.lean           H  a well-formed model exists
  Proofs/Canonicity.lean           H  literals evaluate to normal form
  Proofs/RuleSupport/Support.lean  H  what rule statements are written against
  Proofs/CheckerCore.lean          H  correctness of the core, rule-agnostic
  Proofs/Rules/                  G+H  statement generated, proof yours
```

**F\*** — `Proofs/Checker.lean` is neither yours to write nor yet copied in. In
Logos the corresponding file is **byte-identical** between `Cpc` (591 rules) and
`CpcMini` (5 rules) — packages differing in rule set, in signature, *and* in
which invariants their rules need. It names no rule and no operator, and uses
three `Term` constructors: it is a proof about a stack machine that pushes
assumptions and proven facts, not about a calculus. It should arrive complete,
and does not only because upstream maintains it per package rather than seeding
it (`docs/eoc-requests.md` item 5, the top of that list). It carries a `sorry`
today; it is still not where the calculus-specific work is.

Everything *outside* `<Calculus>/` is **F** as well: the format library, the
scripts, the installer, the CI workflow, `Main.lean`, the Lake files. All copied
in working.

### Where to start

**`Proofs/Invariants/Extra.lean`.** This is what actually differs between two
checkers. The core maintains three invariants of the proof state on its own —
well typed, translatable, locally true — and this slot is for whatever *your*
rules need beyond them. A calculus needing nothing leaves it pointed at `True`
and pays nothing; CPC uses it for variable stability, so that binder-sensitive
rules can be given premise truth in a variable-variant model.

The choice is coupled to `Proofs/RuleSupport/Support.lean`: making the extra
invariant load-bearing means adding a matching field to the evidence a rule gets
about its premises. Decide both together, up front.

Then **the front-end theorems** — `ModelWf.lean` and the four under `Proofs/`.
These are what the rule proofs stand on, and they scale with how many SMT
theories the calculus takes on rather than with how many rules it has. In Logos
the corresponding material is 61,000 lines against a 4,500-line checker layer:
the dominant cost of a new checker.

| file | what it says | inheritable? |
| ---- | ------------ | ------------ |
| `ModelWf.lean` | what `model_wf` gives you | **proven here**, against the current definition |
| `Proofs/TypePreservation.lean` | a typed term has a well-formed type | in principle |
| `Proofs/TranslationTypePreservation.lean` | the type of a translated term is the translation of its type | **no** |
| `Proofs/NonVacuity.lean` | a well-formed model exists | in principle |
| `Proofs/Canonicity.lean` | literals evaluate to normal form | in principle |

Each is a **leaf**: none imports another, so a `sorry` in one does not stop the
rest from building and they can be taken in any order.

Only the translation bridge is irreducibly yours — it is about `__eo_to_smt` for
*your* operators, generated from *your* `.eos`. "In principle" for the others
means *while the SMT-LIB semantics is the stock one*: supply your own
`smt.eos`, change what a type is or what makes a model well-formed, and they
become yours regardless of what upstream ships. `ModelWf.lean` shows both sides
— proven here, and its proofs are precisely what a change to `model_wf` breaks.
The `logos-smt` entry of `install/defs/profile.conf` records which case you are
in.

Non-vacuity is the one easiest to skip and worst to omit: soundness says the
assumptions hold in *no* well-formed model, so if nothing satisfied `model_wf`
the development would prove nothing while appearing to prove everything.

`--theorems` selects which four are generated; the invariant slot and type
preservation are always there.

Then `Proofs/RuleSupport/Support.lean` — every generated rule statement is
written against the names it supplies, so until it is real no rule can be built
at all, and `scripts/build-rules.sh` says so rather than reporting hundreds of
identical errors. Then `Proofs/CheckerCore.lean`, then the rules.

`Proofs/Assumptions.lean` is marked F because it arrives general and working,
but expect to strengthen it per rule as the proofs turn out to need more than
"the arguments translate".

`Proofs/Rules/` is the one set that is both G and H: the compiler emits a rule's
statement with `sorry` for its proof, the proof goes in that same file, and a
reinstall **preserves** it. So a rule new to the signature arrives as a stub, and
a rule whose statement changed keeps its old proof and therefore fails to build
— which is the signal that a proof needs attention.

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
| `--theorems LIST` | which front-end theorems are written: `all`, `none`, or from `translation`, `nonvacuity`, `canonicity`, `modelwf`. `Proofs/Invariants/Extra.lean` and `Proofs/TypePreservation.lean` are always generated |
| `--force` / `--clobber` | regenerating over an existing project. `--force` refuses if it holds rule proofs or a git repository; `--clobber` deletes it regardless, and is not recoverable |
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
