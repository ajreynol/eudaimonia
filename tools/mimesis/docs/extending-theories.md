# Extending CPC theories

Part of the [Eunoia tutorials](tutorials.md).

This tutorial walks through adding a theory symbol or a new theory to cvc5's
CPC signature: declare its vocabulary, connect it to cvc5's proof output, and
check the result. **Both the main and expert paths follow steps 1–4.** If you
are adding to `expert/CpcExpert.eo`, you finish at step 4. That signature does
not go to Logos, so no Logos work is required. If you are adding to `Cpc.eo`,
continue through steps 5–7 to give the addition its semantics and proofs in
Logos, then update cvc5's Logos pin.

We use the existing `int.pow2` operator as a running example. Read its
implementation as a model for your addition; do not add a second copy. When
adding a whole theory, you also need to declare its sorts and values; a
finite-field example illustrates that part. The optional
[worked files](../examples/theories/README.md) exercise these existing
implementations. Your own development does not require Mimesis.

## 1. Choose where the declaration belongs

Start with a complete cvc5 checkout and an Ethos binary. Set their absolute
paths so that the commands below work from any directory:

```bash
CVC5=/absolute/path/to/cvc5
ETHOS=/absolute/path/to/ethos
```

If needed, run `./contrib/get-ethos-checker` from cvc5 to build Ethos at
`deps/bin/ethos`. Keep the complete `proofs/eo/` subtree: the signature files
include each other by relative path.

Choose the main or expert location once. The editing and checking steps are
the same; this choice determines where you put the files and whether you
continue to Logos after step 4. All paths in this table are relative to
`proofs/eo/cpc/`:

| Path | Theory declarations | Entry point |
| --- | --- | --- |
| Main | `theories/<Theory>.eo` | `Cpc.eo` |
| Expert | `expert/theories/<Theory>.eo` | `expert/CpcExpert.eo` |

Use the expert path for experimental vocabulary. Its declarations can be
added while proof-rule support is still incomplete. The contract in
[`CpcExpert.eo`][expert] is that proofs from safe builds or `--safe-options`
must never reference expert symbols or rules. Main additions must have the
Logos support developed in steps 5–7. Being part of SMT-LIB does not decide
placement: `int.pow2` is nonstandard, but belongs to the main signature.

For an existing theory, use its existing declaration file. An experimental
extension of a main theory goes in its expert extension file, such as
`expert/theories/ArithExt.eo`.

For a new theory, create a file in the appropriate directory and include it
from the chosen entry point. For example, a new `MyTheory.eo` uses the same
relative include in either entry point:

```lisp
(include "./theories/MyTheory.eo")
```

An existing rule file may already include the theory file, so first check
whether it is reachable. Expert files can include main files, but main files
must not depend on expert files. At the end of this step, loading your chosen
entry point should reach the file you will edit next.

## 2. Declare the new vocabulary

Write the name and type of each term cvc5 will print. For an operator over
existing types, this can be a single declaration. In `theories/Ints.eo`,
`int.pow2` takes an integer and returns an integer:

```lisp
(declare-const int.pow2 (-> Int Int))
```

Apply the same pattern to your operator. Match its argument order, result
type, indices, and implicit parameters. This declaration gives the term its
syntax and type; its evaluation and proof support come in the next step.

If you are adding a theory with a new sort, declare that sort before its
values and operators. For example, these excerpts from
[`expert/theories/FiniteFields.eo`][finite-fields] describe a field indexed
by an integer and addition within that field:

```lisp
(declare-const FiniteField (-> Int Type))

(declare-parameterized-const ff.value ((p Int)) (-> Int (FiniteField p)))

(declare-parameterized-const ff.add ((p Int :implicit))
    (-> (FiniteField p) (FiniteField p) (FiniteField p))
    :right-assoc-nil (ff.value p 0))
```

The file includes `../../theories/Arith.eo` for its integer vocabulary.
`(FiniteField 7)` is a type, and `(ff.value 7 0)` is its zero value.
`ff.add` infers the field parameter from its arguments, which must belong to
the same field. Its list representation ends in that field's zero value.
CPC represents finite-field constants with `ff.value`, rather than native
finite-field literal syntax.

For your declarations, identify which restrictions the types enforce and
which need separate handling. For example, `FiniteField` above accepts an
integer parameter; the declaration itself does not check primality. Keep
these distinctions explicit when implementing the checking rules and, on the
main path, the semantics.

## 3. Connect the declarations to cvc5's proof output

Now check that cvc5 prints the names and arguments you just declared. For
`int.pow2`, the SMT parser and printer associate `Kind::POW2` with the name
`int.pow2`. Other terms need CPC-specific conversion. Inspect the relevant
parts of this chain and update them where necessary:

