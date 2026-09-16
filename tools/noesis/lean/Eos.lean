/-
  A Lean definition of a Eunoia semantics set (`.eos`), over the fragment of
  `tools/eoc/semantics/smt.eos` that the core symbols make up.

  This is a *reading*, not an authority: what a `.eos` file means is
  `ethos-eoc`'s answer and stays its answer. See ../README.md.

  Two halves are defined here and one is deliberately absent.

    header half     an entry's name and parameters, which denote a constructor
                    of a many-sorted signature. `OpDecl.of` below, and the
                    `#guard`s under it say the constructors it computes are the
                    ones the generated `Cpc/SmtModelDefs.lean` declares.

    behaviour half  a case table, and what one means as a function. `helper`
                    below, and the `#guard`s under it say it agrees with the
                    generated `__smtx_model_eval_*` on the core symbols.

    absent          casting, i.e. what a body means at a level other than the
                    helper's. It is absent because it is not a function of the
                    file. See §6, and ../docs/eos-in-lean.md.

  Self-contained: no imports, no tactics, no metaprogramming. Checked with
  Lean 4.33.0, the toolchain Logos pins, by ./check.sh.
-/

namespace Noesis.Eos

abbrev Name := String

/-! ## 1. The file as data

  A body, a pattern and a type are written from one small grammar
  (`tools/eoc/semantics/README.md` §3). A bare name means whatever the family
  of the level it stands at is; a name in quotes is a native; a `$`-name is a
  program of the set or a constructor of the embedding; `eo::define` is the
  one builtin.
-/

inductive Surface where
  /-- a bare name: a symbol, a type constructor or an evaluator, by level -/
  | name : Name → Surface
  /-- a whole number, written as the level it stands at writes one -/
  | num : Nat → Surface
  /-- `(f a b)`, where `f` is a bare name, a macro of the file, or a `$`-name -/
  | app : Name → List Surface → Surface
  /-- `("op" a b)`, and `"op"` alone when the list is empty -/
  | nat : Name → List Surface → Surface
  /-- `(eo::define ((v e)) body)` -/
  | bind : Name → Surface → Surface → Surface
  deriving Repr, BEq, Inhabited

/-- How a parameter was written: `v`, `(! v :raw)`, `(! v :type)`. -/
inductive ParamKind where
  | plain | raw | type
  deriving Repr, BEq, DecidableEq, Inhabited

/-- A parameter, with the type an entry gives it where the arguments of its
    kind are not all of one type — `(v <numeral>)`, as a value of the embedding
    writes one. -/
structure Param where
  name : Name
  kind : ParamKind := .plain
  type : Option Name := none
  deriving Repr, BEq, Inhabited

/-- The aggregates a target's entry may contribute a case to: the seven
    programs `plugins/model_smt/model_smt.eos` declares, each named after what
    an entry contributes to it rather than after the program. -/
inductive Key where
  | typeof | value | eval | wf | bounded | dflt | canonical
  deriving Repr, BEq, DecidableEq, Inhabited

/-- One case: what it matches, and what it gives back. -/
structure Case where
  pats : List Surface
  body : Surface
  deriving Repr, BEq, Inhabited

/-- Which form declared an entry. The form is what says which constructor is
    written and which aggregates are asked of it. -/
inductive Kind where
  | symbol | sort | ctor | lit
  deriving Repr, BEq, DecidableEq, Inhabited

structure Entry where
  kind : Kind
  name : Name
  params : List Param := []
  cases : List (Key × Case) := []
  /-- `:builds`, which only a `declare-constructor` says -/
  builds : Option Name := none
  keep : Bool := false
  deriving Repr, BEq, Inhabited

/-- `(define-macro NAME (param...) body)`: expanded before anything else sees
    it, in a pattern as well as in a term. -/
structure Macro where
  name : Name
  params : List Name
  body : Surface
  deriving Repr, BEq, Inhabited

/-- A set: one file. -/
structure Set where
  heading : String := ""
  macros : List Macro := []
  entries : List Entry := []
  deriving Repr, Inhabited

/-! ## 2. Macro expansion

  A macro is expanded before anything else sees it, so everything below is
  defined over the expanded file. Expansion is bounded by a step count rather
  than by a measure: nothing forbids a macro naming a macro, so the depth is a
  fact about a file rather than about the language.
-/

