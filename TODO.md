# Roadmap

> ⚠️ **This repository is in development mode.**
> `scripts/get-eo-compiler.sh` builds the head of the `ethosEoc3` branch rather
> than a pinned commit, so **builds are not reproducible**. Temporary and
> deliberate; see [Leave development mode](#1-compiling-the-signature) below.

What [Logos](https://github.com/cvc5/logos) has that a generated checker will
need. Each item names the Logos files it corresponds to, so that what is being
generalized is always in view.

The generator currently produces the *shape* of all of this — every module
below exists as a stub carrying its own description — and none of the content.
The ordering is roughly the order in which the items unblock each other.

---

## 1. Compiling the signature

The whole point, and the thing everything else waits on. A generated project
has a `signature/` directory and no way to turn it into Lean.

- [x] **Fetch and pin the Eunoia compiler.** `scripts/get-eo-compiler.sh`.
      `ethos-eoc` is built from the `plugins/` project of an
      [Ethos](https://github.com/cvc5/ethos) checkout and reads its templates
      out of that tree, so the tree is the dependency, not just the binary.
      Builds from `ethosEoc3`, where the compiler is developed; paths recorded
      in `deps/eoc-env.sh`. Either a fixed commit or the branch head, per
      `DEV_MODE` — see the next item. Whichever it gets, it checks the fetched
      tree for `--calc-name`, `--smt-semantics`, `--semantics` and
      `--no-parser` before building, so a commit without them fails there
      rather than inside a later compile.
- [ ] **⚠️ LEAVE DEVELOPMENT MODE.** `scripts/get-eo-compiler.sh` has
      `DEV_MODE=1`, so it builds the *head* of `ethosEoc3` resolved at run
      time, not a fixed commit. **Builds are therefore not reproducible**: two
      runs on different days build different compilers, and a checker generated
      today cannot be regenerated identically later. This is deliberate for now
      — the compiler is under active development on that branch and tracking it
      is the point — but it has to end before anyone else relies on this
      repository, and before any claim that a generated checker can be
      reproduced.

      To leave: set `DEV_MODE=0` and set `ETHOS_VERSION` to the commit last
      built. A tip run prints both lines at the end, and `deps/eoc-env.sh`
      records `EOC_ETHOS_VERSION` and `EOC_DEV_MODE` for whatever needs to know
      which it got. Pinning what was just built changes nothing about the
      compiler — only whether the next run is allowed to move.
- [ ] **Move the pin to `main` when it can carry one.** The pin is on a
      development branch, whose head moves. Main's `driver.py` has
      `--semantics` but not `--calc-name` or `--smt-semantics`, which are the
      configurable calculus name and the third specification file — the two
      things that make this a template rather than a copy of Logos. Logos
      carries the same workaround and the same TODO.
- [x] **Run the compiler and install what it publishes.**
      `install/install-<calc>.sh` in a generated checker drives
      `driver.py lean` with `--semantics`, `--smt-semantics` and `--calc-name`,
      then installs the published tree. Verified against `examples/cpc`: 8
      signature-wide modules and 591 rule files, byte-identical to what Logos
      carries modulo the generated header, and the result builds.
- [x] **Preserve per-rule proofs across a regeneration.** Signature-wide
      modules are overwritten; files under `Proofs/Rules/` are kept, because the
      proof lives in the same file as the generated statement. Verified: a
      second install reports `0 written, 591 preserved` and a hand edit to a
      rule file survives it.
- [x] **`--check` mode.** Installs into a throwaway copy and compares, exiting
      1 if anything would change. Doing the real install and comparing is what
      keeps the check from drifting from the install it checks.
- [x] **The checker owns its own development infrastructure.** A generated
      directory has `install/` (compiler setup, installer, `defs/`), `scripts/`
      (build, proof hygiene, CI groups), `docs/` about its own calculus,
      `test/regress/`, a CI workflow and a `.gitignore` — the Logos shape. It
      does not refer back to this repository.
- [x] **`--force` no longer destroys proofs.** `scripts/new-checker.sh --force`
      refuses when the target holds rule proofs or a git repository, names what
      it found, and points at the checker's own installer — which is the right
      way to refresh a calculus, since it keeps every proof. `--clobber` is the
      explicit, unrecoverable "start over anyway".
- [x] **Cache the signature.** A signature given by path is recorded into
      `install/defs/<Calculus>.eo` as one self-contained file: every
      `(include "...")` replaced by the text of the file it names, each file
      once and in the order ethos reads them, comments dropped. So a checker
      carries the signature it was built from and a regeneration needs nothing
      outside it, and a diff of that file is a diff of the calculus.
      `--no-record` skips it, and a `--rules` run records nothing since a
      reduced calculus is not the signature.

      Verified against cvc5's `proofs/eo/cpc/Cpc.eo` — a tree of 14 includes.
      The flattened result compiles to Lean identical to compiling the original
      tree, which is the property that makes the copy worth keeping.

## 2. Reading proofs

- [x] **A signature-independent parser library.** A generated checker carries
      `Eunoia/` — an s-expression reader and a table-driven parser for the
      Eunoia proof format, adapted from Logos\'s `Logos/Sexp.lean` and
      `Logos/Parser.lean`, ~1,080 lines. Named for the format rather than for a
      checker, since the checker\'s own name is the user\'s to choose. The
      installer rewrites the compiler\'s `Logos.Parser`/`Logos.Sexp` imports
      onto it.
- [x] **Delivery decided: vendored.** A generated project stays self-contained
      and movable, which is worth more here than letting fixes propagate from a
      shared dependency. Revisit if several checkers ever exist at once.
- [x] **The parser is wired to the correctness statement.** `Api.lean` is one
      function from file text to verdict; `ApiChecks.lean` proves each check is
      the component of `correct___eo_is_refutation` it stands for — including
      that the constant-stack fold over the parser\'s list is the same run as
      the recursion over the `and`-chain — and `ApiCorrect.lean` states
      soundness about the text of a file, deriving it from the one theorem the
      user fills in. All of it proven except that theorem.

- [ ] **Superseded:** the note that once stood here said the parser was the
      blocking item for a usable checker. It is done. Logos's `Logos/Sexp.lean`
      (an s-expression reader, ~156 lines) and `Logos/Parser.lean` (a
      table-driven proof parser, ~913 lines) are genuinely calculus-agnostic:
      the generated `Cpc/Parser.lean` is only the operator table that plugs into
      them. This is the largest piece of Logos that could be reused as-is, and
      until it exists the generated `Parser.lean` has nothing to plug into.
- [ ] **Decide how it is delivered** — vendored into each generated project, or
      a Lake dependency the generated `lakefile.toml` requires. A dependency
      keeps generated projects thin and lets fixes propagate; vendoring keeps
      them self-contained, which is what they are today.
- [ ] **Document the accepted syntax**, as Logos does in `docs/parser.md`. The
      generated `docs/calculus.md` has a placeholder section for it.

Note that the parser is *unverified* in Logos, deliberately: the soundness
theorem is stated about whatever the parser read out of the file. That is a
property to preserve and to state plainly, not a gap.

## 3. The correctness development

- [ ] **The core checker proof** (`Cpc/Proofs/CheckerCore.lean`, ~3,000 lines).
      Rule-agnostic — it is about the machinery of proof checking, not about any
      calculus — so it is the other strong candidate for reuse across checkers.
- [ ] **The side conditions** (`Cpc/Proofs/Assumptions.lean`, ~257 lines): the
      predicates restricting a proof to terms the semantics models, *and* the
      `Decidable` instances that decide them. Both from one definition, so that
      what the rule proofs assume and what the executable checks cannot drift.
- [ ] **The soundness theorem** (`Cpc/Proofs/Checker.lean`, ~1,063 lines):
      `correct___eo_is_refutation`.
- [ ] **Per-rule correctness proofs** (`Cpc/Proofs/Rules/`). Generated as
      `sorry` stubs, discharged by hand. For scale: **591 files in Logos.** This
      is the bulk of the work in building a checker and cannot be automated
      away; everything else on this list exists to make it tractable.
- [ ] **Shared rule support lemmas** (`Cpc/Proofs/RuleSupport/`) — per-theory
      lemma libraries the individual rule proofs draw on.

## 4. From the theorem to the executable

The part that makes the printed verdict mean the theorem, rather than an
informal argument about it.

- [ ] **One function for what the executable does** (`Cpc/Api.lean`): parse,
      then run the checks standing for the theorem's hypotheses.
- [ ] **Proofs that each check is the component it stands for**
      (`Cpc/ApiChecks.lean`) — this is what licenses an efficient
      implementation, e.g. a constant-stack fold in place of a recursion.
- [ ] **The theorem restated about file text** (`Cpc/ApiCorrect.lean`):
      `correct___logos_check_proof`.
- [ ] **Three verdicts, not two.** `correct` / `incorrect` / `incomplete`, with
      `incomplete` for a proof the checker accepts that mentions something the
      semantics does not model. Collapsing it into `correct` would overstate
      what the theorem says.
- [ ] **Diagnostics** (`Cpc/Diagnostics.lean`): say *which* assumption or
      command took a proof outside the modelled fragment.

## 4b. Modularizing Logos — what is actually reusable

Notes from measuring the Logos tree, for whoever works on making a second
checker cheap. **`Cpc/Proofs/` is 97.7% of the package** (734,867 of 751,808
lines, 816 files), so this is where the question lives.

### The prerequisite: a stable core model

The obvious approach — grep for signature vocabulary, call the files that
mention none of it reusable — **does not work**, and it is worth writing down
why, because the metric is seductive.

Compilation *configures the model*. Diffing the `CpcMini` package against `Cpc`,
both compiled from the same signature, one with five rules:

| generated module | CpcMini | Cpc |
| ---------------- | ------- | --- |
| `SmtModel.lean` | 743 | 2,186 |
| `Spec.lean` | 105 | 475 |
| `SmtModelDefs.lean` | 171 | 297 |
| `LogosTerm.lean` | 135 | 312 |
| `SmtEval.lean` | 74 | 175 |
| `SmtValueOrder.lean` | 156 | 156 (identical) |

So a proof file that never names an operator is still *stated about* a
`SmtModel` that varies with the signature. Syntactic independence is not
semantic independence, and only `SmtValueOrder` is invariant outright.

- [ ] **Stabilize the SMT-LIB model as a fixed base that signatures extend**,
      rather than a per-signature emission. This is the prerequisite for
      everything below it: until the model is fixed, a "generic" proof about it
      is generic only by coincidence.

### What that would unlock

Measured the same way — diffing `CpcMini` against `Cpc` — parts of the
hand-written proof tree are already invariant, and parts are not:

| file | CpcMini | Cpc | differing lines |
| ---- | ------- | --- | --------------- |
| `Canonical/TypeDefaultBasic.lean` | 228 | 228 | **0** |
| `TypePreservation/Datatypes.lean` | 1,334 | 1,334 | **0** |
| `TypePreservation/Common.lean` | 529 | 529 | 4 |
| `TypePreservation/Nonvacuity.lean` | 104 | 104 | 2 |
| `TypePreservation/Model.lean` | 203 | 208 | 15 |
| `Invariants/Stability.lean` | 488 | 550 | 108 |
| `TypePreservation/Base.lean` | 411 | 832 | 521 |
| `TypePreservation/Support.lean` | 95 | 957 | 862 |
| `TypePreservation/CoreArith.lean` | 255 | 1,203 | 1,092 |
| `Translation/Apply.lean` | 120 | 17,003 | 17,033 |

`TypePreservation/` is roughly half invariant and half configured;
`Translation/` is thoroughly per-calculus. The two packages also maintain these
by hand in parallel, so some of the difference is duplication rather than
necessity — worth separating before drawing conclusions from any single row.

- [ ] **Extract the invariant core** once the model is stable. The core checker
      proof (`Checker.lean`, `CheckerCore.lean`, `CheckerState.lean`,
      `Invariants/`, `Common.lean` — about 4,900 lines) depends on the signature
      through exactly **two** operators, `and` and `imp`. It was four; Logos
      has since removed the dependence on `eq` and `not`, which is evidence
      that the remaining two are close to irreducible — they are what the
      *statement* of soundness needs, not what any rule needs. `Checker.lean`
      alone references **no** `UserOp` and **no** `CRule`.
- [ ] **Add a third file category to this template: L, library.** It currently
      splits files into G (generated, overwritten) and H (hand-written,
      preserved). What the above produces is neither: files a generated project
      *inherits* rather than writes. That distinction is the difference between
      a scaffold and a framework.

### What makes it tractable, and what to watch

`Term` has **no per-operator constructors**. Operators live in the
`UserOp`/`UserOp1`/`UserOp2`/`UserOp3` enums and `Term` is uniform (`UOp`,
`Apply`, plus core), so the core proofs never pattern-match an individual
operator. Parameterizing `Term` over the op enums with a small class supplying
the four required operators is therefore far cheaper than abstracting the term
algebra.

The risk to price first: the proofs lean on `simp` over concrete constructors,
and abstraction routinely breaks that automation. Try it on
`Invariants/Stability.lean` — 319 lines, one operator — before committing the
other 4,600.

### Corrections from the Logos maintainer

`~/logos/docs/modularity.md` (2026-08-29) measures the same tree from the other
side and sends back two corrections to what is above. Both are accepted, and
both were verified here rather than taken on trust.

**The required-operator list was stale, twice.** It is now **`and` alone**.
`not` and `=` went, then `imp` — the last by accident, five `eo_interprets_imp_*`
lemmas in `CheckerState.lean` that nothing in the checker used. Verified: the
core files name `UserOp.and` and nothing else, and `Proofs/Checker.lean` names
no `UserOp` at all.

**The 108 differing lines in `Invariants/Stability.lean` are necessity, not
duplication.** Cpc carries the real `StableWhenTrueInAnyVarModel` machinery;
CpcMini defines it `True`. The table above should not be read as saying that
file has drifted.

### What the report establishes that this roadmap could not

Measuring from outside, the best available evidence was a diff between two
packages. From inside, the maintainer can say what the diff *means*:

- **`Proofs/Checker.lean` is byte-identical between `Cpc` and `CpcMini`**
  modulo the package name — verified here. Zero `CRule`, zero `UserOp`, three
  `Term` constructors. And the two packages differ in rule set (591 vs 5), in
  signature, *and* in which invariants their rules need, so this is real
  separation rather than two calculi that happen to be similar.
- **`CheckerState.lean` contains no occurrence of `Invariant`** — verified.
- **The extra-invariant slot** (`Invariants/Stability.lean`) is the designed
  escape hatch: four `abbrev`s plus a preservation lemma, pointed at `True` by a
  calculus that needs nothing. It is coupled to `RuleSupport/Contract.lean`, and
  the report is explicit that the two choices are made together, up front.
- **The layering is the reusable unit, and it is template reuse, not library
  reuse.** The report accepts the finding above that compilation configures the
  model, and agrees the same text about two different types is what
  byte-identity buys — so stabilizing the SMT-LIB model comes first.

- [x] **Seeded `Proofs/Assumptions.lean` from CpcMini's generic version.** It
      is now real rather than a stub: a term is translatable when the semantics
      gives it a type, a command when its arguments do. Nothing in it names a
      rule or an operator, which is why it works for any signature. `Decidable`
      instances added so `Api.lean` can keep deciding them, and both bridge
      lemmas in `ApiChecks.lean` are proven against the real predicates.

      Consequence worth knowing: the verdicts became accurate, so the
      HelloWorld proof now returns `correct` rather than `incomplete`. A
      separate regression proof covers `incomplete` genuinely — a sort
      constructor applied to a sort, which the formalization has no counterpart
      for, the same case Logos uses.
- [ ] **Strengthen `cmdTranslationOk` per rule as proofs are written.** Cpc's
      257-line version names 32 rules because some need more than "the
      arguments translate", and which kind a rule needs is discovered while
      proving it. Logos's roadmap (TODO 1 there) wants that table generated from
      the rule files rather than hand-maintained; worth tracking, since it is
      the only hand-written non-rule file in Logos that mentions a rule.
- [ ] **Track the checker layer as it becomes seedable.** The report\'s TODO 2
      proposes promoting `Checker.lean`, `CheckerState.lean`,
      `RuleSupport/Contract.lean` and a generic `Assumptions.lean` to eoc
      templates, installed once and preserved thereafter — the treatment
      `Proofs/Rules/*.lean` already gets. That is precisely the **L (library)**
      category this template lacks, arriving by the cheaper route. When it
      lands, those four stop being stubs a user writes and become files a
      generated checker inherits.
- [ ] **Take the report\'s advice to start from `CpcMini`.** The worked example
      here is `examples/cpc`, which generates 591 rule stubs and a full
      semantics layer. A minimal specification would exercise the same pipeline
      in seconds. This is the same item as the mini calculus in §6, now with an
      argument for it from the other side.

### What not to chase

`Spec.lean` (180 distinct `UserOp`), `TermCompat.lean` (189), `Translation/`
(179), `Closed/` (174), `Assumptions.lean` (32 rules), the 591-way dispatch in
`Logos.lean`, and `Rules/` itself. These are per-calculus because the calculus
is what they are about.

And keep the economics in view: `Rules/` (279,000 lines, 591 files) plus
`RuleSupport/` (352,727 lines) is **84% of the tree**. Modularizing the core
buys architecture, not volume — it makes a second checker *conceivable*, not
*affordable*. The only lever on the 84% is making the operator vocabulary
itself shared, so that a calculus over the same theories inherits their support
libraries. `RuleSupport/` is already organized by theory, which is the right
axis; that is a much deeper change than the above and should be decided
deliberately rather than drifted into.

### Validating a signature

- [x] **Check the signature contract.** `install/install-<calc>.sh` checks all
      four requirements against the compiler's output *before* installing
      anything, and refuses naming what is missing: that `and` exists, that it
      is `:right-assoc-nil true` (evidenced by the `__eo_nil` arm the attribute
      generates), and that the semantics sends it to `SmtTerm.and`. The checks
      are on the compiler's output rather than the signature text because the
      name an operator compiles to need not be its spelling, and the attribute
      is only visible in what it generates.

      This implements TODO 8 of `~/logos/docs/modularity.md`, and refines it.
      The report lists `:right-assoc-nil true` as a flat requirement; measuring
      it showed the restriction is narrower. Compiling CPC with `and` declared
      as a plain binary operator leaves `__eo_invoke_assume_list`, the
      refutation test and the SMT translation **byte-identical** — the core does
      not use the attribute at all. What changes is that the parser stops
      accepting n-ary `(and a b c)`, which is surface syntax, and that
      `__eo_nil` loses its `and` arm.

      That arm matters only where premise lists are gathered with `and`, which
      is a per-rule declaration: CPC has 11 such call sites, another calculus
      may have none. So the check is conditional — it errors only when the
      generated core calls `__eo_mk_premise_list (Term.UOp UserOp.and)` and no
      nil exists for it. A calculus with binary `and` and no `and`-gathered
      premise lists is accepted, correctly.

## 4c. The calculus profile

High-level facts about a calculus that decide what a checker needs, what it must
prove, and what it can inherit. Implemented as one uniform category: a flag on
`scripts/new-checker.sh`, a line in the generated `install/defs/profile.conf`,
and a re-check at install time where compiled output can settle it.

- [x] **Seven questions, five verified and two declared.** scopes,
      list-premises, datatypes, parser and logos-smt are checked against what
      the compiler emitted; binders and value-ordering are recorded on trust,
      because nothing in the output distinguishes the answers. The installer
      prints declared against detected and names any that disagree.
- [x] **`value-ordering` is declared, not verified — and that is a finding.**
      `SmtValueOrder.lean` is *identical* between `Cpc` and `CpcMini`, so the
      compiler emits the same ordering whatever the signature. The question is
      about the semantics you write, not about what is generated.
- [x] **Corrected: `datatypes` was a vacuous check.** It grepped for
      `DatatypeDecl`, which `plugins/lean_meta/lean_meta_checker_term.lean`
      declares unconditionally — so it could only ever answer `yes`. It is now
      *declared* rather than *derived*, with the reason recorded. `binders` and
      `value-ordering` are declared for the same underlying reason: the
      machinery is template-fixed in eoc.
- [ ] **Datatype machinery is unconditional — now measured, not argued.**
      `examples/hello` declares three constants and one rule, no datatypes and
      no literals beyond `Bool`, and still gets `DatatypeType`, `DtCons`,
      `DtSel`, `DatatypeDecl`, `Numeral`, `Rational` and `Binary`: **370 of its
      2,395 generated lines, 15%, are machinery it cannot use.** The mechanism
      to trim it now exists — see the indexed-operator item above — and is
      simply not pointed here yet.
- [ ] **None of the profile is a feature switch, and datatypes should be.**
      What a generated checker contains is decided by the signature and by eoc;
      only `--no-parser` changes anything. Trimming datatype machinery for a
      calculus without datatypes needs compiler work — about 330 lines of a
      generated package mention datatypes, and the cost is not the lines but the
      translation and type-preservation proofs owed for cases the calculus never
      uses. Written up in [docs/eoc-requests.md](docs/eoc-requests.md) §1.
- [ ] **Make `no` answers do more than document, once eoc can.**
      `binders=no` should point the extra-invariant slot at `True` (per Logos's
      `docs/modularity.md`, that is what `CpcMini` does and it costs nothing),
      and `scopes=no` should mark the step-pop preservation obligations vacuous.
      These two are template-side and do not wait on the compiler.
- [ ] **Ship what `logos-smt=yes` earns.** The digest tells a generated checker
      that its SMT-LIB semantics is Logos's, unmodified. Results Logos proves
      about SMT-LIB itself are then candidates to reuse rather than reprove —
      `TypePreservation/Datatypes.lean` and `Canonical/TypeDefaultBasic.lean`
      are byte-identical across `Cpc` and `CpcMini`, so they are the obvious
      first ones. Not shipped yet: they are stated about a `SmtModel` that
      compilation configures, so whether they transfer has to be tested rather
      than assumed. Advertised in the docs meanwhile.

## 4d. Ethos as a reference checker

- [x] **Build ethos alongside the compiler.** Same source tree, its own CMake
      project. `install/get-eo-compiler.sh --no-ethos` skips it.
- [x] **Cross-check the regression proofs.**
      `scripts/check-with-ethos.sh` asks both checkers the same question, using
      ethos's `--require-proof-of-false`, and compares. Run by
      `scripts/run-ci.sh` as the `ethos` group.
- [x] **Encode the one asymmetry.** Ethos has no SMT-LIB semantics, so it cannot
      distinguish `correct` from `incomplete`. Accepting a proof the generated
      checker calls `incomplete` is agreement, not a disagreement — the script
      knows this, and a checker that reported `incorrect` there would not be
      excused.
- [ ] **Notes for the eoc developer.** [docs/eoc-requests.md](docs/eoc-requests.md)
      collects what a template needs from the compiler, with the evidence for
      each: conditional feature emission, `--calc-name`/`--smt-semantics` on
      `main`, a diagnostic for a premise-list operator with no nil, generated
      `cmdTranslationOk`, seeding the checker layer, and stabilizing the
      SMT-LIB model. Keep it current as things land.
- [ ] **Use ethos on the signature itself, not only on proofs.** It parses and
      type-checks a `.eo` directly, so it could report a malformed signature
      before the compiler is even run — a faster and clearer failure than
      anything downstream.

## 4e. Two verdicts or three

A scaffolding choice, not a fact about the calculus, and a bigger fork than it
looks: it decides whether the soundness theorem has side conditions at all.

`incomplete` exists because `correct___eo_is_refutation` takes
`TranslatableAssumptionList F` and `CmdListTranslationOk pf` as hypotheses. Not
checking them at run time leaves two possibilities: claim `correct` without
establishing them, which is unsound reporting; or **have a theorem with no such
hypotheses**, which holds exactly when `__eo_to_smt` is total — every term the
calculus can express has an SMT-LIB meaning. The second is the coherent
two-verdict design.

What a two-verdict project would drop:

- `Proofs/Assumptions.lean` entirely;
- two of the three checks in `Api.lean`, and `verdict` down to two branches;
- the two side-condition bridge lemmas in `ApiChecks.lean`;
- the hypotheses of `correct___eo_is_refutation`;
- the `incomplete` half of `Diagnostics.lean`, and any regression proof whose
  expected verdict is `incomplete`.

What it keeps, and this is worth being clear about: **the replay that localizes
a failing step**. That answers "where did this proof break", which has nothing
to do with how many verdicts there are — a checker with no semantics still wants
it. Earlier drafts of this roadmap said diagnostics would go entirely; that was
wrong.

- [ ] **Implement `--verdicts 2|3`.** It is a second set of templates rather
      than a flag, since the theorem statement itself changes. Worth doing for
      calculi whose translation is total, where a permanently-unreachable
      `incomplete` is a verdict that can only mislead.

## 4f. Starting from something that works

- [x] **A starter signature.** `--dummy-rule` writes a working one-rule calculus
      instead of a commented stub — signature, semantics, and five regression
      proofs covering every verdict. Builds in ~12s and passes its own tests.
      `examples/hello` is the same as a specification directory.
- [x] **A second calculus, which paid for itself immediately.** Compiling
      anything other than CPC exposed three bugs that CPC could not:
      the installer only worked for a checker named `Logos`; the indexed-op
      detection crashed on a calculus with no indexed operators; and its regex
      matched every line. All three were invisible while CPC was the only test.
- [ ] **Use the starter to settle the open derivability questions.** It is a
      datatype-free, literal-free signature, which is exactly what §4b and
      `docs/eoc-requests.md` §1 need in order to test whether `Term`'s
      constructor list is conditional on the signature. That test was not
      possible before this existed.

## 4g. The calculus-specific seam

- [x] **`Proofs/Checker.lean` reclassified F\*.** It is not calculus-specific:
      in Logos it is byte-identical between `Cpc` (591 rules) and `CpcMini` (5),
      packages differing in rule set, signature *and* required invariants, and
      it names no rule and no `UserOp`. It carries a `sorry` here only because
      upstream maintains it per package rather than seeding it. The template now
      says so rather than presenting it as work.
- [x] **`Proofs/Invariants/Extra.lean` — the seam, ported from Logos.** The four
      slot abbrevs (`checkerExtraInvariant`, `cmdExtraOk`, `CmdListExtraOk`,
      `extraAssumptionListOk`) plus the preservation obligation, all pointed at
      `True`. This is what actually differs between two checkers, and the docs
      now send readers here first. Its coupling to `RuleSupport/Support.lean` —
      a load-bearing invariant needs a matching field in the premise evidence —
      is recorded, since the two are decided together.
- [x] **The front-end theorems, one file each.** `ModelWf.lean` plus
      `Proofs/{TypePreservation,TranslationTypePreservation,NonVacuity,Canonicity}.lean`.
      Each is a leaf importing none of the others, so a `sorry` in one does not
      block the rest — which chaining them did, since the package builds with
      warnings as errors. `--theorems` selects which of the four are written.

      `ModelWf.lean` ships proven, and is the honest illustration of the limit:
      its proofs are the projections of the generated `model_wf`, so a change to
      `smt.eos` breaks them. Only `TranslationTypePreservation` can never be
      inherited — it is about `__eo_to_smt` for the user's operators. The rest
      could arrive proven *while the SMT-LIB semantics is stock*, which is what
      the `logos-smt` profile digest records.

      Closedness and variable-model results are deliberately absent: they are
      conditional on binders and belong with the extra invariant.
- [ ] **`CheckerCore.lean` is nearly F too.** Its differences from `CpcMini`'s
      are simp-lemma lists and one namespace qualifier — drift between two
      hand-maintained copies, not calculus-specific content. Worth confirming
      against upstream, since it would move another file out of the H column.

## 4h. Upstream regression, caught by dev mode

- [ ] **ethosEoc3 tip `af638bb3` emits `native_z_uneg` without defining it.**
      CPC's generated `SmtModel.lean` calls it nine times; nothing in the
      generated tree declares it, so the package does not build. Hello is
      unaffected — it has no arithmetic — which is why a second, smaller
      calculus is worth having.

      `install/get-eo-compiler.sh --pinned` (commit `1c0f95e1`) builds and passes
      all four CI groups, so the escape hatch works as designed. This is exactly
      the risk `DEV_MODE=1` documents: report upstream, and pin until it is
      fixed.

## 5. Build and CI

- [ ] **A build script with a toolchain fallback.** Logos's `scripts/build.sh`
      plus `scripts/lean-toolchain-env.sh` fall back to the host C compiler and
      archiver where Lean's bundled Clang cannot run against the host glibc.
- [x] **Batched, resumable rule builds.** `scripts/build-rules.sh` in a
      generated checker: one rule per Lake invocation by default, `--batch-size`
      to trade memory for speed, resumable through Lake's cache. It builds only
      rules that are actually proven, since a `sorry` cannot build under
      warnings-as-errors and attempting all of them would bury the real
      question — after a regeneration, which existing proofs still hold?
- [ ] **CI groups** (`scripts/run-ci.sh`): build a representative subset of
      proofs rather than all of them, plus the regeneration check.
- [ ] **Proof hygiene** (`scripts/check-proof-hygiene.sh`): reject `sorry`,
      `admit` and `axiom` textually, without building. This is what stops an
      unproven rule landing silently when CI does not build every proof — worth
      having from the very first day there is a proof.
- [ ] **A cut-down calculus.** Logos generates `CpcMini` from the same
      signature with five rules and no parser, for developing the proofs
      against something that builds in seconds. `install-sig.sh --rules` and
      `--mini` are how. Cheap to support and disproportionately useful.
- [x] **Progress reporting.** `scripts/rule-status.sh` counts proven versus
      `sorry` rules and names what is left. Textual and instant, and it counts
      what is in the files rather than what has been built, so a proof counts as
      soon as it is written.
- [ ] **Size reporting**: Logos's `scripts/cpc-loc-summary.py` sizes the
      specification, the checker, the parser and the proof separately, which is
      how the shape of the development stays legible.

## 6. Future work

Tracked, but **overkill for now**. These earn their cost once a checker is
being developed in earnest; before that they are infrastructure for work that
is not happening yet, or polish on work that has not started.

- [x] **A mini calculus alongside the full one.** `--mini` generates
      `<Calculus>Mini` and `install-<calc>.sh --mini` compiles the signature
      into it with `--rules` and no parser. Measured on CPC: **8s against 83s**,
      2,130 lines against 20,350, 5 rule files against 591. The rule subset
      comes from `--mini-rules` or a `mini-rules` file in the specification
      directory. The profile check is skipped for it, since the profile
      describes the calculus and a reduced package is not it.

- [ ] **A native proof format** — Logos's second executable, `logos-native`
      (`MainNative.lean`, `Cpc/Native/`), reading an internal format instead of
      s-expressions.
- [ ] **Regression tests** (`test/regress/`), including proofs that are
      *expected* to come back `incomplete`.
- [ ] **The written specification.** Logos's `docs/smt-model-definitions.tex`
      is where the semantics and the correctness argument are set out in prose,
      with the built PDF committed so it can be read without LaTeX.
- [ ] **Performance.** Logos is explicit that it has not been optimized and is
      significantly slower than unverified checkers.

---

## What is not on this list

Choosing the calculus. That is the user's, and it is the whole reason this
repository exists: `examples/cpc` is one specification, and the point is that
it is replaceable.
