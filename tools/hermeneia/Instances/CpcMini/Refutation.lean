import CpcMini.Proofs.Checker
import CpcMini.Proofs.TypePreservation.Nonvacuity

/-!
# A checked refutation carried into Lean's own logic

This is the first end-to-end instance of the correspondence: a CPC-Mini proof is
checked by reflection, its acceptance is turned into `eo_satisfiability ... false`
by Logos's own soundness theorem, and that conclusion is turned into a
proposition about Lean `Bool`s.  Nothing here is `sorry`, and
`#print axioms` at the bottom reports exactly what it rests on.

**It is an instance, not the library.**  `Hermeneia/Contract.lean` states the
contracts abstractly; this file discharges them for one configuration --
CpcMini, one Boolean constant, the assumptions `[p, not p]` -- against the
*actual* generated declarations, which is what
[`docs/plan.md`](../../docs/plan.md) calls H1/H2/H3.

**It is outside this package's build.**  Hermeneia has no Lake dependencies;
this file imports a neighbouring Logos checkout and is run by
[`check.sh`](check.sh).  See [`../README.md`](../README.md).

The identity of the configuration it is checked against is recorded in
[`docs/ledger.md`](../../docs/ledger.md).
-/
open Eo Smtm SmtEval

namespace Hermeneia.Instances.CpcMini

/-! ## 1. Realising a native assignment as a well-formed model

The obligation `FormulaBridge.realizes` states is that *every* native assignment
has a corresponding well-formed embedded model -- agreement on some models would
not justify a conclusion about every native assignment.

Logos already proves models exist: `default_typed_model` assigns every
well-formed SMT type a canonical inhabitant, and `default_typed_model_total_typed`
proves it `model_wf` (`CpcMini/Proofs/TypePreservation/Nonvacuity.lean`).  So the
construction needed here is not a model from nothing, but an *override*: the
native assignment's value at the finitely many keys the checked assumptions
mention, and Logos's default everywhere else.

`model_wf` has three components.  Overriding `values` leaves `nativeFuns`
untouched, so `model_fun_wf` transfers unchanged; the other two reduce to the
typing and canonicality of the single value put in, at the type of its key.
That is exactly what a `SortBridge`'s `typed` field asks for. -/