def lookupMacro (ms : List Macro) (f : Name) (n : Nat) : Option Macro :=
  ms.find? (fun m => m.name == f && m.params.length == n)

mutual

def subst (σ : List (Name × Surface)) : Surface → Surface
  | .name x => match σ.find? (fun p => p.1 == x) with
               | some p => p.2
               | none => .name x
  | .num k => .num k
  | .app f as => .app f (substs σ as)
  | .nat f as => .nat f (substs σ as)
  | .bind v e b => .bind v (subst σ e) (subst (σ.filter (fun p => p.1 != v)) b)

def substs (σ : List (Name × Surface)) : List Surface → List Surface
  | [] => []
  | a :: as => subst σ a :: substs σ as

end

mutual

def expand (ms : List Macro) : Nat → Surface → Surface
  | 0, t => t
  | _+1, .name x =>
      match lookupMacro ms x 0 with
      | some m => m.body
      | none => .name x
  | _+1, .num k => .num k
  | fuel+1, .app f as =>
      let as := expandList ms fuel as
      match lookupMacro ms f as.length with
      | some m => expand ms fuel (subst (m.params.zip as) m.body)
      | none => .app f as
  | fuel+1, .nat f as => .nat f (expandList ms fuel as)
  | fuel+1, .bind v e b => .bind v (expand ms fuel e) (expand ms fuel b)

def expandList (ms : List Macro) : Nat → List Surface → List Surface
  | _, [] => []
  | 0, as => as
  | fuel+1, a :: as => expand ms fuel a :: expandList ms fuel as

end

/-! ## 3. The header half: the many-sorted signature an entry denotes

  The nine datatypes of the embedding are the tool's, declared once in
  `plugins/model_smt/model_smt.eos`; what a set contributes is their
  *constructors*. So the header of an entry — its name and its parameter list —
  denotes one operator of a many-sorted first-order signature, and the set
  denotes the signature.
-/

/-- A sort: one of the embedding's nine datatypes, or one of the native types
    a constructor may be built over. -/
inductive Srt where
  | term | type | value | map | seq | reglan | dtCons | dt | dtDecl
  | nNat | nInt | nBool | nRat | nString | nChar
  deriving Repr, BEq, DecidableEq, Inhabited

structure OpDecl where
  name : Name
  args : List Srt
  out : Srt
  deriving Repr, BEq, DecidableEq, Inhabited

abbrev Sig := List OpDecl

/-- The sort a declared type name stands for, as a set writes one: a native
    type in angle brackets, a datatype of the embedding by its name without
    the `$smt_` it is declared under. -/
def srtOfName : Name → Srt
  | "<bool>" => .nBool
  | "<numeral>" => .nInt
  | "<nat>" => .nNat
  | "<rational>" => .nRat
  | "<string>" => .nString
  | "<char>" => .nChar
  | "SmtType" => .type
  | "SmtValue" => .value
  | "SmtMap" => .map
  | "SmtSeq" => .seq
  | "SmtRegLan" => .reglan
  | "SmtDatatypeCons" => .dtCons
  | "SmtDatatype" => .dt
  | "SmtDatatypeDecl" => .dtDecl
  | _ => .term

/-- What one parameter contributes, which depends on the form that declared
    the entry. This is `Constructor.argument` of `tools/eoc/sem_target.py`:

      a symbol   every argument is a term, and a `:type` one is a type;
      a sort     a plain argument is a type, a `:raw` one the index the type is
                 built over, which is a native natural;
      a value    what the parameter's own declared type says;
      a literal  the same — a literal is a term built over a native rather than
                 over terms, which is the whole of what makes it one.
-/
def argSrt (k : Kind) (p : Param) : Srt :=
  match k, p.kind with
  | .symbol, .type => .type
  | .symbol, _ => .term
  | .sort, .raw => .nNat
  | .sort, _ => .type
  | _, _ => match p.type with
            | some t => srtOfName t
            | none => .term

/-- The datatype an entry's constructor builds. -/
def outSrt (e : Entry) : Srt :=
  match e.kind with
  | .symbol => .term
  | .lit => .term
  | .sort => .type
  | .ctor => match e.builds with
             | some b => srtOfName b
             | none => .value

def OpDecl.of (e : Entry) : OpDecl :=
  { name := e.name, args := e.params.map (argSrt e.kind), out := outSrt e }

def Sig.of (s : Set) : Sig := s.entries.map OpDecl.of