| cvc5 source | What to check |
| --- | --- |
| `src/parser/smt2/smt2_state.cpp`, `src/printer/smt2/smt2_printer.cpp` | The operator's input and printed names |
| `src/proof/eo/eo_node_converter.cpp` | CPC term encoding, such as converting a finite-field constant to `ff.value` with size and value arguments |
| `src/proof/eo/eo_dependent_type_converter.cpp` | Indexed types, such as the field size in `FiniteField` |
| `src/proof/eo/eo_list_node_converter.cpp` | Variadic applications and their terminators |
| `src/proof/eo/eo_printer.cpp` | The names and arguments of proof rules used on these terms |

Next, follow the proof steps cvc5 emits for the operator. Existing rules may
need additional cases even when no new rule is introduced. For `int.pow2`,
the `evaluate` rule uses `$run_evaluate` in `Cpc.eo`, which contains:

```lisp
(($run_evaluate (int.pow2 i1)) ($arith_eval_int_pow_2 ($run_evaluate i1)))
```

This connects the declared operator to the program that computes its result.
For your addition, extend the evaluation or normalization programs it needs.
If you add theory rules, put them in `rules/<Theory>.eo` or
`expert/rules/<Theory>.eo` alongside the chosen theory directory. Include the
theory from the rule file using `../theories/<Theory>.eo`, and make the rule
file reachable from the same entry point chosen in step 1.

An expert declaration can land before those proof rules are complete; add
and test rule support as it becomes available. For a new main-signature rule,
the [CPC rule tutorial](adding-a-cpc-rule.md) explains its declaration and
soundness proof in detail.

Finally, check that the feature's availability in cvc5 agrees with its
placement. Expert vocabulary must stay out of safe-mode proofs. For example,
finite fields have an expert `ff` option in `src/options/ff_options.toml`;
`src/smt/set_defaults.cpp` disables it under safe options, and
`src/smt/illegal_checker.cpp` rejects the disabled theory's kinds. Follow the
corresponding mechanism for your feature. The next step checks this integration.

## 4. Check the addition with Ethos

First write a small CPC file that exercises your addition without including
either signature in the file itself. For `int.pow2`, this complete refutation
uses the evaluation support from step 3:

```lisp
(assume @neq (not (= (int.pow2 3) 8)))
(step @eval (= (int.pow2 3) 8) :rule evaluate :args ((int.pow2 3)))
(step @false false :rule contra :premises (@eval @neq))
```

Save your test and set its absolute path:

```bash
PROOF=/absolute/path/to/extension.cpc
```

Run it with the signature you selected in step 1. For the main path, including
the `int.pow2` example, load only `Cpc.eo`:

```bash
"$ETHOS" --include="$CVC5/proofs/eo/cpc/Cpc.eo" \
  --require-proof-of-false "$PROOF"
```

For the expert path, load `Cpc.eo` and `CpcExpert.eo` together:

```bash
"$ETHOS" --include="$CVC5/proofs/eo/cpc/Cpc.eo" \
  --include="$CVC5/proofs/eo/cpc/expert/CpcExpert.eo" \
  --require-proof-of-false "$PROOF"
```

A valid refutation must print `correct`. If you have only added declarations
so far, use a file with well-typed declarations and assumptions and omit
`--require-proof-of-false`; you do not need to implement proof rules to test
that the terms typecheck.

Then make an invalid application and check that it fails for the intended
reason. For `int.pow2`, `(int.pow2 true)` must fail type checking. For
`ff.add`, mixing `(FiniteField 7)` and `(FiniteField 11)` must fail. Test any
new rule's invalid applications as well. An expert term must also fail to
load with only `Cpc.eo`, because its declaration is unavailable there. The
[five worked checks](../examples/theories/README.md) demonstrate these cases.

Finally, exercise the feature in your changed cvc5 using
`--proof-format-mode=cpc --proof-granularity=dsl-rewrite --dump-proofs`.
Inspect the emitted terms and rule applications, and check the proof with
Ethos. Remove the leading `unsat` and outer proof-list delimiters before
passing the CPC commands to the checker. Record any remaining `trust` steps
as incomplete proof support.

For safe-mode support, also test `--safe-options` and a build configured with
`./configure.sh safe`. Their proofs must check with `Cpc.eo` alone; an
expert-only input should be rejected by safe cvc5 itself. Use the explicit
includes above for this check: the `cpc_gen.sh` helper installed by
`contrib/get-ethos-checker` includes both signatures by default.

**The expert path ends here.** Once the declarations and applicable CPC checks
are in place, your expert addition is ready for review, even if proof-rule
support is still incomplete. `CpcExpert.eo` is not compiled into Logos, so
there is no Logos checkout, semantics, Lean proof, regeneration, or pin update
to do. Continue below only for changes to `Cpc.eo` or its included files.

## 5. Give the main addition its meaning in Logos

The CPC declaration now accepts the intended terms. Next, tell Logos what
those terms mean. Open `install/defs/Cpc.eos` in your Logos development
checkout. This file translates CPC terms and types into the semantic model.
For `int.pow2`, its entry is:

```lisp
(define-symbol int.pow2 (x))
```

