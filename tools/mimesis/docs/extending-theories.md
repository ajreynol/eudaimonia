# Extending CPC theories

Part of the [Eunoia tutorials](tutorials.md).

Start here when adding a theory symbol or a new theory to **cvc5's CPC proof
format**. The job spans the Eunoia declaration, the terms and rules cvc5 prints,
and, for the main signature, their interpretation and proofs in Logos. For
experimental features, it also includes keeping their vocabulary in
`expert/CpcExpert.eo` and out of proofs produced with safe options.

We follow two existing implementations: `int.pow2`, an operator in the main
integer theory, and finite fields, an expert theory. They are models to read,
not declarations to add again. The [worked proofs](../examples/theories/README.md)
run against cvc5's actual signatures. Mimesis supplies optional advice and
fixtures; no cvc5 or Logos development step requires a Mimesis checkout.

## 1. Choose the main or expert signature

Make this decision before choosing a file. The contract in
[`expert/CpcExpert.eo`][expert] is concrete: proofs emitted by safe builds or
with `--safe-options` must never reference symbols or rules from `expert/`.
Expert declarations cover experimental theory symbols even when their proof
rules are still incomplete.

Paths in this table are relative to cvc5's `proofs/eo/cpc/`:

| Change | Declarations and rules | Entry point |
| --- | --- | --- |
| Extend a main theory | `theories/<Theory>.eo`, `rules/<Theory>.eo` and relevant `programs/` files | Reachable through `Cpc.eo` |
| Add an expert operator to an existing theory | Its extension under `expert/theories/` and `expert/rules/`, such as `ArithExt.eo` | Reachable through `expert/CpcExpert.eo` |
| Add an experimental theory | New `expert/theories/<Theory>.eo` and, as rules become available, `expert/rules/<Theory>.eo` | Add includes to `expert/CpcExpert.eo` |
| Add a theory to the main signature | New `theories/<Theory>.eo` and `rules/<Theory>.eo`, with Logos support | Add includes to `Cpc.eo` |

Follow the existing include chain; a rule file can already include the theory
file it needs. Expert files can depend on main declarations. Keep the reverse
dependency out of the main signature, including through shared programs.
Do not include `CpcExpert.eo` from `Cpc.eo` to make an undeclared symbol work.

SMT-LIB standardization does not determine placement. For example, `int.pow2`
is documented as nonstandard but lives in the main signature; arithmetic's
expert extensions live in `expert/theories/ArithExt.eo`.

Use complete cvc5 and Logos working trees and absolute paths:

```bash
CVC5=/absolute/path/to/cvc5
LOGOS=/absolute/path/to/logos
ETHOS=/absolute/path/to/ethos
```

