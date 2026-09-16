# What a Lean definition of `smt.eos` looks like

Goal 4 of [the charter](../README.md) asks for enough of `.eos` defined in Lean
to say what a compiler is obliged to preserve, and says its most useful output
is *the statements that turn out not to be writable yet*. This is the first
pass at that, over one file: `tools/eoc/semantics/smt.eos` in the compiler's
tree, the SMT-LIB semantics every input is compiled through.

It produced a definition that runs — [`../lean/Eos.lean`](../lean/Eos.lean),
checked by [`../lean/check.sh`](../lean/check.sh) — and four things that do not
go through. The fourth is the one worth the page:

> **The meaning of a `.eos` file is not a function of the `.eos` file.** Half of
> it is in a Python module no configuration names, that has no definition
> anywhere, and that the language's own reference says nobody editing a
> semantics needs to open.

Nothing here is a claim about what `smt.eos` *should* say. What a `.eos` file
means is `ethos-eoc`'s answer and stays its answer; a disagreement between that
compiler and anything below is this project's to explain.

Measured on 2026-09-16, against `ethos` at `140716f7` and the generated `Cpc/`
of `logos` at `be479120`.

## 1. What `smt.eos` is

Not a signature. A **configuration that generates one**, three stages above the
Lean a checker is built out of:

```text
smt.eos  ──sem_compile.py──▶  out/smt_defs.eo        ──model-smt──▶  ──lean-meta──▶  Cpc/SmtModelDefs.lean
(2,288 lines)                 out/smt_termination.lean                               Cpc/SmtModel.lean
                                                                                     (295 + 2,186 lines)
```

What the file holds, and what each kind of entry produces:

| in `smt.eos` | count | what one writes |
| --- | --: | --- |
| `define-symbol` | 132 | a constructor of `SmtTerm`, a case of `$smtx_typeof`, and either a case of `$smtx_model_eval` or the program it hands its work to |
| `define-sort` | 14 | a constructor of `SmtType`, and cases of the three programs written over types |
| `declare-constructor` | 34 | a constructor of `SmtValue` or of one of the six datatypes a value is built over |
| `define-literal` | 5 | a constructor of `SmtTerm` built over a native, and the two cases a symbol writes |
| `program` | 98 | itself, with the terms of its cases cast |
| `define-macro` | 35 | nothing: expanded before anything else sees it |
| `define-method` | 3 | nothing of the model — Lean text, appended to a generated definition |

The nine datatypes and the nine aggregate programs are **not** the file's: they
are declared once in `plugins/model_smt/model_smt.eos` and are the same for
every calculus. What a set contributes is constructors and cases.

Two facts about the 132 symbols are worth having before any definition is
written, because they say how regular the thing is. **Every one of them says
`:typeof`** — no symbol leaves its type rule to a default. And the value split
is clean: 122 say `:eval` and hand their work to a program written over values,
10 say `:value` and give it outright, and **no symbol says both, and none says
neither**.

## 2. Two readings, and the one goal 4 wants

**The file as data.** An inductive for the abstract syntax, and `smt.eos` as a
term of it. This is the compiler's *input* in Lean and it is mechanical: §1 of
`Eos.lean` is 80 lines and covers the whole grammar, because the grammar is
closed by design and the language reference says so in those words.

**The file as a denotation.** A function `⟦·⟧` from that syntax to the
mathematical objects it names — the three inductives, the type rule, the
evaluator. This is what a preservation statement needs, because the statement
is *the generated Lean computes `⟦smt.eos⟧`*, and without the right-hand side
there is nothing to be preserved.

Everything below is about the second. The first is a prerequisite for it and is
not interesting on its own.

## 3. The shape the denotation has to take

### The header half is a many-sorted signature, and it is small

An entry's *name and parameter list* denote one operator of a many-sorted
first-order signature: argument sorts, result sort. The sorts are the nine
datatypes of the embedding plus the six native types.

```lean
inductive Srt where
  | term | type | value | map | seq | reglan | dtCons | dt | dtDecl
  | nNat | nInt | nBool | nRat | nString | nChar

structure OpDecl where
  name : Name ; args : List Srt ; out : Srt

def OpDecl.of (e : Entry) : OpDecl :=
  { name := e.name, args := e.params.map (argSrt e.kind), out := outSrt e }
```

`argSrt` is ten lines and is the whole of it, because which sort a
parameter contributes depends only on the form that declared the entry: a
symbol's arguments are terms, a sort's are types except a `:raw` one which is
the native natural the type is built over, and a value's or a literal's are
whatever its own declared type says.

This reproduces the generated inductives exactly. `Eos.lean` carries nine
`#guard`s that say so, each one a line of `Cpc/SmtModelDefs.lean`:

```lean
-- | BitVec : native_Nat -> SmtType
#guard op headerSamples 0 == { name := "BitVec", args := [.nNat], out := .type }
-- | Fun : native_String -> SmtType -> SmtType -> SmtValue
#guard op headerSamples 3 == { name := "Fun", args := [.nString, .type, .type], out := .value }
```

