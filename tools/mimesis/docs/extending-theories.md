# Extending theories

Part of the [Eunoia tutorials](tutorials.md).

Adding a theory symbol—or a whole theory—means deciding both which terms the
signature accepts and what those terms mean. Eunoia declarations describe the
syntax and typing. A separate semantics connects them to the model used by
Logos. Proof rules then need to be justified against that meaning.

This tutorial adds `nand` and `nor` as a small Boolean-gate theory. The
[worked files](../examples/theories/README.md) generate a checker and include
Lean lemmas checking the translations and Boolean values. The example reuses the
existing Boolean domain; the [new-domain section](#6-when-the-theory-needs-a-new-domain)
explains the additional work for a theory with new sorts or values. That larger
extension is a development procedure, not a completed implementation here.

Mimesis is optional reading. Use these example files if helpful; your own
signature, compiler, and Logos development need no Mimesis dependency.

## 1. Decide whether the model already has the meaning

Before adding a declaration, state the intended types and interpretation.
For this example, both gates take two Boolean arguments:

| `p` | `q` | `nand p q` | `nor p q` |
| --- | --- | --- | --- |
| false | false | true | true |
| false | true | true | false |
| true | false | true | false |
| true | true | false | false |

NAND means `not (and p q)`, and NOR means `not (or p q)`. The target SMT
semantics already has all three operators. We can translate into those terms
without adding a model type, a value constructor, or an evaluator.

Distinguish the three inputs to the compiler:

| Input | Its job | In this example |
| --- | --- | --- |
| `.eo` signature and its includes | Declare term syntax, types, and proof-checking rules | `gates.eo`, `theories/BooleanGates.eo`, `rules/BooleanGates.eo` |
| Signature `.eos` | Translate input terms and types into the semantic model | `Gates.eos` |
| Target `smt.eos` | Define the model's types, values, typing, and evaluation | The unchanged file supplied with the pinned compiler |

For CPC, the signature lives under cvc5's `proofs/eo/cpc/`, its authoritative
translation is Logos's `install/defs/Cpc.eos`, and the target `smt.eos` comes
from Logos's pinned Ethos compiler. The compiler's `development-cpc.eos` is a
development fixture; editing it alone does not update Logos's semantics.
See the [semantics reference][semantics] and [Logos installer documentation][install].

## 2. Add the vocabulary

In [`theories/BooleanGates.eo`](../examples/theories/theories/BooleanGates.eo),
the additions are:

```lisp
(declare-const nand (-> Bool Bool Bool))
(declare-const nor (-> Bool Bool Bool))
```

These are exactly binary. Do not copy an associativity attribute from a nearby
declaration without checking the algebra: NAND and NOR are not associative.
The same file declares `and`, `or`, and `not`, the vocabulary needed to express
their expansions.

The root [`gates.eo`](../examples/theories/gates.eo) includes the theory and its
rules separately:

```lisp
(include "theories/BooleanGates.eo")
(include "rules/BooleanGates.eo")
```

For one new CPC operator, add it to the existing theory file. For a new theory,
follow that layout: its declarations under `theories/`, its checking rules
under `rules/`, and include them from the calculus's entry point. Keep relative
includes intact when copying or compiling the signature.

If your operator has indices or type parameters, specify which are explicit,
implicit, or computed in its Eunoia type. Check malformed applications as well
as ordinary ones. A width or index restriction that the producer happens to
respect may still need a check in the signature or semantic translation.

## 3. Give the vocabulary its meaning

The new entries in [`Gates.eos`](../examples/theories/Gates.eos) are:

```lisp
(section "Boolean gates")

(define-symbol nand (x y)
  :term (not (and x y)))

(define-symbol nor (x y)
  :term (not (or x y)))
```

Here `:term` gives a translation into SMT terms. The parameters `x` and `y`
stand for the translated arguments; `not`, `and`, and `or` name target
operators. The generated `__eo_to_smt` therefore maps a NAND application to
`SmtTerm.not (SmtTerm.and … …)`.

The other entries, such as `(define-symbol not (x))`, use the same-name
translation convention. That abbreviation works when the target already has
the symbol. It does not invent the meaning of an arbitrary new name. Also,
writing an Eunoia `program` to compute a rule's result does not provide that
result's model interpretation; those are separate jobs.

`section` organizes the semantics configuration and closes its current block;
it does not define a namespace or a new semantic domain. The theory here is
the vocabulary, translations, and rules taken together.

**Check the representation as well as the formula.** Our Eunoia `and` has
`:right-assoc-nil true`, so `(and p q)` contains a final `true`; `or` similarly
ends in `false`. The NAND translation above uses the target's binary `and`
directly. Those terms agree on Boolean values, but their syntax is different.
The worked Lean lemmas check that agreement too. This distinction matters when
writing the eventual rule proof.

## 4. Add rules and exercise the new terms

The theory's NAND elimination rule is:

```lisp
(declare-rule nand-elim ((p Bool) (q Bool))
  :premises ((nand p q))
  :conclusion (not (and p q))
)
```

The NOR rule is analogous. A contradiction rule lets us make complete proof
tests. For example, [`test/nand.cpc`](../examples/theories/test/nand.cpc)
assumes `(nand p q)` and `(and p q)`, expands the gate, and derives `false`.

The tests also include an integer passed to NAND and an attempted refutation
that replaces NAND's `not-and` conclusion with `not-or`. The latter assumptions
are satisfiable with `p = true`, `q = false`; rejection must come from an
invalid proof step, not just a missing final contradiction.

Run the examples through both Ethos and the generated checker. Ethos reads
the signature directly and tests its syntax and checking behavior. The
generated checker also checks whether terms lie within the supplied semantic
translation. Agreement on these examples is useful evidence, but the new rule
still has a universal soundness obligation.

## 5. Compile and inspect the result

The following is an optional Eudaimonia walkthrough for the supplied example.
Run from an Eudaimonia checkout; generated files go to a fresh temporary
directory. `EXAMPLE` only locates the tutorial's input files.

```bash
EUDAIMONIA="$PWD"
EXAMPLE="$EUDAIMONIA/tools/mimesis/examples/theories"
WORK=$(mktemp -d)

scripts/new-checker.sh --checker TheoryDemo --calculus Gates \
  --signature "$EXAMPLE/gates.eo" --semantics "$EXAMPLE/Gates.eos" \
  --smt-semantics "$EUDAIMONIA/examples/hello/smt.eos" \
  --no-scopes --no-list-premises --no-datatypes --no-binders \
  --indexed-ops 0 --out "$WORK"

cd "$WORK/TheoryDemo"
install/get-eo-compiler.sh --pinned --jobs 4
install/install-gates.sh
scripts/build.sh

source install/deps/eoc-env.sh
python3 "$EXAMPLE/check.py" "$EOC_ETHOS_BIN" "$PWD/.lake/build/bin/theorydemo"
lake env lean "$EXAMPLE/Semantics.lean"
install/install-gates.sh --check
```

This needs the compiler's CMake/C++/GMP dependencies, Python 3, and the Lean
toolchain used by the generated project. The supplied `smt.eos` snapshot matches
Eudaimonia's compiler pin; move the compiler and its semantics together when
upgrading them.

Inspect the generated files with these questions in mind:

| Generated file | What to inspect |
| --- | --- |
| `Gates/TheoryDemoTerm.lean` and `Gates/Parser.lean` | Are both new operators represented and recognized? |
| `Gates/Spec.lean` | Does each `__eo_to_smt` branch express the intended meaning? |
| `Gates/SmtModel.lean` and related model modules | Are the required target operators and their typing/evaluation present? |
| `Gates/Proofs/Rules/Nand_elim.lean` and `Nor_elim.lean` | What exactly must be proved about each compiled checking program? |

[`Semantics.lean`](../examples/theories/Semantics.lean) checks six lemmas:
the two translation equations for arbitrary input terms, both gates' values
for every Boolean input, and their agreement with the Eunoia expansions on
those inputs. It prints their axiom dependencies so an accidental `sorry`
cannot hide in the validation record.

**The generated checker remains unverified.** These lemmas do not prove the
per-rule obligations, translation type preservation for arbitrary terms, or
checker correctness. Eudaimonia generates those as open work; an executable
that prints `correct` does not finish it. For an existing Logos development,
extend the existing proofs and explicitly build affected targets, following
[the CPC rule tutorial](adding-a-cpc-rule.md#5-prove-the-generated-rule-obligation).

## 6. When the theory needs a new domain

First see whether the intended theory can be expressed faithfully with existing
types and operations. Reusing a representation still requires justification:
encoding a mathematical domain into integers, arrays, or datatypes may need
invariants, and each rule must respect them. Declaring an uninterpreted sort
does not give it the intended interpretation.

If the target model itself must grow, work through the following layers. This
is the extension procedure to apply to your theory; the gate example does not
add a new domain.

| Layer | Work to supply |
| --- | --- |
| Input sorts and symbols | Eunoia declarations, parameter/index handling, literals if needed, and producer/parser support for their concrete syntax |
| Sort translation | Input `.eos` entries using `:type`, including the domain of valid parameters |
| Semantic sorts | Target `smt.eos` `define-sort` entries and the appropriate well-formedness, default-value, and boundedness behavior |
| Semantic values | A representation of values, their types, and canonical forms; `declare-constructor` entries where the existing embedding supports them |
| Semantic operations | Target `define-symbol` entries with typing and evaluation cases, plus required helper programs or native implementations |
| Verification | Typing and evaluation lemmas, translation compatibility, model existence, and the affected rule proofs |

Use a complete existing theory as a guide, not just one declaration. For
example, the [bit-vector signature][bv-signature] and [target semantics][smt]
jointly cover `BitVec` widths, binary literals, value representation, default
values, and operations. The target's `define-sort BitVec` gives a default;
its `Binary` value constructor checks the width and representation; a
`define-literal Binary` separately handles literal terms. Those are different
parts of a theory, even though they describe the same mathematical objects.

The two `.eos` roles also use different attributes. In an input translation,
`:term` and `:type` describe what a symbol becomes. In the target, `:typeof`
describes an operator's result type, and `:eval` or `:value` describes its
meaning. As a small target-side example, the pinned `smt.eos` defines negation
with:

```lisp
(define-symbol not (x)
  :typeof (of1 Bool Bool x)
  :eval ((smt.bool x)) (smt.bool ("not" x)))
```

Here `of1` and `smt.bool` are macros declared earlier in that file; quoted
`"not"` names a native operation. A new primitive needs the corresponding
typing and evaluation definitions, rather than only a same-name translation.
If its representation or primitives are outside the embedding's vocabulary,
the compiler/native layer needs an extension too. The
[semantics reference][semantics] documents that boundary and the ordering of
helper definitions. Keep changes in those source configurations; regenerate
the Lean modules instead of editing generated constructors or evaluators.

Before claiming the theory verified, establish that its well-formed types have
appropriate values and that well-formed models exist. Otherwise a rule theorem
quantified over such models can be vacuous. New values also affect canonical
forms and possibly value ordering, especially when used inside sets or maps.
Build the affected model and translation proofs as well as the new rules;
regeneration alone does not check preserved proofs.

## 7. Carry a CPC extension through Logos

For cvc5, make the declaration and producer changes in cvc5, update
`install/defs/Cpc.eos` in Logos, and regenerate Logos from that edited `Cpc.eo`.
If the target semantics or compiler also changed, update the compiler pin and
the compatible semantics before the final regeneration. A local
`--smt-semantics` override is useful for experimenting; the released pin must
reproduce those semantics without your private file.

Test a proof that uses the new symbol in its assumptions and derived terms,
including inside existing surrounding theories where supported. An unsupported
translation may cause `incomplete`; that reports a coverage limitation, not a
proof of the new theory. Test typing boundaries and invalid rule applications,
and explicitly build the model, translation, and rule proofs your change affects.

Then follow [the CPC tutorial's landing procedure](adding-a-cpc-rule.md#7-land-logos-then-update-cvc5s-pin):
land the matching Logos change, obtain passing CI at the exact commit, and move
cvc5's `LOGOS_VERSION` to it. A theory declaration changes the vocabulary the
checker and its semantics must agree on, even when it adds no proof rule.

## What was checked

On 2026-09-17, the example was generated using Eudaimonia
`9e3c15e68edb7dc0ac6dc9f9d75cfec1f9d43f33`, with Ethos and `ethos-eoc` built
from its pin, `8dc85c4db8d6cc612f02dc3bb627331732605eff`, and Lean 4.33.0.
The compiler was built from the pinned source archive and connected to the
generated installer; the download/bootstrap command above was not rerun.

The signature and semantics compiled, the generated checker built, all four
proof tests had their expected outcomes in both checkers, and the regeneration
comparison passed. All six Lean lemmas compiled; their printed dependencies
were `propext`, `Classical.choice`, and `Quot.sound`, with no `sorryAx`.
The [example README](../examples/theories/README.md) records the test meanings.

No new semantic domain was implemented, no generated rule or checker soundness
obligation was discharged, and no cvc5 or Logos pin was changed. The new-domain
and CPC integration sections are procedures checked against the pinned
[semantics reference][semantics], [target semantics][smt], and
[Logos installation documentation][install].

[semantics]: https://github.com/cvc5/ethos/blob/8dc85c4db8d6cc612f02dc3bb627331732605eff/tools/eoc/semantics/README.md
[smt]: https://github.com/cvc5/ethos/blob/8dc85c4db8d6cc612f02dc3bb627331732605eff/tools/eoc/semantics/smt.eos
[bv-signature]: https://github.com/cvc5/cvc5/blob/2900761a7c2e2c0e99e2cf669cffa3740ea9a138/proofs/eo/cpc/theories/BitVectors.eo
[install]: https://github.com/cvc5/logos/blob/664c35d6e188a62d5b5dac8fb403d19b9e0f4baa/install/README.md