This selects the target operator with the same name. Use this form when the
target already defines your operation. Otherwise, write an explicit `:term`
translation into existing target operations, or extend the target semantics.
A new sort also needs a `:type` translation. Keep CPC translations in this
Logos file; changing the compiler's `development-cpc.eos` alone does not
update them.

The target semantics lives in `tools/eoc/semantics/smt.eos` in Logos's pinned
Ethos compiler. If your theory needs a new semantic domain, define its valid
sorts, values, and the typing and evaluation of its operations there. Identify
the properties the model and translation proofs will need, including existence
of the required values and models; you will prove them in step 6. A finite-field
declaration, for example, would need an actual finite-field interpretation;
mapping it to an uninterpreted sort would not provide that meaning.

When changing the target semantics or compiler, land those changes in Ethos
and update Logos's compiler pin in `install/get-eo-compiler.sh`. The
[installer documentation][install] describes local overrides for development;
the final generation must use the pinned sources without a private override.

## 6. Regenerate Logos and complete the proofs

With the declarations and semantics in place, compile your edited main
signature in the Logos checkout:

```bash
LOGOS=/absolute/path/to/logos
cd "$LOGOS"
install/get-eo-compiler.sh
install/install-cpc.sh --all "$CVC5/proofs/eo/cpc/Cpc.eo"
scripts/build.sh Cpc CpcMini logos
```

`--all` updates both `Cpc` and `CpcMini`. Review the generated term constructors
and parser, the translations in `Cpc/Spec.lean`, and the affected model
modules. Keep `install/defs/Cpc.cached.eo`, which records the input signature,
with the generated changes. Fix mistakes in their source declarations or
semantics and regenerate.

Now complete the affected model, translation, and rule proofs. New rules get
proof files containing `sorry`; existing rule proof files are preserved and
may need repair. Build affected proofs explicitly. For the running example,
the evaluation rule's proof target is:

```bash
scripts/build.sh Cpc.Proofs.Rules.Evaluate
```

Choose the targets your own change affects. Building the executable alone
does not build all soundness proofs. Follow the
[CPC validation procedure](adding-a-cpc-rule.md#6-validate-the-logos-change)
for proof hygiene, CI, and broader proof builds when a theory change affects
other rules. Record which proof targets you checked.

Run your include-free proof from step 4 through the rebuilt Logos executable:

```bash
./.lake/build/bin/logos "$PROOF"
```

It must report `correct`; test the invalid applications too. An `incomplete`
result means the required support is not finished. Commit the semantic sources,
cached signature, generated modules, completed proofs, and regressions together.

## 7. Land Logos and update cvc5's pin

Merge the matching Logos change and obtain a successful Logos `CI` run at the
exact commit you will pin. In cvc5, set `LOGOS_VERSION` in
`contrib/get-logos-checker` to that full commit hash, then run:

```bash
cd "$CVC5"
./contrib/check-logos-compilation
```

This must confirm that the main signature matches the pinned Logos generation.
It does not build the Lean proofs; that work belongs to step 6. Install the
newly pinned checker with `./contrib/get-logos-checker` and check the regression
proof emitted by your changed cvc5. The
[CPC landing procedure](adding-a-cpc-rule.md#7-land-logos-then-update-cvc5s-pin)
details the CI requirement and failure statuses.

The main addition is ready when cvc5's declaration and proof output agree with
that tested Logos revision. If you later promote an expert feature, move its
declarations and rules into the main include chain, remove obsolete expert
copies, update the printer's rule selection, and follow these same seven steps.

## Sources and validation

The worked examples use cvc5 `2900761a7c2e2c0e99e2cf669cffa3740ea9a138`,
the merged [PR #12891][pr]. All five fixture checks passed on 2026-09-17
with Ethos built from cvc5's checker pin,
`8dc85c4db8d6cc612f02dc3bb627331732605eff`. Negative cases were checked for
the expected diagnostics.

The cvc5 integration and Logos steps are a source-reviewed procedure for your
extension. No solver build, new theory implementation, Logos regeneration, or
Lean proof was performed for these fixtures. Logos sources were reviewed at
cvc5's pin, `664c35d6e188a62d5b5dac8fb403d19b9e0f4baa`, whose compiler pin
is `406b5499f3c83f2a114113107be251f8e58b2d85`. The finite-field example checks
CPC declarations and existing expert proof support; it does not implement
finite-field semantics in Logos.

[pr]: https://github.com/cvc5/cvc5/pull/12891
[expert]: https://github.com/cvc5/cvc5/blob/2900761a7c2e2c0e99e2cf669cffa3740ea9a138/proofs/eo/cpc/expert/CpcExpert.eo
[finite-fields]: https://github.com/cvc5/cvc5/blob/2900761a7c2e2c0e99e2cf669cffa3740ea9a138/proofs/eo/cpc/expert/theories/FiniteFields.eo
[install]: https://github.com/cvc5/logos/blob/664c35d6e188a62d5b5dac8fb403d19b9e0f4baa/install/README.md
