#!/usr/bin/env bash
# Check the CpcMini instance against a Logos checkout.
#
# The instance imports Logos's generated CpcMini declarations, so it cannot be
# built by `lake build` in this package -- Hermeneia has no Lake dependencies
# and stays outside anyone else's build. This script is the whole recipe.
#
#   usage: check.sh <path-to-logos-checkout>
#
# It builds two CpcMini targets in that checkout and elaborates the instance
# against them. It writes only to that checkout's `.lake/` (a build directory,
# gitignored there) and to nothing else. Use a scratch copy of the checkout if
# even that is unwanted.

set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ $# -ne 1 ]; then
  echo "usage: $(basename "$0") <path-to-logos-checkout>" >&2
  exit 2
fi

logos="$1"
if [ ! -f "$logos/CpcMini.lean" ]; then
  echo "error: $logos does not look like a Logos checkout (no CpcMini.lean)" >&2
  exit 2
fi

cd "$logos"
echo "== building CpcMini soundness and model existence in $logos"
lake build CpcMini.Proofs.Checker CpcMini.Proofs.TypePreservation.Nonvacuity

echo "== elaborating $here/Refutation.lean"
lake env lean "$here/Refutation.lean"
