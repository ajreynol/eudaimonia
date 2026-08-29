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

# The Lean toolchain the generated project pins.
TOOLCHAIN="leanprover/lean4:v4.33.0"
