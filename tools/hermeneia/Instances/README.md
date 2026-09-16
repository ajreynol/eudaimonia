# Instances

An **instance** discharges the contracts of
[`Hermeneia/Contract.lean`](../Hermeneia/Contract.lean) for one particular
configuration, against the *actual* generated declarations rather than a copy of
them. [`docs/contract.md`](../docs/contract.md#1-what-is-being-related) says why
that distinction is the whole point: there is no project-wide flag saying that
Logos matches Lean, only a family of contracts and a proof per configuration.

## What is here

[`HermeneiaCpc/`](HermeneiaCpc) is against **full CPC**. It is in three files,
split by what each one costs to check rather than by what it says:

| file | imports | what it is |
| --- | --- | --- |
| [`Bridge.lean`](HermeneiaCpc/Bridge.lean) | the SMT-LIB semantics and its type-preservation layer (≈1 min) | the reusable layers: the refutation seam, model realisation, sorts, symbol laws. Names no proof rule and no calculus operator. |
| [`Example.lean`](HermeneiaCpc/Example.lean) | `Bridge` | one checked refutation carried to a Lean proposition, *conditional on* Logos's conclusion |
| [`Refutation.lean`](HermeneiaCpc/Refutation.lean) | `Example` and `Cpc.Proofs.Checker` (hours) | three lines discharging that condition |

The split is the point, and [`docs/generality.md`](../docs/generality.md#6-what-this-instance-does-and-does-not-establish)
explains it: the bridge is developed and rechecked against the semantics alone,
and CPC's 691,928-line proof development is built once, for the last file.

## Why these are outside the package

Hermeneia's default build has no external Lake dependencies, and Hermeneia is
[an island](../README.md#an-island): it writes only inside `tools/hermeneia/`
and appears on no other project's build path. An instance has to import a
neighbouring checkout, so it is kept out of `lakefile.toml` and run by its own
script instead. `lake build` in this package still builds only the contract
library and its synthetic checks.

Nothing here is imported by the package, and deleting this directory changes
nothing else.

## Running it

```bash
Instances/check-cpc.sh <path-to-logos-checkout>          # bridge + conditional example
Instances/check-cpc.sh --full <path-to-logos-checkout>   # also discharges the hypothesis
```

The script builds the Logos targets it needs in that checkout and elaborates the
instance against them, printing an axiom report for each theorem. It writes to
that checkout's `.lake/` build directory and to a temporary directory it
removes; point it at a scratch copy if even that is unwanted.

**`--full` needs room.** CPC's rule proofs produce roughly 9 GB of oleans (107
of 591 modules produced 1.6 GB), so the checkout's `.lake/` wants about 15 GB
free and a machine that will not run out of memory building them. Without it,
`Example.lean`'s `refutation_of_soundness` checks the same three lines against a
transcribed statement of `correct___eo_is_refutation`, which leaves only the
transcription to confirm by eye.

The revisions an instance was last checked against are recorded in
[`docs/ledger.md`](../docs/ledger.md#evidence-baseline). A checkout at a
different revision may need the instance updated, and a passing run against an
unrecorded revision is not a certification of it.
