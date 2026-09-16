#!/usr/bin/env bash
# Does the CPC that cvc5 emits under lean-smt's solver options check in Logos?
#
#   usage: run.sh <cvc5-binary> <logos-binary> [query-dir]
#
# For each query: run cvc5 with lean-smt's `defaultSolverOptions`
# (Smt/Reconstruct.lean), dump the CPC proof, strip cvc5's `unsat` line and the
# parentheses it wraps the proof in, and hand the result to `logos`.
#
# Reads only the query directory; writes only into a temporary directory it
# creates and removes. Prints one line per query and a summary.

set -uo pipefail

if [ $# -lt 2 ]; then
  echo "usage: $(basename "$0") <cvc5-binary> <logos-binary> [query-dir]" >&2
  exit 2
fi

cvc5="$1"
logos="$2"
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
queries="${3:-$here/queries}"

# lean-smt's defaultSolverOptions, as command-line flags.
opts=(
  --dag-thresh=0
  --simplification=none
  --enum-inst
  --enum-inst-interleave
  --cegqi-midpoint
  --proof-elim-subtypes
  --proof-granularity=dsl-rewrite
  --no-proof-chain-m-res
)

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

pass=0
total=0
for q in "$queries"/*.smt2; do
  name="$(basename "$q" .smt2)"
  total=$((total + 1))
  if ! timeout 300 "$cvc5" "${opts[@]}" --dump-proofs --proof-format=cpc "$q" \
       > "$work/$name.cpc" 2> "$work/$name.err"; then
    echo "$name: cvc5 failed -- $(head -c 120 "$work/$name.err")"
    continue
  fi
  # drop "unsat", the opening "(" and the closing ")"
  sed '1d' "$work/$name.cpc" | sed '1{/^($/d}' | sed '${/^)$/d}' > "$work/$name.proof"
  steps=$(grep -c '^(step\|^(step-pop' "$work/$name.proof")
  verdict=$(timeout 300 "$logos" "$work/$name.proof" 2>/dev/null | tail -1)
  [ "$verdict" = "correct" ] && pass=$((pass + 1))
  printf '%-12s steps=%-6s %s\n' "$name" "$steps" "${verdict:-<no verdict>}"
done

echo "---"
echo "$pass/$total correct"
[ "$pass" -eq "$total" ]
