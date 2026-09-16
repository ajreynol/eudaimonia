import Cpc.Proofs.TypePreservation.Nonvacuity
import Cpc.Proofs.TypePreservation.Helpers
import Cpc.Proofs.Assumptions

/-!
# The bridge, at full CPC generality

**Nothing in this file names a proof rule or a calculus operator.** It imports
`Cpc` only because that is where the generated `Smtm` namespace lives; every
theorem below is about the SMT-LIB semantics (`smt.eos`), which Eudaimonia
already identifies by digest, and would be unchanged for any checker sharing it.

That is the point. The layers are ordered by what makes them grow:

| layer | what it is | grows with |
| --- | --- | --- |
| 0 — the seam | from `eo_satisfiability (argListAssumes F) false` to "no well-formed model makes every assumption true" | **nothing** |
| 1 — realisation | every native assignment reaches a globally well-formed model | **nothing** (the per-sort part is layer 2) |
| 2 — sorts | one native carrier per `SmtType`, in two separate directions | one `SmtType` constructor (15 today) |
| 3 — symbol laws | one evaluation equation per `SmtTerm` constructor | one `SmtTerm` constructor (148 today) |

CPC's 591 proof rules and 189 operators appear in none of them: the soundness
theorem names no rule, and `eo_satisfiability t b` is *defined* as
`smt_satisfiability (__eo_to_smt t) b`, so the calculus is discharged by
computing `__eo_to_smt` on a concrete term rather than by reasoning about it.
[`docs/lean-smt.md`](../../docs/lean-smt.md) works through the consequences.
-/

open Eo Smtm SmtEval

namespace Hermeneia.Cpc

/-! ## Layer 0 — the refutation seam

Rule-free, symbol-free and sort-free, and it reports no `native_decide` axiom.
This is the whole of what Logos's conclusion has to be turned into. -/

/-- `smt_satisfiability t false` is *false under every well-formed model*, which
is stronger than *no model makes it true*; this uses the former as it stands
rather than redefining Logos's predicate. -/
theorem no_true_model {t : SmtTerm} (h : smt_satisfiability t false) :
    ∀ M, model_wf M -> __smtx_model_eval M t = SmtValue.Boolean false := by
  cases h with | intro_false h => exact h

/-- A model makes every assumption of a list true. -/
inductive AllTrue (M : SmtModel) : CArgList -> Prop
  | nil : AllTrue M CArgList.nil
  | cons {A : Term} {as : CArgList} :
      __smtx_model_eval M (__eo_to_smt A) = SmtValue.Boolean true ->
      AllTrue M as -> AllTrue M (CArgList.cons A as)