/-! ## 4. The behaviour half: a case table, and what one means

  A value of the embedding is a constructor applied to values and to natives.
  Nothing here is indexed by `Srt`: well-sortedness is a predicate over this
  universe rather than a property of its terms, which keeps the definitions
  first-order and keeps the `#guard`s below computable.
-/

inductive U where
  | mk : Name → List U → U
  | bool : Bool → U
  | int : Int → U
  | str : String → U
  deriving Repr, BEq, Inhabited

/-- The trusted base, as a parameter. A native is a partial function on the
    universe: `natives.eos` declares 66 of them, and every one a body calls
    gets its meaning from Lean text in `plugins/lean_meta/lean.eos`, never from
    a set. -/
abbrev Natives := Name → List U → Option U

/-- What the embedding defines for itself, as a parameter: `$vsm_true` and its
    like are `define`s of `plugins/model_smt/model_smt.eo`, not of any set. -/
abbrev EmbDefs := List (Name × Surface)

/-! ### Matching

  A case binds only what its own pattern matches, and the cases of an
  aggregate are tried in the order they were written; what is left over is the
  aggregate's `:otherwise`. A `$`-name in a pattern is a constructor and
  matches itself; a bare name matches anything and binds it.
-/

def isCtor (f : Name) : Bool := f.startsWith "$"

/-- The constructor a `$`-name of the value layer names: `$vsm_Boolean` is the
    embedding's `Boolean`, and the four prefixes are the four datatypes a value
    of this fragment is built over. -/
def ctorName (f : Name) : Name :=
  if f.startsWith "$vsm_" || f.startsWith "$msm_"
     || f.startsWith "$ssm_" || f.startsWith "$rsm_" then (f.drop 5).toString else f

mutual

def matchOne (ν : Natives) : Surface → U → Option (List (Name × U))
  | .name x, u =>
      if isCtor x then
        match u with
        | .mk c [] => if c == ctorName x then some [] else none
        | _ => none
      else some [(x, u)]
  | .app f ps, .mk c us => if isCtor f && ctorName f == c then matchAll ν ps us else none
  | .nat f [], u => if ν f [] == some u then some [] else none
  | .num k, .int i => if (k : Int) == i then some [] else none
  | _, _ => none

def matchAll (ν : Natives) : List Surface → List U → Option (List (Name × U))
  | [], [] => some []
  | p :: ps, u :: us =>
      match matchOne ν p u with
      | none => none
      | some σ => match matchAll ν ps us with
                  | none => none
                  | some τ => some (σ ++ τ)
  | _, _ => none

end

def firstMatch (ν : Natives) : List Case → List U → Option (List (Name × U) × Surface)
  | [], _ => none
  | c :: rest, args =>
      match matchAll ν c.pats args with
      | some σ => some (σ, c.body)
      | none => firstMatch ν rest args

/-! ### Evaluating a body

  A body of a helper case is written over values, so what it means is read off
  three things and no more: what the pattern bound, what a `$`-name builds, and
  what a native does.
-/

mutual

def evalBody (ν : Natives) (σ : List (Name × U)) : Nat → Surface → Option U
  | 0, _ => none
  | _+1, .name x =>
      match σ.find? (fun p => p.1 == x) with
      | some p => some p.2
      | none => if isCtor x then some (.mk (ctorName x) []) else none
  | _+1, .num k => some (.int k)
  | fuel+1, .app f as =>
      match evalArgs ν σ fuel as with
      | none => none
      | some us => if isCtor f then some (.mk (ctorName f) us) else none
  | fuel+1, .nat f as =>
      match evalArgs ν σ fuel as with
      | none => none
      | some us => ν f us
  | fuel+1, .bind v e b =>
      match evalBody ν σ fuel e with
      | none => none
      | some u => evalBody ν ((v, u) :: σ) fuel b

def evalArgs (ν : Natives) (σ : List (Name × U)) : Nat → List Surface → Option (List U)
  | _, [] => some []
  | 0, _ => none
  | fuel+1, a :: as =>
      match evalBody ν σ fuel a with
      | none => none
      | some u => match evalArgs ν σ fuel as with
                  | none => none
                  | some us => some (u :: us)

end

/-- The cases an entry gives of one aggregate: macro-expanded, then with the
    embedding's own definitions resolved. The order matters both times — a
    macro is expanded before anything else sees it, and `$vsm_true` is a
    `define` the expansion of `smt.true` reaches. -/
