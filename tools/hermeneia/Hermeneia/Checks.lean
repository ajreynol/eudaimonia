import Hermeneia.Contract

/-! Synthetic contract checks. These are deliberately not a Logos adapter. -/

namespace Hermeneia.Checks

/-- Tiny literal-only semantics with independently mutable translation and
evaluation. The constructor payload, native carrier and sort stay fixed. -/
def fixture (translateOffset evalOffset : Int) : Semantics where
  Term := Int
  SmtTerm := Int
  SmtType := Unit
  Value := Int
  Model := Unit
  translate := fun n => n + translateOffset
  typeOf := fun _ => ()
  valueType := fun _ => ()
  eval := fun _ n => n + evalOffset
  modelWf := fun _ => True
  holds := fun _ => False

def integers (a b : Int) : SortBridge (fixture a b) Int where
  sort := ()
  encode := id
  typed := fun _ => rfl
  faithful := fun _ _ h => h

def literals (a b : Int) : LiteralBinding (fixture a b) Int where
  term := id
  smtTerm := id

theorem unchanged : NumeralBridge (fixture 0 0) (integers 0 0) (literals 0 0) where
  translates := fun n => Int.add_zero n
  typed := fun _ => rfl
  evaluates := fun _ n => Int.add_zero n

theorem changed_value_rejected :
    ¬ NumeralBridge (fixture 0 1) (integers 0 1) (literals 0 1) := by
  intro h
  have bad : (1 : Int) = 0 := h.evaluates () 0
  exact (by decide : (1 : Int) ≠ 0) bad

theorem changed_translation_rejected :
    ¬ NumeralBridge (fixture 1 0) (integers 1 0) (literals 1 0) := by
  intro h
  have bad : (1 : Int) = 0 := h.translates 0
  exact (by decide : (1 : Int) ≠ 0) bad

/-- Matching literals cannot certify an unrelated implementation of addition. -/
theorem changed_addition_rejected :
    ¬ BinaryBridge (fixture 0 0) Int Int Int
      (integers 0 0) (integers 0 0) (integers 0 0)
      (fun (x y : Int) => x - y) (fun x y => x + y) (fun _ _ => True) := by
  intro h
  have bad : (-1 : Int) = 1 := h.agrees 0 1 trivial
  exact (by decide : (-1 : Int) ≠ 1) bad

def noModels : Semantics := { fixture 0 0 with modelWf := fun _ => False }

/-- Universal evaluation claims under `modelWf` alone would be vacuous here.
The native-to-model existence obligation prevents such a formula bridge. -/
theorem empty_models_rejected : ¬ Nonempty (FormulaBridge noModels Unit) := by
  rintro ⟨B⟩
  obtain ⟨_, hw, _⟩ := B.realizes ()
  exact hw

#print axioms numeral_denotes
#print axioms transfer_unsat
#print axioms transfer_refutation
#print axioms unchanged
#print axioms changed_value_rejected
#print axioms changed_translation_rejected
#print axioms changed_addition_rejected
#print axioms empty_models_rejected

end Hermeneia.Checks
