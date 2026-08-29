# The project to generate. `scripts/new-checker.sh` reads this file; every
# setting here is also a command-line option of that script, which wins over
# what is set here.
#
# Two names decide the layout. The checker is the Lake project -- the directory,
# the package and the executable -- and the calculus is the library inside it
# that the proof rules live in, so a run generates <CHECKER>/<CALCULUS>/ under
# OUT_DIR. They are separate because one checker is a checker *of* a calculus.
#
# The defaults below are placeholders, and are meant to be replaced: they are
# deliberately not the names of any existing checker, so that what a run
# generates is never mistaken for one.
#
# Both names are used verbatim as Lean names, so both have to be upper camel
# case identifiers: a letter, then letters and digits.

# The checker: the generated directory, the Lake package, and (lowercased) the
# executable it builds.
CHECKER="MyChecker"

# The calculus: the Lean library under it, and the namespace its modules open.
CALCULUS="MyCalculus"

# The Eunoia signature defining the calculus, and the semantics files saying
# what its symbols mean. Each is copied into the generated project's
# signature/ directory; leave one empty to get a commented stub to fill in,
# which is the expected state before a calculus has been settled on.
SIGNATURE=""
SEMANTICS=""
SMT_SEMANTICS=""

# Where generated checkers are written. The default is inside this repository
# and is not kept in git, which suits trying the generator out and working on
# the templates. A checker being developed for its own sake belongs in its own
# repository: name that directory here, or with --out, and this one is not
# involved in it at all.
OUT_DIR=""

# ---------------------------------------------------------------------------
# The calculus profile.
#
# High-level facts about the calculus that decide what a generated checker
# needs, what it has to prove, and what it can inherit. Each is a yes/no
# question, each is also a --flag of scripts/new-checker.sh, and each is written
# into the generated project as install/defs/profile.conf.
#
# Answering `no` where the truth is `yes` does not break the build -- the
# calculus is what the signature says it is -- it makes the documentation and
# the scaffolding wrong. install-<calc>.sh re-checks the ones that are visible
# in compiled output and reports any disagreement.
#
# The defaults are the conservative answers: assume the calculus has the
# feature, so nothing is quietly left out.
# ---------------------------------------------------------------------------

# Rules that discharge assumptions (`scope`, compiling to step-pop).
PROFILE_SCOPES="yes"

# Rules that gather `:list` premises.
PROFILE_LIST_PREMISES="yes"

# Algebraic datatypes.
PROFILE_DATATYPES="yes"

# Binder-sensitive rules, needing the variable-stability invariant.
PROFILE_BINDERS="yes"

# A semantics that leans on a total order on values.
PROFILE_VALUE_ORDERING="yes"

# The greatest number of indices an operator takes (0-3; eoc's ladder stops
# at 3). Unused arities are still emitted, holding a placeholder constructor.
PROFILE_INDEXED_OPS="3"

# The generated parser configuration.
PROFILE_PARSER="yes"

# Whether install/defs/smt.eos is Logos's, unmodified, is not set here: it is
# a fact about the file, so the generator computes it.

# The Lean toolchain the generated project pins.
TOOLCHAIN="leanprover/lean4:v4.33.0"
