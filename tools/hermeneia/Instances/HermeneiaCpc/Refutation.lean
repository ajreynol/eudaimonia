import HermeneiaCpc.Example
import Cpc.Proofs.Checker

/-!
# Discharging the hypothesis

[`Example.lean`](Example.lean) proves its native theorem *conditional on*
`eo_satisfiability (argListAssumes F) false`. This file is everything needed to
remove that condition, and it is the only file in this instance that imports
CPC's soundness proof — 820 files and 691,928 lines, a build measured in hours.

Keeping it to these few lines is the point: the bridge is developed and
rechecked against the semantics alone, in about a minute, and pays the proof
development's build cost once, here.
-/

open Eo Smtm SmtEval
open Hermeneia.Cpc.Example

namespace Hermeneia.Cpc.Example

/-- Logos's conclusion for this proof. -/
theorem unsat : eo_satisfiability (argListAssumes F) false :=
  correct___eo_is_refutation F cmds transOk cmdsOk (eo_is_refutation.intro F cmds checked)

/-- The native theorem, unconditionally. -/
theorem refutation : ∀ b : Bool, ¬ (b = true ∧ (!b) = true) :=
  native_refutation unsat

end Hermeneia.Cpc.Example

#print axioms Hermeneia.Cpc.no_realizing_model
#print axioms Hermeneia.Cpc.Example.unsat
#print axioms Hermeneia.Cpc.Example.refutation