def casesOf (S : Set) (d : EmbDefs) (name : Name) (k : Key) : List Case :=
  match S.entries.find? (fun e => e.name == name) with
  | none => []
  | some e =>
      (e.cases.filter (fun c => c.1 == k)).map fun c =>
        { pats := (expandList S.macros 32 c.2.pats).map (subst d),
          body := subst d (expand S.macros 32 c.2.body) }

/-- **The helper aggregate, denoted.** This is `$smtx_model_eval_X` of
    `plugins/model_smt/model_smt.eos`: the program a symbol's `:eval` cases are
    written as, over values rather than over terms. Its `:otherwise` is
    `$vsm_NotValue`, which is what "left over" means here, and which no set
    says. -/
def helper (S : Set) (ν : Natives) (d : EmbDefs) (name : Name) (args : List U) : U :=
  match firstMatch ν (casesOf S d name .eval) args with
  | none => .mk "NotValue" []
  | some (σ, body) =>
      match evalBody ν σ 64 body with
      | some u => u
      | none => .mk "NotValue" []

/-! ## 5. A worked fragment: the core symbols of `smt.eos`

  Transcribed from `tools/eoc/semantics/smt.eos`, section "The core symbols",
  and from the vocabulary section above it. Nothing is simplified on the way
  in: what this fragment leaves out is left out, never rewritten.
-/

/-- `(define-macro smt.bool (b) ($vsm_Boolean b))` and its neighbours, from the
    vocabulary section. -/
def vocab : List Macro :=
  [ { name := "smt.bool", params := ["b"], body := .app "$vsm_Boolean" [.name "b"] },
    { name := "smt.re", params := ["r"], body := .app "$vsm_RegLan" [.name "r"] },
    { name := "smt.true", params := [], body := .name "$vsm_true" },
    { name := "smt.false", params := [], body := .name "$vsm_false" } ]

/-- `(define $vsm_true () ($vsm_Boolean $native_true))`, from
    `plugins/model_smt/model_smt.eo`. The embedding's, not the set's — which is
    why it is a parameter here rather than part of the file. -/
def embDefs : EmbDefs :=
  [ ("$vsm_true", .app "$vsm_Boolean" [.nat "true" []]),
    ("$vsm_false", .app "$vsm_Boolean" [.nat "false" []]) ]

/--
```
(define-symbol ite (c x y)
  :keep
  :typeof ($smtx_typeof_ite c x y)
  :eval (smt.true x y)  x
  :eval (smt.false x y) y)

(define-symbol = (x y)
  :keep
  :typeof ($smtx_typeof_= x y)
  :eval ((smt.re r1) (smt.re r2)) (smt.bool ("re_ext_eq" r1 r2))
  :eval (v1 v2) (smt.bool ("veq" v1 v2)))

(define-symbol not (x)
  :typeof (of1 Bool Bool x)
  :eval ((smt.bool x)) (smt.bool ("not" x)))

(define-symbol or (x y)
  :typeof (of2 Bool Bool Bool x y)
  :eval ((smt.bool x) (smt.bool y)) (smt.bool ("or" x y)))

(define-symbol and (x y)
  :typeof (of2 Bool Bool Bool x y)
  :eval ((smt.bool x) (smt.bool y)) (smt.bool ("and" x y)))
```
-/
def coreSymbols : Set :=
  { heading := "The core symbols of smt.eos"
    macros := vocab
    entries :=
      [ { kind := .symbol, name := "ite", keep := true
          params := [⟨"c", .plain, none⟩, ⟨"x", .plain, none⟩, ⟨"y", .plain, none⟩]
          cases :=
            [ (.typeof, ⟨[], .app "$smtx_typeof_ite" [.name "c", .name "x", .name "y"]⟩),
              (.eval, ⟨[.name "smt.true", .name "x", .name "y"], .name "x"⟩),
              (.eval, ⟨[.name "smt.false", .name "x", .name "y"], .name "y"⟩) ] },

        { kind := .symbol, name := "=", keep := true
          params := [⟨"x", .plain, none⟩, ⟨"y", .plain, none⟩]
          cases :=
            [ (.typeof, ⟨[], .app "$smtx_typeof_=" [.name "x", .name "y"]⟩),
              (.eval, ⟨[.app "smt.re" [.name "r1"], .app "smt.re" [.name "r2"]],
                      .app "smt.bool" [.nat "re_ext_eq" [.name "r1", .name "r2"]]⟩),
              (.eval, ⟨[.name "v1", .name "v2"],
                      .app "smt.bool" [.nat "veq" [.name "v1", .name "v2"]]⟩) ] },

        { kind := .symbol, name := "not"
          params := [⟨"x", .plain, none⟩]
          cases :=
            [ (.eval, ⟨[.app "smt.bool" [.name "x"]],
                      .app "smt.bool" [.nat "not" [.name "x"]]⟩) ] },

        { kind := .symbol, name := "or"
          params := [⟨"x", .plain, none⟩, ⟨"y", .plain, none⟩]
          cases :=
            [ (.eval, ⟨[.app "smt.bool" [.name "x"], .app "smt.bool" [.name "y"]],
                      .app "smt.bool" [.nat "or" [.name "x", .name "y"]]⟩) ] },

        { kind := .symbol, name := "and"
          params := [⟨"x", .plain, none⟩, ⟨"y", .plain, none⟩]
          cases :=
            [ (.eval, ⟨[.app "smt.bool" [.name "x"], .app "smt.bool" [.name "y"]],
                      .app "smt.bool" [.nat "and" [.name "x", .name "y"]]⟩) ] } ] }

