# Where it is expected to break

Seven predictions, written **before any run**, about where the framework and the
target meet badly. They are recorded in advance for one reason: a stress test
that writes down its expectations only after the fact can never be surprised,
and being surprised is the only outcome here worth much.

Each carries the framework's fixed point it collides with, what would count as a
break rather than as an honest limitation, and how it would be settled. None is
a claim about Alethe — the specification is its authors' and this page's
readings of it are to be confirmed against it before any of them is used.

**Written from published material only, and held.** What is described below comes
from the published specification and from what is public about the format;
nothing here draws on unpublished work, which is its authors' alone. And the page
is not a plan in progress: [the gate](../README.md#the-gate) has not opened, so
none of these predictions is being tested, and if the Alethe maintainers ask for
this page to change or to go, it changes or goes.

**How to read a prediction that turns out wrong.** A hypothesis that does not
break is not a nuisance; it is the more valuable half of the result, because it
converts *the framework is probably narrow here* into *the framework is general
here, measured*. Wrong predictions stay on this page with a line saying what
happened, and are never quietly deleted.

## The grading

Every entry resolves to one of four, and the distinction is the whole point of
keeping a ledger rather than a list of complaints:

| grade | what it means |
| --- | --- |
| **refused** | the framework says no, in the open, at generation or install time. The best outcome after *no break*: the boundary is where it says it is |
| **mis-shaped** | it accepts the input and produces something that is the wrong shape for the calculus — an obligation nobody can discharge, a slot that does not fit |
| **silently wrong** | it accepts and proceeds while meaning something other than what the calculus means. The only grade that is always the framework's problem |
| **disproportionate** | it works, and the cost of making it work is out of all proportion to what was asked |

A prediction that resolves to *the calculus's fault* — the target asks for
something no framework of this kind could give — is a fifth outcome and is
recorded as such, with the argument, because it is the answer most likely to be
self-serving.

## H1 — a step concludes a clause, not a formula

Alethe steps conclude clauses, written `(cl ...)`, and the distinction from the
formula `(or ...)` is load-bearing in the format rather than cosmetic. The
framework's conclusion is fixed: a run establishes that the **conjunction of the
proof's assumptions** is unsatisfiable, the refutation target is `false`, and
`and` is the one operator the statement is phrased in.

So a rendering has to decide what `(cl)` — the empty clause — *is*, and the
framework leaves exactly one answer available: it has to be `false`, or the
refutation test is testing the wrong thing.

*Meets:* the signature contract, and the fixed question *is this a refutation?*
*Break if:* the identification is expressible but the checker's conclusion then
says something other than what an Alethe refutation establishes, and nothing on
the path notices — the contract's own warning about `and` translated elsewhere,
one level up.
*Settled by:* rendering `cl` and reading the generated `Spec.lean` to see what
the conclusion became.

## H2 — contexts are not assumption discharge

Alethe's subproofs open with an anchor carrying a context — a substitution,
used to reason under binders — and this is not the same mechanism as discharging
an assumption into an implication, which is what the framework's `scopes`
profile answer describes and what `examples/scoped` exercises through step-pop.

This is the prediction with the most riding on it. If a context has to be
encoded *through* assumption discharge, the encoding is where a stress test
finds out whether the framework's notion of a subproof is a general one or CPC's
one wearing a general name.

*Meets:* the `scopes` profile answer, which is **derived** — the step-pop
dispatch arms are emitted per rule, so the compiled output settles whether the
calculus has them, but not whether they mean the right thing.
*Break if:* the context has to be smuggled through a mechanism that means
something else — *silently wrong* — or if it can only be expressed by moving the
substitution into a side condition, which is *disproportionate* and also moves
work out of what is proved and into what is computed.
*Settled by:* one rule that reasons under a context, rendered and generated.

## H3 — some rules are deliberate holes

Alethe has rules that are checked by an external procedure rather than by a
syntactic side condition, and at least one that is explicitly an unchecked hole.
The framework verifies a calculus against SMT-LIB model semantics; a rule with
no side condition and no proof is an axiom, and a generated checker would report
`correct` for a proof that leans on it.

That is not obviously the framework's problem — it ships unproven, every rule
arrives with `sorry`, and an axiom is what an undischarged obligation looks like.
What is worth finding out is whether the arrangement can **tell the difference**
between a rule nobody has proven yet and a rule nobody can.

*Meets:* the fixed point that a calculus is verified against SMT-LIB model
semantics, and the stub discipline in `docs/limitations.md`, which is careful
about exactly this distinction one level down.
*Break if:* the two are indistinguishable in what a generated project reports.
*Settled by:* rendering one such rule and reading what `rule-status.sh` says
about it.

## H4 — arguments that are numerals

Several Alethe rules take arguments that are coefficients or indices rather than
terms. The framework handles indexed operators, and how many indices a calculus
uses is a **derived** profile answer — the compiler emits `UserOp<n>` only for
an arity the calculus actually uses.

*Meets:* `--indexed-ops N`, and the compiler's emission of the corresponding
enums.
*Break if:* the arity a rendering needs is one the compiler does not emit, or
the derived answer disagrees with what the rendering declared and the
disagreement is reported as a template problem rather than as a calculus fact.
*Settled by:* one arithmetic rule with coefficient arguments.

## H5 — binders, which the profile does not check

Whether any rules are binder-sensitive is a **declared** profile answer, taken on
trust, because the machinery is emitted unconditionally — a calculus with
binder-sensitive rules and one without compile to the same thing. Alethe's
quantifier rules are the natural way to find out whether *unconditionally
emitted* means *actually sufficient*.

This is the sharpest test available of the derived/declared split, which is the
framework's own list of what it does not verify about a calculus.

*Meets:* `--[no-]binders`, and by the same argument `--[no-]datatypes` and
`--[no-]value-ordering`.
*Break if:* a declared-yes answer needs machinery that is not in fact emitted.
That would mean the split is a statement about the compiler's uniformity rather
than about calculi, which is worth knowing precisely because the profile
currently presents it as the latter.
*Settled by:* one quantifier-instantiation rule.

## H6 — sharing, and terms named before they are used

Alethe proofs lean on term sharing and on naming. The framework's parser is
generated from the signature and is explicitly in the trusted base and
unverified, so this is the one prediction whose break would land somewhere the
framework has already declared it is not defending.

*Meets:* the unverified parser, kept in the trusted base deliberately.
*Break if:* sharing has to be expanded away to be rendered at all, which changes
what proof is being checked, and the change is invisible in the verdict.
*Settled by:* a proof large enough that expansion is not free.

## H7 — the seam, and whether Alethe fits it

The framework's per-calculus obligations arrive as a fixed set of slots —
`Proofs/Invariants/Extra.lean` is marked *the calculus-specific seam*, and
`Proofs/TranslationTypePreservation.lean` as the file that cannot be inherited.
For CPC and its relatives the slots fit, which is unsurprising: they were derived
from it.

*Meets:* the F/G/H classification, and the proposed **L** category.
*Break if:* Alethe needs an invariant the slots cannot express. That would not
appear as a hard proof — it would appear as the template being wrong about what
an obligation *is*, which is the failure mode hardest to see from inside.
*Settled by:* generating a checker over a fragment with H2 in it, and reading
what landed in the seam.

## What this feeds

H2, H5 and H7 are the three that bear on the parent's own blocker, and they are
the three [`tools/noesis`](../../noesis/docs/question-7.md) is watching for —
respectively: is the seam's shape invariant or only its name, is the
derived/declared split a fact about calculi or about the compiler, and what does
the translation have to be total over. That page states them as questions about
the framework; this one states them as loads. They are the same three.

The rest — H1, H3, H4, H6 — bear on the framework's own boundary and go no
further than the ledger and, if a person carries them, `TODO.md`.
