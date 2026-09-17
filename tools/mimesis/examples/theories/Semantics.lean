module

-- Checks the generated translations and their values on every Boolean input.
-- These lemmas do not discharge the generated checker or rule obligations.
import Gates.Spec
import all Gates.Spec

open Eo Smtm

def gate (op : UserOp) (p q : Term) : Term :=
  Term.Apply (Term.Apply (Term.UOp op) p) q

theorem nand_translation (p q : Term) :
    __eo_to_smt (gate UserOp.nand p q) =
      SmtTerm.not (SmtTerm.and (__eo_to_smt p) (__eo_to_smt q)) := by
  rfl

theorem nor_translation (p q : Term) :
    __eo_to_smt (gate UserOp.nor p q) =
      SmtTerm.not (SmtTerm.or (__eo_to_smt p) (__eo_to_smt q)) := by
  rfl

theorem nand_values (M : SmtModel) (p q : Bool) :
    __smtx_model_eval M
      (__eo_to_smt (gate UserOp.nand (Term.Boolean p) (Term.Boolean q))) =
        SmtValue.Boolean (!(p && q)) := by
  cases p <;> cases q <;> rfl

theorem nor_values (M : SmtModel) (p q : Bool) :
    __smtx_model_eval M
      (__eo_to_smt (gate UserOp.nor (Term.Boolean p) (Term.Boolean q))) =
        SmtValue.Boolean (!(p || q)) := by
  cases p <;> cases q <;> rfl

-- Pin the connection to the actual Eunoia conclusions, whose variadic and/or
-- applications include their nil terminators when translated into SMT terms.
theorem nand_expansion_values (M : SmtModel) (p q : Bool) :
    __smtx_model_eval M
      (__eo_to_smt (gate UserOp.nand (Term.Boolean p) (Term.Boolean q))) =
    __smtx_model_eval M
      (__eo_to_smt (Term.Apply (Term.UOp UserOp.not)
        (gate UserOp.and (Term.Boolean p)
          (gate UserOp.and (Term.Boolean q) (Term.Boolean true))))) := by
  cases p <;> cases q <;> rfl

theorem nor_expansion_values (M : SmtModel) (p q : Bool) :
    __smtx_model_eval M
      (__eo_to_smt (gate UserOp.nor (Term.Boolean p) (Term.Boolean q))) =
    __smtx_model_eval M
      (__eo_to_smt (Term.Apply (Term.UOp UserOp.not)
        (gate UserOp.or (Term.Boolean p)
          (gate UserOp.or (Term.Boolean q) (Term.Boolean false))))) := by
  cases p <;> cases q <;> rfl

#print axioms nand_translation
#print axioms nor_translation
#print axioms nand_values
#print axioms nor_values
#print axioms nand_expansion_values
#print axioms nor_expansion_values
