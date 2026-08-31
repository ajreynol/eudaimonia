#!/usr/bin/env bash
#
# Advance the pinned Eunoia compiler, and the files that are pinned with it.
#
# A generated checker is pinned to one commit of ethos (DEV_MODE=0 in
# install/get-eo-compiler.sh), because a checker built against a moving
# compiler cannot be regenerated identically later.
#
# The pin is not just the commit. install/defs/smt.eos is a *snapshot* of that
# commit's tools/eoc/semantics/smt.eos, passed back to the compiler with
# --smt-semantics. The semantics format is still changing, so a snapshot taken
# at one commit will not generally parse against another -- the two have to
# move together, which is what this script does.
#
# Modelled on scripts/bump-eoc-version.py in Logos, which does the same for a
# single package. This one covers the example specifications and the digest
# the calculus profile reports `logos-smt` from.
#
# It changes files and nothing else. Run the CI afterwards.
set -uo pipefail

usage() {
  cat <<'USAGE'
usage: scripts/bump-eoc.sh [--commit <sha>] [--dry-run]

  --commit <sha>  pin this commit instead of the head of ethosEoc3
  --dry-run       report what would change, write nothing

What moves together:

  templates/install/get-eo-compiler.sh.in   ETHOS_VERSION
  examples/*/smt.eos                        the SMT-LIB semantics snapshot
  examples/cpc/Cpc.eos                      CPC's semantics
  scripts/new-checker.sh                    LOGOS_SMT_DIGEST
  templates/install/install-sig.sh.in       the same digest, for `logos-smt`
USAGE
}

COMMIT=""; DRY=0
while [ $# -gt 0 ]; do
  case "$1" in
    --commit) COMMIT="${2:?--commit requires a value}"; shift 2 ;;
    --commit=*) COMMIT="${1#*=}"; shift ;;
    --dry-run) DRY=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unrecognized option $1" >&2; usage >&2; exit 2 ;;
  esac
done

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${repo_root}"

BRANCH="ethosEoc3"
REMOTE="https://github.com/cvc5/ethos.git"
RAW="https://raw.githubusercontent.com/cvc5/ethos"

PIN_FILE="templates/install/get-eo-compiler.sh.in"
DIGEST_FILES=(scripts/new-checker.sh templates/install/install-sig.sh.in)

if [ -z "${COMMIT}" ]; then
  echo "==> Resolving the head of ${BRANCH}"
  COMMIT="$(git ls-remote --exit-code "${REMOTE}" "refs/heads/${BRANCH}" 2>/dev/null | cut -f1)"
  [ -n "${COMMIT}" ] || { echo "error: could not read ${BRANCH} from ${REMOTE}" >&2; exit 1; }
fi
case "${COMMIT}" in
  [0-9a-f]*) [ "${#COMMIT}" = 40 ] || { echo "error: --commit wants a full 40-character sha" >&2; exit 1; } ;;
  *) echo "error: --commit wants a full 40-character sha" >&2; exit 1 ;;
esac
echo "    ${COMMIT}"

# The current pin, so an already-current tree can say so rather than churn.
OLD_PIN="$(sed -n 's/^ETHOS_VERSION="\([0-9a-f]\{40\}\)"$/\1/p' "${PIN_FILE}")"
[ -n "${OLD_PIN}" ] || { echo "error: no ETHOS_VERSION found in ${PIN_FILE}" >&2; exit 1; }

tmp="$(mktemp -d)"
trap 'rm -rf "${tmp}"' EXIT

# md5 by whichever tool exists: md5sum is GNU, md5 is what macOS ships, and
# openssl is the fallback. Without one the digest checks are skipped rather than
# reporting a wrong answer.
file_digest() {
  if command -v md5sum >/dev/null 2>&1; then md5sum < "$1" | cut -d' ' -f1
  elif command -v md5 >/dev/null 2>&1; then md5 -q < "$1"
  elif command -v openssl >/dev/null 2>&1; then openssl md5 < "$1" | sed 's/.*= *//'
  else return 1
  fi
}

fetch() { # fetch <path-in-ethos> <destination>
  local path="$1" dest="$2"
  curl -sSfL "${RAW}/${COMMIT}/${path}" -o "${dest}" \
    || { echo "error: could not download ${path} at ${COMMIT}" >&2; exit 1; }
}

