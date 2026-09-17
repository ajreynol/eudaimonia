# Eunoia tutorials

These tutorials offer advice and optional worked examples. Mimesis is not a
dependency of signature creation or checker development. Choose the job you
are doing:

| I want to… | Start here | What you will work on |
| --- | --- | --- |
| Add a proof rule to cvc5's CPC signature | **[Start here if you want to add a rule to Cpc.eo in cvc5](adding-a-cpc-rule.md)** | The rule's interface and tests, its generated Lean and soundness proof in Logos, and the cvc5 version pin |
| Define my own proof calculus | [Define a calculus: propositional resolution](defining-a-calculus.md) | Terms, premises, arguments, computed conclusions, side conditions, and proof tests |

For a concrete example of why the Logos proof matters, read the
[BV abstraction case study](case-study.md): stating the obligation exposed a
missing condition in a rule that cvc5's own proof output did not exercise.

Each tutorial records what was tested and what remains a procedure for the
reader to run. The [Eunoia manual](https://github.com/cvc5/ethos/blob/main/user_manual.md)
is the language reference. Return to [Mimesis](../README.md) for the case studies
and the project's scope.