If needed, `./contrib/get-ethos-checker` from the cvc5 checkout builds Ethos at
`deps/bin/ethos`. Keep all of `proofs/eo/`: the relative includes are part of
the signature. See the [CPC rule tutorial](adding-a-cpc-rule.md#1-set-up-the-two-working-trees)
for setup and prerequisites.

## 2. Extend an existing theory: follow `int.pow2`

The declaration in `theories/Ints.eo` is small:

```lisp
(declare-const int.pow2 (-> Int Int))
```

It says that the operator takes an integer and returns an integer. Its
evaluation support is separate. In `Cpc.eo`, `$run_evaluate` dispatches to
the arithmetic evaluation program:

```lisp
(($run_evaluate (int.pow2 i1)) ($arith_eval_int_pow_2 ($run_evaluate i1)))
```

That lets the existing `evaluate` rule prove a concrete result:

```lisp
(assume @neq (not (= (int.pow2 3) 8)))
(step @eval (= (int.pow2 3) 8) :rule evaluate :args ((int.pow2 3)))
(step @false false :rule contra :premises (@eval @neq))
```

For your operator, specify the arity, types, indices, and any implicit
parameters, then trace the proof steps cvc5 uses on it. Check whether existing
rules for evaluation, normalization, congruence, or distinct values need new
cases. Adding a declaration alone does not supply those cases. When a new
rule is needed, use the [CPC rule workflow](adding-a-cpc-rule.md).

For an expert extension to an existing theory, make these additions in the
expert files and programs reached from `CpcExpert.eo`. The fact that the base
theory is supported by the main signature does not make every extension safe.

## 3. Add a theory: follow finite fields in `CpcExpert.eo`

The [finite-field theory file][finite-fields] starts by including arithmetic
for its integer parameters. These are excerpts from its declarations:

```lisp
(include "../../theories/Arith.eo")

(declare-const FiniteField (-> Int Type))

(declare-parameterized-const ff.value ((p Int)) (-> Int (FiniteField p)))

(declare-parameterized-const ff.add ((p Int :implicit))
    (-> (FiniteField p) (FiniteField p) (FiniteField p))
    :right-assoc-nil (ff.value p 0))
```

Here `(FiniteField 7)` is a type and `(ff.value 7 0)` is its zero value.
`ff.add` infers the field parameter from its arguments, which must have the
same type. Its list representation has a zero terminator. Those details must
agree with cvc5's conversion of sorts, constants, and variadic applications.
CPC uses `ff.value` applications; this file explicitly does not support native
finite-field literal syntax.

The type constructor above accepts an integer parameter; it does not itself
check primality. For your theory, explicitly identify where valid indices,
value ranges, and other mathematical restrictions are enforced. A producer
restriction is not automatically a signature check or a semantic invariant.

`expert/CpcExpert.eo` makes these declarations available with:

```lisp
(include "./theories/FiniteFields.eo")
```

For a new experimental theory, create `expert/theories/<Theory>.eo` and add
`(include "./theories/<Theory>.eo")` to `expert/CpcExpert.eo`. This is
worthwhile even before all theory rules are implemented: CPC needs a
declaration for each experimental symbol that cvc5 prints. As rules become
available, put them in `expert/rules/<Theory>.eo`, include their theory file
using `../theories/<Theory>.eo`, and include that rule file from
`CpcExpert.eo`. Check that the entire include chain loads.

Finite fields also illustrate a change to an existing generic rule.
`CpcExpert.eo` extends normalization through
`$get_aci_normal_form_expert` and `aci_norm_expert`; cvc5's EO printer chooses
that rule for `ProofRule::ACI_NORM` on finite-field addition and multiplication.
The [expert proof fixture](../examples/theories/test/finite-fields.cpc) uses it
to prove `(= (ff.add x y) (ff.add y x))` for `x` and `y` in `(FiniteField 7)`.

## 4. Make cvc5 emit the declared vocabulary

Trace a term from the solver to the printed proof. These are the places to
inspect, with existing finite-field handling as a guide; a new operator will
not necessarily need changes in every file:

| cvc5 source | What must agree with the signature |
| --- | --- |
| `src/parser/smt2/smt2_state.cpp`, `src/printer/smt2/smt2_printer.cpp` | Input and printed names, including ordinary theory operators |
| `src/proof/eo/eo_node_converter.cpp` | CPC-specific term encoding; `CONST_FINITE_FIELD` becomes `ff.value` with field size and value arguments |
| `src/proof/eo/eo_dependent_type_converter.cpp` | Indexed sorts; `FINITE_FIELD_TYPE` maps to `FiniteField` |
| `src/proof/eo/eo_list_node_converter.cpp` | Variadic operators and their list representation; includes finite-field addition and multiplication |
| `src/proof/eo/eo_printer.cpp` | Rule names and arguments; selects `aci_norm_expert` for the finite-field normalization cases |

The solver still needs its normal kind, type-checking, rewriting, and proof
production support. Inspect an actual generated proof to check the connection
to CPC; a hand-written proof cannot establish that the printer emits the same
terms.

**Enforce the expert restriction in cvc5 too.** A directory name does not
disable a solver feature. For finite fields, `ff` is an expert option in
`src/options/ff_options.toml`; `src/smt/set_defaults.cpp` disables it under
safe options, and `src/smt/illegal_checker.cpp` rejects the disabled theory's
kinds. Follow the appropriate existing path for your theory or extension.
Test `--safe-options` and a build configured with `./configure.sh safe`, as
well as the unrestricted feature.

## 5. Check the main and expert signatures separately

Save the `int.pow2` refutation above as a CPC file, or use the optional
fixtures here. `EXAMPLES` below only locates those fixtures:

```bash
EXAMPLES=/absolute/path/to/eudaimonia/tools/mimesis/examples/theories

"$ETHOS" --include="$CVC5/proofs/eo/cpc/Cpc.eo" --require-proof-of-false \
  "$EXAMPLES/test/int-pow2.cpc"

"$ETHOS" --include="$CVC5/proofs/eo/cpc/Cpc.eo" \
  --include="$CVC5/proofs/eo/cpc/expert/CpcExpert.eo" --require-proof-of-false \
  "$EXAMPLES/test/finite-fields.cpc"

python3 "$EXAMPLES/check.py" "$ETHOS" "$CVC5"
```

Both positive runs must print `correct`. The script checks five outcomes:

| Proof | Includes | Expected result |
| --- | --- | --- |
| `int-pow2.cpc` | Main | Complete refutation accepted |
| `int-pow2-wrong-type.cpc` | Main | Boolean argument to `int.pow2` rejected by type checking |
| `finite-fields.cpc` | Main | Rejected because `FiniteField` is undeclared |
| `finite-fields.cpc` | Main and expert | Complete refutation accepted |
| `finite-fields-wrong-type.cpc` | Main and expert | Addition mixing fields of sizes 7 and 11 rejected by type checking |

Adapt this coverage to your extension: well-typed terms and valid steps,
malformed indices and argument types, and invalid rule applications. For expert
features, also check that their vocabulary is unavailable with only `Cpc.eo`.

Produce a regression from the changed cvc5 using
`--proof-format-mode=cpc --proof-granularity=dsl-rewrite --dump-proofs`.
Check that it exercises the new vocabulary and intended rules, and identify
any remaining `trust` steps. Pass the CPC commands inside the dump's outer
proof-list delimiters to Ethos, omitting the leading `unsat` result.

At the reviewed revision, the `cpc_gen.sh` helper installed by
`contrib/get-ethos-checker` inserts **both** signature includes. For a main-only
test, use an include-free proof with the explicit `Cpc.eo` command above.
Passing the helper's default check does not establish that the proof can be
checked without expert declarations. Check proofs from supported safe-mode
inputs this way; an expert-only input should be rejected by safe cvc5 itself.

## 6. Extend Logos for changes to the main signature

The normal Logos compilation starts at `Cpc.eo`, which excludes the expert
signature. A change confined to `CpcExpert.eo` and its private includes may
therefore leave the compiled Logos package and cvc5's Logos pin unchanged.
Run the cvc5 regeneration comparison to confirm this; shared main files can
still affect Logos. Do not treat an expert declaration as implemented Logos
semantics or pass `CpcExpert.eo` as a replacement for `Cpc.eo` to the installer.

For a new main symbol or theory, or an expert feature being promoted to the
main signature, **the Logos update is part of the implementation**:

| Source | Required work |
| --- | --- |
| Logos `install/defs/Cpc.eos` | Translate the new CPC terms and types into the model |
| Logos's pinned Ethos `tools/eoc/semantics/smt.eos` | Supply any missing semantic sorts, values, typing, and evaluation |
| Logos's handwritten model, translation, and rule proofs | Establish the properties of those additions and repair affected proofs |

For `int.pow2`, the [CPC semantics][cpc-semantics] contains:

```lisp
(define-symbol int.pow2 (x))
```

This uses the target operator with the same name. Such an entry works only
because the target already supplies that meaning. For your symbol, use an
existing target operator or an explicit `:term` translation when that captures
the intended operation. New sorts need a `:type` translation as well. Editing
the compiler's `development-cpc.eos` alone does not update the authoritative
`install/defs/Cpc.eos` in Logos.

For a whole new theory, first determine whether the target model can represent
it faithfully. A finite-field declaration, for example, would not acquire
finite-field semantics just by being translated to an uninterpreted sort.
A new domain needs valid type parameters, a representation of values, typing
and evaluation for each operation, and the corresponding model and translation
proofs. Establish that the required values and models exist; rule proofs over
an impossible model would be vacuous. The finite-field fixture here does not
implement or verify that domain in Logos.

Keep model changes in the semantic sources and regenerate the Lean. If the
target semantics or compiler changes, land it in Ethos and update Logos's
compiler pin in `install/get-eo-compiler.sh`. The final generation must work
with that pin, without a private `--smt-semantics` override. See the
[Logos installer documentation][install] for local development overrides.

Then regenerate from the edited main signature:

```bash
cd "$LOGOS"
install/get-eo-compiler.sh
install/install-cpc.sh --all "$CVC5/proofs/eo/cpc/Cpc.eo"
scripts/build.sh Cpc CpcMini logos
```

Review the term constructors and parser, the translations in `Cpc/Spec.lean`,
and the generated `SmtModel`, `SmtEval`, and related modules. Keep the refreshed
`install/defs/Cpc.cached.eo` with the change. Existing rule proof files are
preserved, so successful regeneration does not mean those proofs still compile.
Build the affected model and translation proofs and every affected rule proof,
and discharge any new rule's generated `sorry`.

Follow [the CPC rule tutorial's validation steps](adding-a-cpc-rule.md#6-validate-the-logos-change),
including proof hygiene and explicit proof builds: the reviewed Logos CI builds
only a subset of the rule proofs. Exercise the new main vocabulary with the
rebuilt Logos executable using include-free CPC proofs. An `incomplete` result
does not establish support for the theory.

Land the matching Logos change, obtain passing Logos CI at the exact commit,
and set cvc5's `LOGOS_VERSION` in `contrib/get-logos-checker` to it. Then run:

```bash
cd "$CVC5"
./contrib/check-logos-compilation
```

This compares the main signature against the pinned Logos generation. It does
not build all the Lean proofs. See the
[landing procedure](adding-a-cpc-rule.md#7-land-logos-then-update-cvc5s-pin)
for the exit statuses, exact-commit CI requirement, and final regression check.

## 7. When promoting an expert feature

Move its declarations and supported rules into the main include chain, remove
obsolete expert copies, and update any printer dispatch that selected an
expert rule name. Check the full dependency chain: a promoted rule must not
still require an expert-only symbol or helper.

Complete the Logos work above before enabling the feature under safe options.
Update cvc5's feature guards as appropriate and add main-only Ethos, Logos,
and safe-cvc5 regressions. For finite fields this would be a larger development
than moving `FiniteFields.eo`: it includes the semantic domain and proofs.

## Sources and validation

On 2026-09-17, all five fixture checks passed against cvc5
`2900761a7c2e2c0e99e2cf669cffa3740ea9a138` (the merged
[PR #12891][pr]), using Ethos built from cvc5's checker pin,
`8dc85c4db8d6cc612f02dc3bb627331732605eff`. Negative cases were checked for
the expected diagnostics, not merely a nonzero exit.

The cvc5 integration and Logos commands are a source-reviewed procedure for
the reader's extension. No solver build, new theory implementation, Logos
regeneration, or Lean proof was performed for these fixtures. Logos sources
were reviewed at cvc5's pin, `664c35d6e188a62d5b5dac8fb403d19b9e0f4baa`;
its compiler pin is `406b5499f3c83f2a114113107be251f8e58b2d85`, separate from
the Ethos checker revision used above. No project pins were changed.

[pr]: https://github.com/cvc5/cvc5/pull/12891
[expert]: https://github.com/cvc5/cvc5/blob/2900761a7c2e2c0e99e2cf669cffa3740ea9a138/proofs/eo/cpc/expert/CpcExpert.eo
[finite-fields]: https://github.com/cvc5/cvc5/blob/2900761a7c2e2c0e99e2cf669cffa3740ea9a138/proofs/eo/cpc/expert/theories/FiniteFields.eo
[cpc-semantics]: https://github.com/cvc5/logos/blob/664c35d6e188a62d5b5dac8fb403d19b9e0f4baa/install/defs/Cpc.eos
[install]: https://github.com/cvc5/logos/blob/664c35d6e188a62d5b5dac8fb403d19b9e0f4baa/install/README.md
