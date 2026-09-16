#!/bin/sh
# Type-check Eos.lean, which is where the `#guard`s are.
#
#   ./check.sh [path-to-lean]
#
# Every claim in Eos.lean that can be run is a `#guard`, so a clean run is the
# whole of the check: the header half agreeing with the constructors of
# Cpc/SmtModelDefs.lean, and the behaviour half agreeing with the
# __smtx_model_eval_* of Cpc/SmtModel.lean, on the core symbols.
#
# There is no Lake project and there are no imports. The toolchain is the one
# Logos pins, because the generated Lean these guards are read against is built
# with it; any 4.33-or-later Lean should do.
set -e
here=$(dirname "$0")
LEAN=${1:-}

if [ -z "$LEAN" ]; then
  for candidate in \
      "$HOME/.elan/toolchains/leanprover--lean4---v4.33.0/bin/lean" \
      "$(command -v lean 2>/dev/null)"; do
    if [ -x "$candidate" ]; then LEAN=$candidate; break; fi
  done
fi

if [ -z "$LEAN" ] || [ ! -x "$LEAN" ]; then
  echo "no lean found; pass one: ./check.sh /path/to/lean" >&2
  exit 2
fi

echo "== $("$LEAN" --version)"
if "$LEAN" "$here/Eos.lean"; then
  echo "   ok   Eos.lean, and every #guard in it"
else
  echo "   FAIL Eos.lean" >&2
  exit 1
fi