**That the header half is this cheap is the good news on this page.** Nine
constructors of the generated file fall out of three short definitions —
`srtOfName`, `argSrt`, `outSrt` — and every one of them is readable by somebody
who does not use Lean, which is the charter's standard for a definition.

### The behaviour half is an ordered case table

An attribute is a case: a list of patterns and a body. The cases of an
aggregate are tried in the order written, and what is left over is the
aggregate's `:otherwise` — which no set states and every generated program
ends with. So the denotation of a case table is the obvious fold, and the
generated Lean is literally that fold printed:

```lean
def helper (S : Set) (ν : Natives) (d : EmbDefs) (name : Name) (args : List U) : U :=
  match firstMatch ν (casesOf S d name .eval) args with
  | none => .mk "NotValue" []                       -- the :otherwise
  | some (σ, body) => (evalBody ν σ 64 body).getD (.mk "NotValue" [])
```

Against `__smtx_model_eval_and`, `_or`, `_not`, `_ite` and `_eq` of
`Cpc/SmtModel.lean`, on the core-symbol block of `smt.eos` transcribed
verbatim, fourteen `#guard`s pass — including the two that matter more than the
positive ones: a non-Boolean argument falling to the `:otherwise`, and `=`
having no `:otherwise` at all because its second case binds both arguments and
leaves nothing over. That second one is a rule *about the file* rather than
about a run, and it is checkable here.

### The natives are a parameter, and that is the trust boundary

```lean
abbrev Natives := Name → List U → Option U
```

Passing them in rather than defining them is not a shortcut, it is the shape of
the truth: see finding 2.

## 4. What does not go through

### F1. The meaning of a `.eos` file is not a function of the `.eos` file

In one entry of `smt.eos`:

```lisp
(define-symbol and (x y)
  :typeof (of2 Bool Bool Bool x y)
  :eval ((smt.bool x) (smt.bool y)) (smt.bool ("and" x y)))
```

the parameter `x` stands for **the type of the argument** in the first
attribute and for **the value of the argument** in the second. The file does
not say this, and could not: there is no form of the language for it. It comes
from the aggregate's `:stands-for`, which lives in `tools/eoc/sem_target.py`:

| aggregate | a plain argument stands for | at level |
| --- | --- | --- |
| `:typeof` | `($smtx_typeof x)` | type |
| `:value` | `($smtx_model_eval M x)` | value |
| `:eval` | itself | value |
| `:wf`, `:bounded` | itself | native |
| `:default` | itself | value |
| `:canonical` | itself | native |

and the same table decides what a `:raw` argument means — the term itself where
the type rule reads it, its value where the evaluator does — and what the
`:otherwise` is, and which aggregate a symbol falls back to when it says
nothing.

`sem_target.py` is 1,025 lines. The language reference describes it as *"read
by nothing but the compiler"* and *"not a file anyone editing a signature needs
to open"*. Both are true of somebody editing a signature and neither is true of
somebody defining what one means.

**So the object to define is not `⟦set⟧` but `⟦set⟧shape`** — and the shape is
the half with no definition anywhere. That is a deliverable this project can
produce without waiting on anybody: it is a table, it is fixed for every
calculus, and writing it in Lean is the thing that makes `:typeof` and the
other five aggregates statable at all. `Eos.lean` defines the one aggregate
whose `:stands-for` is the identity, which is exactly the one that needs no
shape table, and stops there deliberately.

### F2. The trusted base is bigger than the thing being defined

`smt.eos` calls **101 distinct natives**, and 95 of them have no meaning in any
configuration — the other six say what they *are* under `:is`, written over
other natives, so they reduce rather than bottom out. They split three ways by
how much the configuration knows about one:

| | count | what is known about it in the configuration |
| --- | --: | --- |
| declared in `plugins/desugar/natives.eos` | 45 | name, arity, argument types |
| named in the embedding's own `.eo` files | 5 | the same |
| applied through `$native_apply_N` | **51** | the name, as a string, and nothing else |

The third row is the one to read twice. A native the embedding gives no name of
its own is emitted as `($native_apply_1 "seq.len" x)`, typed
`$native_BuiltinType`, and the caster checks nothing about it: not its arity,
not the level of its arguments. Its only definition is Lean text — 116
`define-native-method` entries carrying 545 lines of Lean in
`plugins/lean_meta/lean.eos`.

So a Lean denotation of `smt.eos` is parameterised by an environment that, for
half the natives the file calls, has to supply the *type* as well as the
meaning, from outside. This is finding 1 of [`passes.md`](passes.md)'s trusted
base — the definitions are trusted — made specific and countable. It is also a
reason the middle strength is reachable: an environment is exactly the kind of
thing a run can be asked to produce evidence about.

### F3. Termination is Lean text inside the configuration

Three `define-method` entries in `smt.eos` carry Lean:

```lisp
(define-method $smtx_type_default  :lean "termination_by T => 2 * sizeOf T")
(define-method $smtx_type_bounded  :lean "termination_by T => (sizeOf T, 0)")
(define-method $smtx_model_eval    :lean "termination_by structural t => t ...")
```

