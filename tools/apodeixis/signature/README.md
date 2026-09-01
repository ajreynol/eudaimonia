# The rendering

Where the Eunoia rendering of the target lives. **Goal 2.**

**It is empty. Nothing has been rendered.**

## What goes here

A specification, in the shape the parent's generator expects one — the layout
`--spec` names by convention:

```
Alethe.eo      the signature: the fragment's operators, and its rules
Alethe.eos     the semantics: what those symbols mean
smt.eos        the SMT-LIB semantics
```

`smt.eos` is the framework's, unmodified, for as long as that is possible. The
profile records whether it is unmodified by digest, so a change here is visible
rather than declared — and a fragment that needs a modified one is a substantial
finding rather than a step, because the framework says replacing it *"is the
hardest part of the specification rather than a flag"*.

The parent's [`examples/hello`](../../../examples/hello) and
[`examples/scoped`](../../../examples/scoped) are the two worked minimal
specifications to read first; `examples/cpc` is the full one. Reading them is
also the calibration this project needs, because both were written by somebody
who knew where the framework's line was, and the point here is to write one that
was not.

## What governs what goes in next

Fragments are chosen for what they stress, in the order
[`../docs/method.md`](../docs/method.md) sets out: enough of the propositional
core that a refutation is expressible at all, then one fragment per hypothesis
in [`../docs/hypotheses.md`](../docs/hypotheses.md), cheapest load first,
contexts last.

Three things are recorded with each addition, in the ledger rather than here:

1. **what was skipped**, and why. Coverage is explicitly out of scope, so the
   omissions are the part a reader cannot reconstruct;
2. **where the rendering was bent** to fit — every such bend before it is made,
   not after;
3. **what the specification says**, where a reading of it is doing work. Every
   rendering is a reading of somebody else's document, and where the reading is
   uncertain, that uncertainty belongs beside the rule and not in a footnote.

## The contract comes first

Before any of it is worth generating, the fragment has to meet the signature
contract: a binary `and`, sent by the semantics to `SmtTerm.and`, with the Bool
literals as the language's own builtins — and `:right-assoc-nil true` on `and`
if any rule gathers `:list` premises with it.

`install/install-<calc>.sh` checks this against the compiler's output rather than
against the source text, so the check is on what a signature *compiles to* and
not on how it spells things. A rendering that cannot meet it is `H1` resolving
early, and that is a result rather than an obstacle.
