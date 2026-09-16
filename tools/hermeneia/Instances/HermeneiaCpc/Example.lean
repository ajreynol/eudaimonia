import HermeneiaCpc.Bridge

/-!
# One refutation, carried across

A concrete CPC refutation — a Boolean constant and its negation, closed by
`contra` — run through the bridge. Everything here is *conditional on* Logos's
conclusion, supplied as the hypothesis `hsound`, so this file needs only the
semantics and not the 691,928 lines of rule proofs.
[`Refutation.lean`](Refutation.lean) discharges that hypothesis.

The only per-problem work is the last two bullets of `native_refutation`: **one
evaluation fact per assumption**, each of which is layer 3's symbol laws applied
to a computed translation. Adding rules or operators to CPC changes none of it.
-/

open Eo Smtm SmtEval
open Hermeneia.Cpc

namespace Hermeneia.Cpc.Example

/-! ## The checked refutation -/

/-- A Boolean constant. -/
def p : Term := Term.UConst 1 Term.Bool

/-- Its negation. -/
def np : Term := Term.Apply (Term.UOp UserOp.not) p

/-- The assumption list, in the order `__eo_invoke_assume_list` consumes. -/
def F : CArgList := CArgList.cons p (CArgList.cons np CArgList.nil)

/-- One `contra` step against the two assumptions, proving `false`. -/
def cmds : CCmdList :=
  CCmdList.cons
    (CCmd.step CRule.contra CArgList.nil (CIndexList.cons 0 (CIndexList.cons 1 CIndexList.nil)))
    CCmdList.nil

/-- The checker accepts: a decidable fact about a concrete run, established by
executing compiled code. `decide` cannot do this; see
[`docs/lean-smt.md`](../../docs/lean-smt.md#4-kernel-reduction). -/
theorem checked : __eo_checker_is_refutation F cmds = true := by native_decide

/-- Every assumption has an SMT-LIB translation: the first side condition. -/
theorem transOk : TranslatableAssumptionList F := by
  refine ⟨?_, ?_, trivial⟩ <;> (unfold eoHasSmtTranslation; native_decide)

/-- The command's arguments satisfy theirs: the second. The list is empty. -/
theorem cmdsOk : CmdListTranslationOk cmds :=
  CmdListTranslationOk.cons _ _ trivial CmdListTranslationOk.nil

/-! ## The model realising a native assignment -/

/-- The key the constant translates to. The name is the compiler's. -/
def kp : SmtModelKey := model_key (native_string_lit "@u.1") SmtType.Bool

/-- `boolSort` supplies the typing and canonicality the override needs, so this
is layer 1 applied to layer 2 with nothing new proved. -/
noncomputable def M (b : Bool) : SmtModel :=
  overrideMany default_typed_model [(kp, boolSort.encode b)]

theorem M_wf (b : Bool) : model_wf (M b) := by
  refine model_wf_overrideMany _ default_typed_model_total_typed _ ?_
  intro kv hkv _
  simp at hkv
  subst hkv
  exact ⟨boolSort.typed b, boolSort.canonical b⟩

theorem M_lookup (b : Bool) :
    (M b).values (model_key (native_string_lit "@u.1") SmtType.Bool) = SmtValue.Boolean b := by
  simp [M, overrideMany, override, kp, boolSort]

/-! ## The native theorem -/

/--
The proposition the checked refutation establishes, in Lean's own terms,
conditional on Logos's conclusion.

The contradiction is the seam's: under the hypotheses the model `M b` makes
every assumption true, and `no_realizing_model` says no well-formed model does.
-/
theorem native_refutation
    (hsound : eo_satisfiability (argListAssumes F) false) :
    ∀ b : Bool, ¬ (b = true ∧ (!b) = true) := by
  rintro b ⟨h1, h2⟩
  refine no_realizing_model hsound (M b) (M_wf b) ?_
  refine AllTrue.cons ?_ (AllTrue.cons ?_ AllTrue.nil)
  · -- the constant: translation, then the `UConst` law, then the lookup
    have ht : __eo_to_smt p = SmtTerm.UConst (native_string_lit "@u.1") SmtType.Bool := rfl
    rw [ht, eval_uconst, M_lookup, h1]
  · -- its negation: the same, then the `not` law
    have ht : __eo_to_smt np
        = SmtTerm.not (SmtTerm.UConst (native_string_lit "@u.1") SmtType.Bool) := rfl
    rw [ht, eval_not, eval_uconst, M_lookup]
    simp [__smtx_model_eval_not, native_not, h2]

/-! ## The shape of the discharge, checked without the proof development

[`Refutation.lean`](Refutation.lean) applies CPC's `correct___eo_is_refutation`,
and importing that theorem costs hours. This says the same three lines against
its *statement*, taken as a hypothesis and transcribed from
`Cpc/Proofs/Checker.lean`, so that everything except "the real theorem has this
statement" is checked in the one-minute build. The transcription is the one
thing a reader must confirm by eye.
-/
theorem refutation_of_soundness
    (soundness : ∀ (F' : CArgList) (pf : CCmdList),
      TranslatableAssumptionList F' -> CmdListTranslationOk pf ->
      eo_is_refutation F' pf -> eo_satisfiability (argListAssumes F') false) :
    ∀ b : Bool, ¬ (b = true ∧ (!b) = true) :=
  native_refutation (soundness F cmds transOk cmdsOk (eo_is_refutation.intro F cmds checked))

end Hermeneia.Cpc.Example

#print axioms Hermeneia.Cpc.Example.M_wf
#print axioms Hermeneia.Cpc.Example.refutation_of_soundness
#print axioms Hermeneia.Cpc.Example.native_refutation