The 98 `program` forms of the file are recursive definitions, and three of the
aggregate programs their cases are spliced into need a termination argument
Lean does not find on its own — a lexicographic measure for the boundedness
fixpoint, twice the size of a type for the datatype recursion, and a structural
annotation plus a cached equation for the evaluator. What makes those
definitions at all is Lean a person wrote, inside the semantics file, which no
part of the pipeline reads as anything but text. A Lean definition of `smt.eos`
therefore has a choice, and it is not a free one:

- **take the measures as input**, and inherit them into the trusted base;
- **define the programs relationally** — an inductive `Eval : Program → List
  Value → Value → Prop` — prove it deterministic, and state the compiler
  theorem as agreement wherever the relation is defined plus a separate
  totality obligation.

The second is the honest one and is more work. Either way the ledger gains a
row it does not have.

### F4. The header half is an isomorphism per run, not a theorem once

The inductives depend on the file, so `⟦·⟧` cannot land in a fixed Lean type.
It lands in a term algebra over the signature of §3, and the generated
inductive has to be related to it — which is a per-run obligation with a
derived proof, not a theorem proved once. In the ledger's vocabulary that is
**validated per run**, and it is the natural reading of `Sig.of`: the nine
`#guard`s above are that validation, done by hand for nine constructors.

## 5. What this changes for the pass ledger

[`passes.md`](passes.md) borrows its pass table from the compiler tree's
readiness document. **That table has no row for the compiler this page is
about.** Its rows are `linear_patterns`, `trim_defs`, `defs_reader`,
`lean_meta`/`smt_meta` and `desugar`, all C++ stages of the binary; the program
that turns `smt.eos` into `smt_defs.eo` is `sem_lang.py`, `sem_target.py` and
`sem_compile.py`, which at the readiness document's own commit were 4,222 of
the 5,545 lines of Python under `tools/eoc/`.

Nothing about that is an error anybody made — a document says what it was
written to say, and that one was written to place a *project*, not to enumerate
a pipeline. But goal 4 is about the input to exactly this pass, so the ledger
needs the row. On the evidence above, it would read:

| pass | what it does | noesis's counterpart | strength it could hold |
| --- | --- | --- | --- |
| `sem_lang` — read, expand, block | text to abstract syntax | the `Surface`/`Entry` inductives | **checked** — round trip, and the parser is trusted by charter |
| `sem_lang` — cast | surface to the deep embedding, by level | the level judgment, over the shape table | **proved**, and not statable until F1 is discharged |
| `sem_target` — the shape | which program a case joins, and what an argument stands for | the shape table as a definition | **proved**, because it is a table |
| `sem_compile` — emit | the signature's constructors and programs | `Sig.of`, and the case-table fold | **validated per run** (F4) for the constructors, **proved** for the folds |

The first useful piece of that is the third row, and it is small.

## 6. What is next, in order

1. **The shape table, in Lean.** Six aggregates, the `:stands-for` of each, the
   `:otherwise`, the defaults and the `:raw` rule. It unblocks the other five
   aggregates and it is a day's work. F1 is the argument for doing it first.
2. **`:typeof` for the core symbols**, over that table, guarded against
   `__smtx_typeof_*` the way `:eval` is now. That is the first statement of the
   form *this generated function computes what the file says*.
3. **The relational reading of a `program`**, and the determinism proof. F3
   says the alternative is inheriting three hand-written measures.
4. Only then anything that looks like a compiler.

None of this touches goal 3. The probe — `linear_patterns` in Lean — answers a
different question and stays first in the charter's order; this page is
evidence that goal 4 has work in it that does not wait on the probe.

## 7. What would change this page

- **The shape table moving.** It is somebody else's file and is not maintained
  for this purpose. Every claim in §4's first finding is against
  `sem_target.py` at `140716f7`.
- **A second calculus.** Everything here is read off the SMT-LIB target, which
  is the one set that is the *target* rather than an input. An input set —
  `development-cpc.eos` — has three aggregates of its own and a level this page
  never mentions, and reading it could change what the shape table has to be.
- **`Eos.lean` failing to scale past the core symbols.** Five entries is a
  fragment. The arithmetic and bit-vector sections have the `:raw` parameters
  and the overloads, and are where a definition of this shape would first
  strain.

## 8. Ledger — candidate feedback, not carried

The child-project rule is that nothing leaves the island by machine, and that
what a child may do on its own is accumulate candidates for a person to decide
about. One, from §5:

- **To the compiler tree, if anybody wants it.** The pass table of
  `docs/noesis-readiness.md` §5 has no row for the `.eos` compiler, and its
  Python figure (2,026) does not match `tools/eoc/*.py` at the commit the
  document was written on (5,545, of which 4,222 are the three `sem_*`
  modules). This may be a scope the document intended; it reads like one worth
  a sentence either way. **Not carried anywhere.** It is written here because
  this page relies on that table.
