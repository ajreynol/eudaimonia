# CPC — an example checker specification

A snapshot of the specification that [Logos](https://github.com/cvc5/logos)
compiles: the Cooperating Proof Calculus, the calculus cvc5 emits proofs in.

It is here as a **worked example of the three files a checker is specified by**,
so that the generator has something real to be pointed at. Nothing in the
framework depends on it, and it is not the default: `config.sh` generates a
stubbed project under placeholder names.

## The three files

A checker specification is a signature and the two semantics it is read
against. The generator picks all three up from one directory:

```bash
scripts/new-checker.sh --checker Logos --calculus Cpc --spec examples/cpc
```

| file       | what it is                                                       |
| ---------- | ---------------------------------------------------------------- |
| `Cpc.eo`   | the **Eunoia signature**: the sorts, operators and proof rules of the calculus |
| `Cpc.eos`  | the **semantics of that signature**: what each of its symbols means, as a transformation into the deep embedding of SMT-LIB |
| `smt.eos`  | the **SMT-LIB semantics** `Cpc.eos` is written against: what each SMT-LIB symbol means to a model |

The split between the last two is the point of the arrangement. `smt.eos` is
the target and is the same for every calculus — it is what a model of any input
means. `Cpc.eos` is particular to this calculus and says only how its symbols
land in that target. A new calculus over ordinary SMT-LIB therefore replaces
`Cpc.eo` and `Cpc.eos` and keeps `smt.eos`; extending SMT-LIB itself is what
changes the third.

## Provenance

Copied verbatim, unedited, so a diff against the sources below is a diff of the
specification. The headers each file carries are the ones it has upstream, and
refer to paths in the repositories they came from rather than to this one.

| file       | source                                                              |
| ---------- | ------------------------------------------------------------------- |
| `Cpc.eo`   | `install/defs/Cpc.cached.eo` in cvc5/logos at `9a16707a` (2026-08-29) |
| `Cpc.eos`  | `tools/eoc/semantics/development-cpc.eos` in cvc5/ethos at `3cf1c03f` |
| `smt.eos`  | `tools/eoc/semantics/smt.eos` in the same commit                      |

`Cpc.eo` is Logos's *cached* signature rather than the upstream
`proofs/eo/cpc/Cpc.eo` in cvc5: it is that signature with every `(include ...)`
replaced by the text of the file it names and the comments dropped.

**That flattening is specific to Logos, not a style this framework expects.** A
signature is normally a tree -- a root `.eo` pulling in theories, programs and
rules -- and `--signature` copies the whole include closure into `install/defs/`
with its layout intact. This example is flat only because Logos's copy is.

`Cpc.eos` and `smt.eos` are taken from the **pinned Ethos commit**, verbatim, so
either can be checked against upstream by digest. They are not free to choose:
the semantics format is still changing, and a snapshot only parses against the
compiler it was taken from. `scripts/bump-eoc.sh` advances the pin and both
files together.

`Cpc.eo` is the exception — it comes from Logos, tracks CPC as cvc5 evolves it,
and is refreshed deliberately. Record the commit when you do.

Note that `Cpc.eos` here is upstream's *development copy*, which describes
itself as a compiler fixture; the authoritative CPC semantics lives in Logos.
For an example whose purpose is to exercise the generator over a real 591-rule
signature, the fixture is the right thing and being byte-identical to it is
worth more than local edits.
