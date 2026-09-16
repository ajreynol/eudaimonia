#!/bin/sh
# Run the tutorial's proof tests against both signatures in this directory.
#
#   ./check.sh [path-to-ethos]
#
# `ethos` checks a proof against a Eunoia signature; it is not the framework's
# generated checker and does not produce the framework's four verdicts. Here a
# test either prints `correct` or is rejected with an error, and each
# test/<name>.expected says which of the two it must be.
set -e
ETHOS=${1:-ethos}
here=$(dirname "$0")
status=0

for sig in "$here"/Resolution.eo "$here"/Resolution-lists.eo; do
  echo "== $(basename "$sig")"
  for proof in "$here"/test/*.proof; do
    name=$(basename "$proof" .proof)
    want=$(cat "$here/test/$name.expected")
    if out=$("$ETHOS" --include="$sig" "$proof" 2>&1); then
      got=$(echo "$out" | tail -n 1)
    else
      got=rejected
    fi
    case "$got" in
      "$want") echo "   ok   $name ($want)" ;;
      *)       echo "   FAIL $name: wanted $want, got $got"; status=1 ;;
    esac
  done
done

exit $status