echo "==> Downloading the semantics at that commit"
fetch tools/eoc/semantics/smt.eos "${tmp}/smt.eos"
fetch tools/eoc/semantics/development-cpc.eos "${tmp}/Cpc.eos"

# Both files are used verbatim, so a snapshot can be checked against upstream by
# digest. Verify they are what they claim before overwriting anything.
grep -q 'eo_to_smt' "${tmp}/Cpc.eos" \
  || { echo "error: development-cpc.eos does not look like CPC semantics" >&2; exit 1; }
grep -q 'SmtValue' "${tmp}/smt.eos" \
  || { echo "error: smt.eos does not look like the SMT-LIB semantics" >&2; exit 1; }

NEW_DIGEST="$(file_digest "${tmp}/smt.eos")" || {
  echo "error: no md5sum, md5 or openssl on PATH; cannot compute the digest." >&2; exit 1; }
OLD_DIGEST="$(sed -n 's/^LOGOS_SMT_DIGEST="\([0-9a-f]*\)"$/\1/p' scripts/new-checker.sh)"

changed=0
report() { # report <path> <changed?>
  if [ "$2" = 1 ]; then printf '    %-42s updated\n' "$1"; changed=1
  else printf '    %-42s unchanged\n' "$1"; fi
}

echo "==> Files"
if [ "${DRY}" = 1 ]; then
  [ "${OLD_PIN}" = "${COMMIT}" ] && report "${PIN_FILE}" 0 || report "${PIN_FILE}" 1
  for f in examples/*/smt.eos; do
    cmp -s "${tmp}/smt.eos" "${f}" && report "${f}" 0 || report "${f}" 1
  done
  cmp -s "${tmp}/Cpc.eos" examples/cpc/Cpc.eos && report examples/cpc/Cpc.eos 0 || report examples/cpc/Cpc.eos 1
  [ "${OLD_DIGEST}" = "${NEW_DIGEST}" ] && report "the logos-smt digest" 0 || report "the logos-smt digest" 1
  echo
  echo "Dry run: nothing was written."
  exit 0
fi

if [ "${OLD_PIN}" != "${COMMIT}" ]; then
  # -i.bak, not bare -i: BSD sed reads -i's argument as the backup suffix, so
  # the GNU spelling silently eats the expression on macOS.
  sed -i.bak "s/^ETHOS_VERSION=\"${OLD_PIN}\"$/ETHOS_VERSION=\"${COMMIT}\"/" "${PIN_FILE}"
  rm -f "${PIN_FILE}.bak"
  grep -q "ETHOS_VERSION=\"${COMMIT}\"" "${PIN_FILE}" \
    || { echo "error: the pin in ${PIN_FILE} did not take" >&2; exit 1; }
  report "${PIN_FILE}" 1
else
  report "${PIN_FILE}" 0
fi

for f in examples/*/smt.eos; do
  if cmp -s "${tmp}/smt.eos" "${f}"; then report "${f}" 0; else cp "${tmp}/smt.eos" "${f}"; report "${f}" 1; fi
done
if cmp -s "${tmp}/Cpc.eos" examples/cpc/Cpc.eos; then
  report examples/cpc/Cpc.eos 0
else
  cp "${tmp}/Cpc.eos" examples/cpc/Cpc.eos; report examples/cpc/Cpc.eos 1
fi

if [ "${OLD_DIGEST}" != "${NEW_DIGEST}" ]; then
  for f in "${DIGEST_FILES[@]}"; do
    sed -i.bak "s/${OLD_DIGEST}/${NEW_DIGEST}/g" "${f}"
    rm -f "${f}.bak"
    grep -q "${NEW_DIGEST}" "${f}" || { echo "error: the digest in ${f} did not take" >&2; exit 1; }
  done
  report "the logos-smt digest" 1
else
  report "the logos-smt digest" 0
fi

echo
if [ "${changed}" = 0 ]; then
  echo "==> Already at ${COMMIT}. Nothing to do."
  exit 0
fi

cat <<NEXT
==> Bumped to ${COMMIT}.

Next, and not optional -- the semantics moved, so what the compiler generates
may have moved with it:

  scripts/run-ci.sh

Anything a generated checker ships *proven* is proven against the model this
semantics generates: ModelWf.lean and Proofs/{TypeDefaults,TypePredicates,
Canonicity}.lean. If the model changed, those proofs are about the old one and
CI is what says so.
NEXT
