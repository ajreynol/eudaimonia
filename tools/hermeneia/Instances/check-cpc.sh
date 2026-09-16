#!/usr/bin/env bash
# Check the CPC instance against a Logos checkout.
#
#   usage: check-cpc.sh [--full] <path-to-logos-checkout>
#
# Default: the bridge and the conditional example. These need only the SMT-LIB
# semantics and its type-preservation layer, which build in about a minute.
#
# --full: additionally `Refutation.lean`, which discharges the soundness
# hypothesis with `correct___eo_is_refutation` and therefore needs CPC's whole
# proof development -- 820 files, a build measured in hours (Logos's own CI does
# not build it either). Run it once, or after a regeneration.
#
# The instance imports a neighbouring checkout, so it cannot be built by
# `lake build` in this package; this script is the whole recipe. It writes to
# that checkout's `.lake/` build directory and to a temporary directory it
# removes. Point it at a scratch copy if even that is unwanted.

set -euo pipefail

full=0
case "${1:-}" in
  --full) full=1; shift ;;
esac

if [ $# -ne 1 ]; then
  echo "usage: $(basename "$0") [--full] <path-to-logos-checkout>" >&2
  exit 2
fi

logos="$1"
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -f "$logos/Cpc.lean" ]; then
  echo "error: $logos does not look like a Logos checkout (no Cpc.lean)" >&2
  exit 2
fi

out="$(mktemp -d)"
trap 'rm -rf "$out"' EXIT
mkdir -p "$out/HermeneiaCpc"

targets=(Cpc.Proofs.TypePreservation.Nonvacuity Cpc.Proofs.TypePreservation.Helpers Cpc.Proofs.Assumptions)
[ "$full" -eq 1 ] && targets+=(Cpc.Proofs.Checker)

cd "$logos"
echo "== building ${targets[*]}"
lake build "${targets[@]}"

run() {
  lake env bash -c "cd '$here' && LEAN_PATH=\"\$LEAN_PATH:$out\" lean --root='$here' $*"
}

echo "== HermeneiaCpc/Bridge.lean"
run "-o '$out/HermeneiaCpc/Bridge.olean' HermeneiaCpc/Bridge.lean"

echo "== HermeneiaCpc/Example.lean"
if [ "$full" -eq 1 ]; then
  run "-o '$out/HermeneiaCpc/Example.olean' HermeneiaCpc/Example.lean"
  echo "== HermeneiaCpc/Refutation.lean"
  run "HermeneiaCpc/Refutation.lean"
else
  run "HermeneiaCpc/Example.lean"
  echo "== skipping Refutation.lean (pass --full; needs CPC's whole proof development)"
fi
