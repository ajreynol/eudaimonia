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
| `Cpc.eos`  | `install/defs/Cpc.eos` in the same commit                            |
| `smt.eos`  | `tools/eoc/semantics/smt.eos` in cvc5/ethos at `b704df9d`, the commit Logos pins |

`Cpc.eo` is Logos's *cached* signature rather than the upstream
`proofs/eo/cpc/Cpc.eo` in cvc5: it is that signature with every `(include ...)`
replaced by the text of the file it names and the comments dropped, which makes
it a single self-contained file. That is what makes it usable here, since the
upstream one only resolves inside a complete copy of the `proofs/eo` tree.

This is a snapshot and is not kept in step with either upstream. CPC evolves
with cvc5; refresh these files deliberately, and record the commits when you do.