/-! The two calculus-level facts the fold needs are exactly Eudaimonia's
[signature contract](../../../../README.md#the-signature-contract): a binary
`and` sent to `SmtTerm.and`, and the Bool literals. Both hold by `rfl`, and a
signature that broke either would break this proof rather than pass silently. -/

private theorem eval_bool (M : SmtModel) (b : Bool) :
    __smtx_model_eval M (SmtTerm.Boolean b) = SmtValue.Boolean b := by
  simp [__smtx_model_eval]

private theorem eval_and (M : SmtModel) (x y : SmtTerm) :
    __smtx_model_eval M (SmtTerm.and x y)
      = __smtx_model_eval_and (__smtx_model_eval M x) (__smtx_model_eval M y) := by
  simp [__smtx_model_eval]

/-- `argListAssumes` folds the assumptions into an `and`-chain with a terminal
`true`; this is that chain evaluated. -/
theorem eval_argListAssumes (M : SmtModel) :
    ∀ F : CArgList, AllTrue M F ->
      __smtx_model_eval M (__eo_to_smt (argListAssumes F)) = SmtValue.Boolean true := by
  intro F h
  induction h with
  | nil =>
      have h1 : __eo_to_smt (argListAssumes CArgList.nil) = SmtTerm.Boolean true := rfl
      rw [h1, eval_bool]
  | @cons A as hA _ ih =>
      have h1 : __eo_to_smt (argListAssumes (CArgList.cons A as))
          = SmtTerm.and (__eo_to_smt A) (__eo_to_smt (argListAssumes as)) := rfl
      rw [h1, eval_and, hA, ih]
      rfl

/--
**The seam.** No well-formed model makes every assumption of a checked
refutation true.

Everything a caller still owes is on the other side of this theorem: a model
(layer 1), and one evaluation fact per assumption (layers 2 and 3).
-/
theorem no_realizing_model {F : CArgList}
    (h : eo_satisfiability (argListAssumes F) false)
    (M : SmtModel) (hM : model_wf M) : ¬ AllTrue M F := by
  intro hAll
  have h1 := no_true_model h M hM
  rw [eval_argListAssumes M F hAll] at h1
  simp at h1

/-! ## Layer 1 — realising a native assignment

`FormulaBridge.realizes` asks for a *globally* well-formed model for every
native assignment, not one that is well-formed where the formula happens to
look. Logos already proves models exist — `default_typed_model` is canonical at
every well-formed type — so what is needed is an override at the finitely many
keys the assumptions mention. `model_fun_wf` constrains only `nativeFuns`, which
an override leaves alone, so it transfers for free; the rest reduces to the
typing and canonicality of the substituted value, which is what layer 2 supplies. -/

def override (M : SmtModel) (k : SmtModelKey) (v : SmtValue) : SmtModel :=
  { M with values := fun k' => if k' = k then v else M.values k' }

theorem model_wf_override (M : SmtModel) (hM : model_wf M) (k : SmtModelKey) (v : SmtValue)
    (hty : __smtx_type_wf k.ty = true -> __smtx_typeof_value v = k.ty)
    (hcan : __smtx_type_wf k.ty = true -> __smtx_value_canonical v = true) :
    model_wf (override M k v) := by
  obtain ⟨h1, h2, h3⟩ := hM
  refine ⟨?_, ?_, ?_⟩
  · intro isVar s T hT
    by_cases hk : ({ isVar := isVar, name := s, ty := T } : SmtModelKey) = k
    · subst hk; simpa [override] using hty hT
    · simp [override, hk]; exact h1 isVar s T hT
  · intro isVar s T hT
    by_cases hk : ({ isVar := isVar, name := s, ty := T } : SmtModelKey) = k
    · subst hk; simpa [override] using hcan hT
    · simp [override, hk]; exact h2 isVar s T hT
  · intro fid A B i hFun hi; exact h3 fid A B i hFun hi

/-- Any finite assignment, not just one key: the head of the list wins. -/
def overrideMany (M : SmtModel) : List (SmtModelKey × SmtValue) -> SmtModel
  | [] => M
  | (k, v) :: rest => override (overrideMany M rest) k v

theorem model_wf_overrideMany (M : SmtModel) (hM : model_wf M) :
    ∀ ks : List (SmtModelKey × SmtValue),
      (∀ kv ∈ ks, __smtx_type_wf kv.1.ty = true ->
        __smtx_typeof_value kv.2 = kv.1.ty ∧ __smtx_value_canonical kv.2 = true) ->
      model_wf (overrideMany M ks)
  | [], _ => hM
  | (k, v) :: rest, h => by
      refine model_wf_override _ (model_wf_overrideMany M hM rest ?_) k v ?_ ?_
      · intro kv hkv; exact h kv (List.mem_cons_of_mem _ hkv)
      · intro hT; exact (h (k, v) (List.mem_cons_self ..) hT).1
      · intro hT; exact (h (k, v) (List.mem_cons_self ..) hT).2

theorem overrideMany_values (M : SmtModel) :
    ∀ (ks : List (SmtModelKey × SmtValue)) (k : SmtModelKey),
      (overrideMany M ks).values k
        = ((ks.find? (fun kv => kv.1 = k)).map Prod.snd).getD (M.values k)
  | [], k => rfl
  | (k0, v0) :: rest, k => by
      by_cases hk : k = k0
      · subst hk; simp [overrideMany, override]
      · have : ¬ (k0 = k) := fun h => hk h.symm
        simp [overrideMany, override, hk, this, overrideMany_values M rest k]

/-- Every finite native assignment reaches a globally well-formed model that
looks its values up. -/
theorem exists_model (ks : List (SmtModelKey × SmtValue))
    (h : ∀ kv ∈ ks, __smtx_type_wf kv.1.ty = true ->
      __smtx_typeof_value kv.2 = kv.1.ty ∧ __smtx_value_canonical kv.2 = true) :
    ∃ M, model_wf M ∧ ∀ k : SmtModelKey,
      M.values k = ((ks.find? (fun kv => kv.1 = k)).map Prod.snd).getD
        (default_typed_model.values k) :=
  ⟨overrideMany default_typed_model ks,
    model_wf_overrideMany _ default_typed_model_total_typed ks h,
    overrideMany_values default_typed_model ks⟩

/-! ## Layer 2 — one sort, two directions

`SortRealize` is what a quantifier-free goal needs: every native value of the
sort has a well-typed, canonical embedded counterpart, injectively.
`SortCover` is the *other* direction, and only quantifiers need it: every
embedded value of the sort is the image of a native one.

The two are kept apart because a sort can have one and not the other:

* Bridging Lean `Nat` to `SmtType.Int` **realises** (every `Nat` is an `Int`)
  but does not **cover** (negative numerals are no `Nat`), so an embedded `∀`
  over `Int` is not a Lean `∀ n : Nat` without a guard. lean-smt embeds `Nat`
  this way, so this is not a hypothetical.
* Bridging Lean `ℝ` to `SmtType.Real` fails the *first* direction outright.
  `SmtValue.Rational` carries a `Rat`, so an assignment to an irrational has no
  embedded counterpart. `ratSort` below is the only carrier this sort admits.

Note also what covering costs. `boolCover` is not a fact about `Bool`: it needs
shape lemmas about maps, sets, sequences and datatype-constructor applications,
because those are the other ways a value could have acquired the type. **Coverage
obligations are not independent per sort** — adding a sort can reopen every
existing coverage proof — while realisation obligations are. -/

/-- The set-type former yields a `Set` type or nothing. -/
theorem set_type_shape (X : SmtType) :
    (∃ A : SmtType, __smtx_map_to_set_type X = SmtType.Set A) ∨
      __smtx_map_to_set_type X = SmtType.None := by
  cases X with
  | Map A B => cases B with
    | Bool => exact Or.inl ⟨A, by simp [__smtx_map_to_set_type]⟩
    | _ => right; simp [__smtx_map_to_set_type]
  | _ => right; simp [__smtx_map_to_set_type]

/-- Applying a value yields a datatype-constructor chain result type, or nothing. -/
theorem apply_value_chain : ∀ v : SmtValue, ∀ T U : SmtType,
    __smtx_typeof_value v = SmtType.DtcAppType T U -> dt_cons_chain_result U
  | SmtValue.DtCons s d i, T, U, h => by
      have := dt_cons_chain_result_of_dt_cons_value_type h
      simpa [dt_cons_chain_result] using this
  | SmtValue.Apply v1 v2, T, U, h => by
      simp only [__smtx_typeof_value] at h
      cases hv1 : __smtx_typeof_value v1 with
      | DtcAppType T' U' =>
          have ih := apply_value_chain v1 T' U' hv1
          rw [hv1] at h
          simp only [__smtx_typeof_apply_value, __smtx_typeof_guard, native_ite] at h
          split at h
          · simp at h
          · split at h
            · subst h; simpa [dt_cons_chain_result] using ih
            · simp at h
      | _ => rw [hv1] at h; simp [__smtx_typeof_apply_value] at h
  | SmtValue.NotValue, T, U, h => by simp [__smtx_typeof_value] at h
  | SmtValue.Boolean _, T, U, h => by simp [__smtx_typeof_value] at h
  | SmtValue.Numeral _, T, U, h => by simp [__smtx_typeof_value] at h
  | SmtValue.Rational _, T, U, h => by simp [__smtx_typeof_value] at h
  | SmtValue.Binary _ _, T, U, h => by
      simp only [__smtx_typeof_value, native_ite] at h; split at h <;> simp at h
  | SmtValue.Map _, T, U, h => by
      rcases typeof_map_value_shape ‹SmtMap› with ⟨A, B, hm⟩ | hm <;>
        simp_all [__smtx_typeof_value]
  | SmtValue.Fun _ _ _, T, U, h => by simp [__smtx_typeof_value] at h
  | SmtValue.Set m, T, U, h => by
      rcases set_type_shape (__smtx_typeof_map_value m) with ⟨A, hs⟩ | hs <;>
        simp_all [__smtx_typeof_value]
  | SmtValue.Seq s, T, U, h => by
      rcases typeof_seq_value_shape s with ⟨A, hs⟩ | hs <;> simp_all [__smtx_typeof_value]
  | SmtValue.Char _, T, U, h => by
      simp only [__smtx_typeof_value, native_ite] at h; split at h <;> simp at h
  | SmtValue.UValue _ _, T, U, h => by simp [__smtx_typeof_value] at h
  | SmtValue.RegLan _, T, U, h => by simp [__smtx_typeof_value] at h

/-- Nothing but the `Boolean` constructor has type `Bool`. -/
theorem bool_cover (v : SmtValue) (h : __smtx_typeof_value v = SmtType.Bool) :
    ∃ b : Bool, v = SmtValue.Boolean b := by
  cases v with
  | Boolean b => exact ⟨b, rfl⟩
  | Map m => rcases typeof_map_value_shape m with ⟨A, B, hm⟩ | hm <;> simp_all [__smtx_typeof_value]
  | Set m => rcases set_type_shape (__smtx_typeof_map_value m) with ⟨A, hs⟩ | hs <;>
      simp_all [__smtx_typeof_value]
  | Seq s => rcases typeof_seq_value_shape s with ⟨A, hs⟩ | hs <;> simp_all [__smtx_typeof_value]
  | DtCons s d i =>
      have := dt_cons_chain_result_of_dt_cons_value_type h
      simp [dt_cons_chain_result] at this
  | Apply v1 v2 =>
      simp only [__smtx_typeof_value] at h
      cases hv1 : __smtx_typeof_value v1 with
      | DtcAppType T' U' =>
          have ih := apply_value_chain v1 T' U' hv1
          rw [hv1] at h
          simp only [__smtx_typeof_apply_value, __smtx_typeof_guard, native_ite] at h
          split at h
          · simp at h
          · split at h
            · subst h; simp [dt_cons_chain_result] at ih
            · simp at h
      | _ => rw [hv1] at h; simp [__smtx_typeof_apply_value] at h
  | _ => simp only [__smtx_typeof_value, native_ite] at h <;> (try split at h) <;> simp_all

/-- Nothing but the `Numeral` constructor has type `Int`. -/
theorem int_cover (v : SmtValue) (h : __smtx_typeof_value v = SmtType.Int) :
    ∃ n : Int, v = SmtValue.Numeral n := by
  cases v with
  | Numeral n => exact ⟨n, rfl⟩
  | Map m => rcases typeof_map_value_shape m with ⟨A, B, hm⟩ | hm <;> simp_all [__smtx_typeof_value]
  | Set m => rcases set_type_shape (__smtx_typeof_map_value m) with ⟨A, hs⟩ | hs <;>
      simp_all [__smtx_typeof_value]
  | Seq s => rcases typeof_seq_value_shape s with ⟨A, hs⟩ | hs <;> simp_all [__smtx_typeof_value]
  | DtCons s d i =>
      have := dt_cons_chain_result_of_dt_cons_value_type h
      simp [dt_cons_chain_result] at this
  | Apply v1 v2 =>
      simp only [__smtx_typeof_value] at h
      cases hv1 : __smtx_typeof_value v1 with
      | DtcAppType T' U' =>
          have ih := apply_value_chain v1 T' U' hv1
          rw [hv1] at h
          simp only [__smtx_typeof_apply_value, __smtx_typeof_guard, native_ite] at h
          split at h
          · simp at h
          · split at h
            · subst h; simp [dt_cons_chain_result] at ih
            · simp at h
      | _ => rw [hv1] at h; simp [__smtx_typeof_apply_value] at h
  | _ => simp only [__smtx_typeof_value, native_ite] at h <;> (try split at h) <;> simp_all

/-- What a quantifier-free goal needs of a sort. -/
structure SortRealize where
  carrier : Type
  sort : SmtType
  encode : carrier -> SmtValue
  typed : ∀ a, __smtx_typeof_value (encode a) = sort
  canonical : ∀ a, __smtx_value_canonical (encode a) = true
  injective : ∀ a b, encode a = encode b -> a = b

/-- What a quantifier additionally needs. Separate on purpose. -/
def SortCover (R : SortRealize) : Prop :=
  ∀ v : SmtValue, __smtx_typeof_value v = R.sort -> ∃ a : R.carrier, v = R.encode a

def boolSort : SortRealize where
  carrier := Bool
  sort := SmtType.Bool
  encode := SmtValue.Boolean
  typed := fun _ => rfl
  canonical := fun _ => rfl
  injective := fun _ _ h => by cases h; rfl

def intSort : SortRealize where
  carrier := Int
  sort := SmtType.Int
  encode := SmtValue.Numeral
  typed := fun _ => rfl
  canonical := fun _ => rfl
  injective := fun _ _ h => by cases h; rfl

/-- The `Real` sort's native carrier is `Rat`. There is no `SortRealize` for it
with carrier `ℝ`, and that is a property of the semantics, not of this file. -/
def ratSort : SortRealize where
  carrier := Rat
  sort := SmtType.Real
  encode := SmtValue.Rational
  typed := fun _ => rfl
  canonical := fun _ => rfl
  injective := fun _ _ h => by cases h; rfl

theorem boolCover : SortCover boolSort := fun v h => bool_cover v h
theorem intCover : SortCover intSort := fun v h => int_cover v h

/-! ## Layer 3 — symbol laws

One evaluation equation per `SmtTerm` constructor used. These are the
obligations that grow with the semantics, and the only ones a new *operator*
can create — and only when it translates to a constructor with no law yet.
`eval_bool` and `eval_and` above belong to this layer too; they are stated
earlier because layer 0's fold needs them. -/

theorem eval_not (M : SmtModel) (x : SmtTerm) :
    __smtx_model_eval M (SmtTerm.not x)
      = __smtx_model_eval_not (__smtx_model_eval M x) := by
  simp [__smtx_model_eval]

theorem eval_uconst (M : SmtModel) (s : native_String) (T : SmtType) :
    __smtx_model_eval M (SmtTerm.UConst s T) = M.values (model_key s T) := by
  simp [__smtx_model_eval, native_model_lookup]

end Hermeneia.Cpc

/-! ## What the layers rest on

Layer 0 reports only Lean's three standard axioms: the seam itself is
kernel-clean, with no `native_decide` anywhere. Layer 1's model existence
inherits two `native_decide` axioms from Logos's own canonicality proofs, and
layer 2's coverage theorems report no compiler dependency either. -/
#print axioms Hermeneia.Cpc.no_realizing_model
#print axioms Hermeneia.Cpc.exists_model
#print axioms Hermeneia.Cpc.boolCover
#print axioms Hermeneia.Cpc.intCover