/-- Replace a model's value at one key. -/
def override (M : SmtModel) (k : SmtModelKey) (v : SmtValue) : SmtModel :=
  { M with values := fun k' => if k' = k then v else M.values k' }

/--
An override preserves well-formedness when the substituted value is typed and
canonical at its key's type.

Both hypotheses are guarded by `__smtx_type_wf k.ty`, because that is the only
case `model_wf` constrains: at a type that is not well-formed the model may
return anything.
-/
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
  · intro fid A B i hFun hi
    exact h3 fid A B i hFun hi

/-! ## 2. The checked refutation

`p` is a Boolean constant and the assumptions are `[p, not p]`, refuted by the
single rule `contra`.  Nothing below is taken on trust from a solver: the
checker run is *evaluated*, and its result is what the soundness theorem
consumes. -/

/-- The Boolean constant the demonstration quantifies over. -/
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

/--
The checker accepts.  This is the reflection step: a decidable fact about a
concrete run, established by executing compiled code.

`decide` cannot do this — see [`docs/lean-smt.md`](../../docs/lean-smt.md#4-kernel-reduction)
for why, and for what the resulting trusted-code-base position is.
-/
theorem checked : __eo_checker_is_refutation F cmds = true := by native_decide

/-- Every assumption has an SMT-LIB translation: the first side condition of
`correct___eo_is_refutation`. -/
theorem transOk : TranslatableAssumptionList F := by
  refine ⟨?_, ?_, trivial⟩ <;> (unfold eoHasSmtTranslation; native_decide)

/-- The command's arguments satisfy their translation side condition: the
second.  The list is empty, so this is `True`. -/
theorem cmdsOk : CmdListTranslationOk cmds :=
  CmdListTranslationOk.cons _ _ trivial CmdListTranslationOk.nil

/--
What Logos concludes: the conjunction of the assumptions is unsatisfiable in the
embedded semantics.  This is the interface Hermeneia starts from, and it is
*not yet* a statement about anything in Lean's own logic.
-/
theorem unsat : eo_satisfiability (argListAssumes F) false :=
  correct___eo_is_refutation F cmds transOk cmdsOk (eo_is_refutation.intro F cmds checked)

/-! ## 3. The bridge

Three facts connect that conclusion to Lean `Bool`s: which model realises an
assignment, what the checked term translates to, and what it evaluates to. -/

/-- The model key the constant `p` translates to.  The name is the compiler's,
not the signature's; binding it by hand is the point of an *instance*. -/
def kp : SmtModelKey := model_key (native_string_lit "@u.1") SmtType.Bool

/-- The model realising the native assignment `b`. -/
noncomputable def M (b : Bool) : SmtModel :=
  override default_typed_model kp (SmtValue.Boolean b)

/-- Every native assignment is realised by a *globally* well-formed model, not
merely by one that is well-formed where the formula looks. -/
theorem M_wf (b : Bool) : model_wf (M b) := by
  refine model_wf_override _ default_typed_model_total_typed kp _ ?_ ?_ <;> intro _ <;> rfl

/-- The calculus translation of the checked conjunction, including the terminal
`Term.Boolean true` that `argListAssumes` folds in. -/
theorem translated : __eo_to_smt (argListAssumes F)
    = SmtTerm.and (SmtTerm.UConst (native_string_lit "@u.1") SmtType.Bool)
        (SmtTerm.and (SmtTerm.not (SmtTerm.UConst (native_string_lit "@u.1") SmtType.Bool))
          (SmtTerm.Boolean true)) := by native_decide

/-- The denotation of the checked conjunction under the assignment `b`: the
composition of translation and model evaluation, against the native reading. -/
theorem denote (b : Bool) :
    __smtx_model_eval (M b) (__eo_to_smt (argListAssumes F))
      = SmtValue.Boolean (b && (!b && true)) := by
  rw [translated]
  show __smtx_model_eval_and (__smtx_model_eval (M b) _)
        (__smtx_model_eval (M b) (SmtTerm.and _ _)) = _
  simp [__smtx_model_eval, native_model_lookup, M, override, kp,
        __smtx_model_eval_and, __smtx_model_eval_not, native_and, native_not]

/-! ## 4. The native theorem

`smt_satisfiability t false` is *false under every well-formed model*, which is
stronger than *no model makes it true*; the conversion below uses the former
directly rather than redefining Logos's predicate. -/

/-- Read `eo_satisfiability t false` as a statement about every well-formed model. -/
theorem no_true_model {t : SmtTerm} (h : smt_satisfiability t false) :
    ∀ M, model_wf M -> __smtx_model_eval M t = SmtValue.Boolean false := by
  cases h with
  | intro_false h => exact h

/--
The proposition the checked refutation establishes, written entirely in Lean's
own terms.

The contradiction comes from the checker: under the hypotheses the checked
conjunction *evaluates* to `Boolean true` in the model realising `b`, while
`unsat` says it is `Boolean false` in every well-formed model.
-/
theorem native_refutation : ∀ b : Bool, ¬ (b = true ∧ (!b) = true) := by
  rintro b ⟨h1, h2⟩
  have hf := no_true_model unsat (M b) (M_wf b)
  rw [denote b] at hf
  have key : (b && (!b && true)) = true := by
    rw [Bool.and_true, h2, Bool.and_true, h1]
  rw [key] at hf
  simp at hf

end Hermeneia.Instances.CpcMini

/-! ## 5. What it rests on

Every `native_decide` in the report is either one of the four in this file, or
one inside Logos's own proof development -- the checker's soundness already uses
`native_decide` heavily, so the Lean compiler is in the trusted code base of the
theorem being composed with, independently of how this file discharges its own
decidable facts.  No report contains `sorryAx`. -/
#print axioms Hermeneia.Instances.CpcMini.unsat
#print axioms Hermeneia.Instances.CpcMini.M_wf
#print axioms Hermeneia.Instances.CpcMini.denote
#print axioms Hermeneia.Instances.CpcMini.native_refutation