/-- Five entries from elsewhere in the file, to exercise the parameter kinds a
    core symbol does not have:

```
(define-sort BitVec ((! w :raw)) ...)
(define-sort Map (T U) ...)
(declare-constructor Binary ((w <numeral>) (v <numeral>)) :builds SmtValue ...)
(declare-constructor Fun ((s <string>) (T SmtType) (U SmtType)) :builds SmtValue ...)
(declare-constructor Map ((m SmtMap)) :builds SmtValue ...)
(define-literal Binary ((w <numeral>) (v <numeral>)) ...)
```
-/
def headerSamples : Set :=
  { entries :=
      [ { kind := .sort, name := "BitVec", params := [⟨"w", .raw, none⟩] },
        { kind := .sort, name := "Map",
          params := [⟨"T", .plain, none⟩, ⟨"U", .plain, none⟩] },
        { kind := .ctor, name := "Binary", builds := some "SmtValue",
          params := [⟨"w", .plain, some "<numeral>"⟩, ⟨"v", .plain, some "<numeral>"⟩] },
        { kind := .ctor, name := "Fun", builds := some "SmtValue",
          params := [⟨"s", .plain, some "<string>"⟩, ⟨"T", .plain, some "SmtType"⟩,
                     ⟨"U", .plain, some "SmtType"⟩] },
        { kind := .ctor, name := "Map", builds := some "SmtValue",
          params := [⟨"m", .plain, some "SmtMap"⟩] },
        { kind := .lit, name := "Binary",
          params := [⟨"w", .plain, some "<numeral>"⟩, ⟨"v", .plain, some "<numeral>"⟩] } ] }

/-! ### The header half, against the generated Lean

  Each `#guard` below is one constructor of `Cpc/SmtModelDefs.lean` as
  `OpDecl.of` computes it from the entry that produced it. A failure here is
  this definition disagreeing with the compiler, which is this project's
  finding to explain rather than the compiler's to fix.
-/

private def op (s : Set) (i : Nat) : OpDecl := OpDecl.of (s.entries.getD i default)

-- `| ite : SmtTerm -> SmtTerm -> SmtTerm -> SmtTerm`
#guard op coreSymbols 0 == { name := "ite", args := [.term, .term, .term], out := .term }
-- `| eq : SmtTerm -> SmtTerm -> SmtTerm`  (`=` is spelt `eq` by the printer)
#guard op coreSymbols 1 == { name := "=", args := [.term, .term], out := .term }
-- `| not : SmtTerm -> SmtTerm`
#guard op coreSymbols 2 == { name := "not", args := [.term], out := .term }
-- `| BitVec : native_Nat -> SmtType`
#guard op headerSamples 0 == { name := "BitVec", args := [.nNat], out := .type }
-- `| Map : SmtType -> SmtType -> SmtType`
#guard op headerSamples 1 == { name := "Map", args := [.type, .type], out := .type }
-- `| Binary : native_Int -> native_Int -> SmtValue`
#guard op headerSamples 2 == { name := "Binary", args := [.nInt, .nInt], out := .value }
-- `| Fun : native_String -> SmtType -> SmtType -> SmtValue`
#guard op headerSamples 3 == { name := "Fun", args := [.nString, .type, .type], out := .value }
-- `| Map : SmtMap -> SmtValue`
#guard op headerSamples 4 == { name := "Map", args := [.map], out := .value }
-- `| Binary : native_Int -> native_Int -> SmtTerm`   (the literal, not the value)
#guard op headerSamples 5 == { name := "Binary", args := [.nInt, .nInt], out := .term }

