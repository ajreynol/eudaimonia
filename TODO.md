# Roadmap

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

- [ ] **Fetch and pin the Eunoia compiler.** `ethos-eoc` is built from the
      `plugins/` project of an [Ethos](https://github.com/cvc5/ethos) checkout
      and reads its templates out of that tree, so the tree is a dependency and
      not just the binary. Logos pins the commit in `ETHOS_VERSION` in
      `install/get-eo-compiler.sh` and records what it built in
      `install/deps/eoc-env.sh`, so a compile only has to be told the signature.
      Pinning by commit is deliberate: what the compiler emits then changes only
      when someone moves the pin.
- [ ] **Run the compiler and install what it publishes.** Logos's
      `install/install-sig.sh` drives `tools/eoc/driver.py lean` with
      `--semantics`, `--smt-semantics` and `--calc-name`, then places the
      published tree into the package. The three files in `examples/cpc` are
      exactly the inputs it takes.
- [ ] **Preserve per-rule proofs across a regeneration.** The single most
      important behaviour of the installer: signature-wide modules are
      overwritten, and files under `Proofs/Rules/` are kept, because the proof
      lives in the same file as the generated statement. See
      `<Calculus>/Proofs/Rules/README.md` in a generated project.
- [ ] **Fix `--force`.** It currently deletes the project directory outright,
      which destroys hand-written Lean. Regeneration must become the
      overwrite-some-preserve-others operation above.
- [ ] **Cache the signature.** Logos keeps `install/defs/Cpc.cached.eo`: the
      signature it compiled, flattened to one self-contained file, so a
      regeneration needs nothing outside the repository. `examples/cpc/Cpc.eo`
      is such a file.
- [ ] **`--check` mode.** Install into a throwaway copy and diff, exiting
      non-zero if generated code has drifted from the signature it came from.
      Logos does the real install and compares, so the check cannot drift from
      the install it checks.

## 2. Reading proofs

- [ ] **A signature-independent parser library.** Logos's `Logos/Sexp.lean`
      (an s-expression reader, ~156 lines) and `Logos/Parser.lean` (a
      table-driven proof parser, ~913 lines) are genuinely calculus-agnostic:
      the generated `Cpc/Parser.lean` is only the operator table that plugs into
      them. This is the largest piece of Logos that could be reused as-is, and
      until it exists the generated `Parser.lean` has nothing to plug into.
- [ ] **Decide how it is delivered** — vendored into each generated project, or
      a Lake dependency the generated `lakefile.toml` requires. A dependency
      keeps generated projects thin and lets fixes propagate; vendoring keeps
      them self-contained, which is what they are today.
- [ ] **Document the accepted syntax**, as Logos does in `docs/parser.md`.

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

## 5. Build and CI

- [ ] **A build script with a toolchain fallback.** Logos's `scripts/build.sh`
      plus `scripts/lean-toolchain-env.sh` fall back to the host C compiler and
      archiver where Lean's bundled Clang cannot run against the host glibc.
- [ ] **Batched, resumable rule builds** (`scripts/build-all-cpc-rules.sh`).
      A full proof build takes **over two hours** and can exhaust memory, so it
      builds one target at a time by default and relies on Lake's cache to
      resume.
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
- [ ] **Reporting**: `scripts/cpc-loc-summary.py` sizes the specification, the
      checker, the parser and the proof separately, which is how the shape of
      the development stays legible.

## 6. Later

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
