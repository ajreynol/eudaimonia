# Instances

An **instance** discharges the contracts of
[`Hermeneia/Contract.lean`](../Hermeneia/Contract.lean) for one particular
configuration, against the *actual* generated declarations rather than a copy of
them. [`docs/contract.md`](../docs/contract.md#1-what-is-being-related) says why
that distinction is the whole point: there is no project-wide flag saying that
Logos matches Lean, only a family of contracts and a proof per configuration.

## Why these are outside the package

Hermeneia's default build has no external Lake dependencies, and Hermeneia is
[an island](../README.md#an-island): it writes only inside `tools/hermeneia/`
and appears on no other project's build path. An instance has to import a
neighbouring checkout, so it is kept out of `lakefile.toml` and run by its own
script instead. `lake build` in this package still builds only the contract
library and its synthetic checks.

Nothing here is imported by the package, and deleting this directory changes
nothing else.

## What is here

| instance | configuration | what it establishes |
| --- | --- | --- |
| [`CpcMini/`](CpcMini) | Logos's CpcMini calculus, one Boolean constant, assumptions `[p, not p]` | A CPC-Mini refutation checked by reflection, carried through `correct___eo_is_refutation` and a model construction into a proposition about Lean `Bool`s. No `sorry`; axioms reported. |

## Running one

```bash
Instances/CpcMini/check.sh <path-to-logos-checkout>
```

The script builds the two CpcMini targets it needs in that checkout and
elaborates the instance against them. It writes only to that checkout's
`.lake/` build directory. The revisions an instance was last checked against
are recorded in [`docs/ledger.md`](../docs/ledger.md#evidence-baseline); a
checkout at a different revision may need the instance updated, and a passing
run against an unrecorded revision is not a certification of it.