/-! ### The behaviour half, against the generated Lean

  The natives this fragment reaches. Every one is Lean text in
  `plugins/lean_meta/lean.eos` there and is hand-written here; that is the
  trusted base showing through, and it is the point rather than a shortcut.
-/

def natives : Natives
  | "true", [] => some (.bool true)
  | "false", [] => some (.bool false)
  | "not", [.bool a] => some (.bool (!a))
  | "or", [.bool a, .bool b] => some (.bool (a || b))
  | "and", [.bool a, .bool b] => some (.bool (a && b))
  | "veq", [a, b] => some (.bool (a == b))
  | _, _ => none

private def T : U := .mk "Boolean" [.bool true]
private def F : U := .mk "Boolean" [.bool false]
private def N : U := .mk "NotValue" []
private def three : U := .mk "Numeral" [.int 3]

private def ev (f : Name) (args : List U) : U := helper coreSymbols natives embDefs f args

-- `__smtx_model_eval_and | (Boolean x), (Boolean y) => Boolean (native_and x y)`
#guard ev "and" [T, T] == T
#guard ev "and" [T, F] == F
-- `__smtx_model_eval_or`
#guard ev "or" [F, F] == F
#guard ev "or" [T, F] == T
-- `__smtx_model_eval_not`
#guard ev "not" [T] == F
-- `| t1, t2 => SmtValue.NotValue`, the `:otherwise` — which no set says
#guard ev "and" [T, three] == N
#guard ev "not" [three] == N
-- `__smtx_model_eval_ite | (Boolean true), x, y => x`, which reaches `$vsm_true`
-- through the macro `smt.true` and the embedding's own `define`
#guard ev "ite" [T, three, F] == three
#guard ev "ite" [F, three, F] == F
#guard ev "ite" [three, T, F] == N
-- `__smtx_model_eval_eq | v1, v2 => Boolean (native_veq v1 v2)`. Its second
-- case binds both arguments, so nothing is left over and no `:otherwise` is
-- written for it — which is a rule about the *file*, checkable here
#guard ev "=" [three, three] == T
#guard ev "=" [T, F] == F
-- an arity no aggregate calls it at is left over rather than an error
#guard ev "and" [T] == N
-- a symbol the fragment does not hold has no cases, so everything is left over
#guard ev "bvadd" [T, T] == N

/-! ## 6. What is not here, and why

  `:typeof`, `:wf`, `:bounded`, `:default`, `:canonical` and the non-helper
  half of `:value` are absent, and one line says why. In

      :typeof (of2 Bool Bool Bool x y)
      :eval   ((smt.bool x) (smt.bool y)) (smt.bool ("and" x y))

  the same parameter `x` stands for a *type* in the first and for a *value* in
  the second, and the file does not say so. Which it is comes from the
  aggregate's `:stands-for`, in `tools/eoc/sem_target.py` — 1,025 lines of
  Python that no set names and that the language reference says nobody editing
  a set needs to open.

  So `⟦·⟧` is not a function of a `.eos` file. It is a function of the file and
  of that shape table, and the shape table has no definition anywhere. Writing
  it down is the next thing, and it is what this fragment was written to find
  out.

  Three smaller absences, each for its own reason:

  * a body that names another symbol — `(define-symbol => (x y) :eval (x y)
    (or (not x) y))` — is the `:default` path, where a case hands its work to
    another symbol's helper. Definable here, and left out because it needs the
    evaluator and the helper to be mutually recursive, which wants a measure
    this fragment has no reason to pick;
  * the 98 `program` forms, which are ordinary recursive definitions and are
    the place termination has to be argued. Three of them are argued today by
    Lean text inside the configuration, under `define-method :lean`;
  * well-sortedness, which is a predicate over `U` rather than an index on it.
    Stating it is what turns `Sig.of` from a computation into a claim about the
    generated inductives.
-/

end Noesis.Eos
