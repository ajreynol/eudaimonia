import Std

/-!
An interface experiment, not an instance for Logos. All semantic operations
are parameters; a concrete adapter must bind them to generated declarations.
See docs/contract.md for that binding and the obligations omitted here.
-/

namespace Hermeneia

set_option autoImplicit false

/-- One generated semantics, including the calculus-to-SMT translation. -/
structure Semantics where
  Term : Type
  SmtTerm : Type
  SmtType : Type
  Value : Type
  Model : Type
  translate : Term → SmtTerm
  typeOf : SmtTerm → SmtType
  valueType : Value → SmtType
  eval : Model → SmtTerm → Value
  modelWf : Model → Prop
  /-- The Logos adapter must use equality to `SmtValue.Boolean true`. -/
  holds : Value → Prop

/-- A faithful native representation. Surjectivity is a later, separate law
needed for quantification over all embedded values of a sort. -/
structure SortBridge (S : Semantics) (α : Type) where
  sort : S.SmtType
  encode : α → S.Value
  typed : ∀ a, S.valueType (encode a) = sort
  faithful : ∀ a b, encode a = encode b → a = b

/-- The actual constructors to which a literal claim applies. -/
structure LiteralBinding (S : Semantics) (α : Type) where
  term : α → S.Term
  smtTerm : α → S.SmtTerm

/-- Proof fields, not a Boolean assertion that two things match. Literal
evaluation does not assume `modelWf`; model existence is a separate obligation
in `FormulaBridge`. -/
structure LiteralBridge (S : Semantics) (α : Type)
    (R : SortBridge S α) (L : LiteralBinding S α) : Prop where
  translates : ∀ a, S.translate (L.term a) = L.smtTerm a
  typed : ∀ a, S.typeOf (L.smtTerm a) = R.sort
  evaluates : ∀ M a, S.eval M (L.smtTerm a) = R.encode a

abbrev NumeralBridge (S : Semantics) (R : SortBridge S Int)
    (L : LiteralBinding S Int) := LiteralBridge S Int R L

theorem numeral_denotes {S : Semantics} {R : SortBridge S Int}
    {L : LiteralBinding S Int} (B : NumeralBridge S R L) (M : S.Model) (n : Int) :
    S.eval M (S.translate (L.term n)) = R.encode n := by
  rw [B.translates, B.evaluates]

/-- Each arithmetic operation requires its own law, even after literals match.
`domain` makes conditional correspondences explicit (e.g. nonzero divisors). -/
structure BinaryBridge (S : Semantics) (α β γ : Type)
    (A : SortBridge S α) (B : SortBridge S β) (C : SortBridge S γ)
    (embedded : S.Value → S.Value → S.Value) (native : α → β → γ)
    (domain : α → β → Prop) : Prop where
  agrees : ∀ a b, domain a b →
    embedded (A.encode a) (B.encode b) = C.encode (native a b)

/-- Correspondence for a stated fragment and native assignment space. -/
structure FormulaBridge (S : Semantics) (Env : Type) where
  supported : S.Term → Prop
  native : Env → S.Term → Prop
  related : Env → S.Model → Prop
  /-- Every native assignment must be represented, in this direction. -/
  realizes : ∀ ρ, ∃ M, S.modelWf M ∧ related ρ M
  correct : ∀ ρ M t, S.modelWf M → related ρ M → supported t →
    (S.holds (S.eval M (S.translate t)) ↔ native ρ t)

/-- A generic no-true-model conclusion. The Logos adapter must derive this
from `eo_satisfiability t false`; these definitions are not identical. -/
def Unsatisfiable (S : Semantics) (t : S.Term) : Prop :=
  ∀ M, S.modelWf M → ¬ S.holds (S.eval M (S.translate t))

theorem transfer_unsat {S : Semantics} {Env : Type}
    (B : FormulaBridge S Env) (t : S.Term) (ht : B.supported t)
    (hu : Unsatisfiable S t) : ∀ ρ, ¬ B.native ρ t := by
  intro ρ hn
  obtain ⟨M, hw, hr⟩ := B.realizes ρ
  exact hu M hw ((B.correct ρ M t hw hr ht).mpr hn)

/-- The caller must connect the *actual checked term* to hypotheses and the
negated goal. Checker soundness is supplied through `hu`, never assumed here. -/
theorem transfer_refutation {S : Semantics} {Env : Type}
    (B : FormulaBridge S Env) (checked : S.Term) (ht : B.supported checked)
    (hu : Unsatisfiable S checked) (hypotheses goal : Env → Prop)
    (intended : ∀ ρ, B.native ρ checked ↔ (hypotheses ρ ∧ ¬ goal ρ)) :
    ∀ ρ, hypotheses ρ → goal ρ := by
  intro ρ hh
  apply Classical.byContradiction
  intro hn
  exact transfer_unsat B checked ht hu ρ ((intended ρ).mpr ⟨hh, hn⟩)

end Hermeneia
