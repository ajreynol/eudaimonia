#!/usr/bin/env bash

# Generate checkers across option configurations and build them. See --help.

set -uo pipefail

usage() {
  cat <<'USAGE'
Usage: scripts/run-ci.sh [OPTION]...

Generate a checker for each configuration below, install its calculus, and then
**run that project's own CI**. This is the test suite of the generator: it does
not check that any proof is right, it checks that every option combination still
produces a project whose own checks pass.

Running the generated CI rather than a bespoke set of commands is deliberate --
it tests what a user actually gets, and it means a check added there is covered
here automatically.

Only the small examples are built. CPC is generated and installed but not built:
that takes minutes and 591 rule files, and nothing about it exercises the
generator that the small ones do not.

Options:
  --jobs N     parallel compile jobs (default: all processors)
  --keep       keep the generated checkers instead of deleting them
  --list       print the configurations and exit
  -h, --help   show this message

The Eunoia compiler is built once and shared by every configuration, which is
what keeps this under a few minutes.
USAGE
}

JOBS=""; KEEP=0; LIST=0
while [ $# -gt 0 ]; do
  case "$1" in
    --jobs) JOBS="${2:?}"; shift 2 ;;
    --jobs=*) JOBS="${1#*=}"; shift ;;
    --keep) KEEP=1; shift ;;
    --list) LIST=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unrecognized option $1" >&2; usage >&2; exit 2 ;;
  esac
done
[ -n "${JOBS}" ] || JOBS="$(nproc 2>/dev/null || echo 4)"

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${repo_root}"

# name : calculus : spec : extra options.  Each exists to reach something the
# others do not; a configuration that duplicates another's coverage is waste,
# because every one of these is a Lean build.
CONFIGS=(
  "Basic:Hello:examples/hello:"
  "Scoped:Scoped:examples/scoped:--mini"
  "Starter:Logic::--dummy-rule --mini"
  "NoTheorems:Hello:examples/hello:--theorems none"
  "SomeTheorems:Hello:examples/hello:--theorems nonvacuity,modelwf"
  "Renamed:Hello:examples/hello:--format-name Fmt --no-parser"
)

if [ "${LIST}" = "1" ]; then
  printf '%s\n' "${CONFIGS[@]}"
  exit 0
fi

OUT="${repo_root}/checkers/.ci"
rm -rf "${OUT}"; mkdir -p "${OUT}"
[ "${KEEP}" = "1" ] || trap 'rm -rf "${OUT}"' EXIT

# One compiler, shared. Building it per configuration would dominate the run.
echo "==> Building the Eunoia compiler once (shared by every configuration)"
./scripts/new-checker.sh --checker Shared --calculus Hello --spec examples/hello \
  --out "${OUT}" >/dev/null
( cd "${OUT}/Shared" && ./install/get-eo-compiler.sh --pinned --jobs "${JOBS}" ) >/dev/null 2>&1 || {
  echo "error: the compiler did not build." >&2; exit 1; }
SHARED_DEPS="${OUT}/Shared/install/deps"

failed=()
for cfg in "${CONFIGS[@]}"; do
  IFS=: read -r name calc spec opts <<< "${cfg}"
  echo
  echo "############ ${name} ############"
  start=$(date +%s)

  # shellcheck disable=SC2086
  specarg=""; [ -z "${spec}" ] || specarg="--spec ${spec}"
  if ! ./scripts/new-checker.sh --checker "${name}" --calculus "${calc}" \
       ${specarg} ${opts} --out "${OUT}" >/dev/null; then
    echo "  generate: FAILED"; failed+=("${name}/generate"); continue
  fi
  rm -rf "${OUT}/${name}/install/deps"
  ln -s "${SHARED_DEPS}" "${OUT}/${name}/install/deps"

  lower="$(printf '%s' "${calc}" | tr '[:upper:]' '[:lower:]')"
  if ! ( cd "${OUT}/${name}" && ./install/install-${lower}.sh --jobs "${JOBS}" ) >/dev/null 2>&1; then
    echo "  install: FAILED"; failed+=("${name}/install"); continue
  fi
  case "${opts}" in *--mini*)
    ( cd "${OUT}/${name}" && ./install/install-${lower}.sh --mini --jobs "${JOBS}" ) >/dev/null 2>&1 || {
      echo "  install --mini: FAILED"; failed+=("${name}/mini"); continue; } ;;
  esac

  # Every module the template ships has to compile. The generated rule
  # dispatcher is excluded on purpose: it imports the rule files, which are
  # written against names Proofs/RuleSupport/Support.lean is meant to supply and
  # does not -- see "Known limitations" in README.md.
  mods=$( cd "${OUT}/${name}" && find . -name '*.lean' \
            -not -path '*/.lake/*' -not -path '*/Rules/*' -not -name 'Main.lean' \
            -not -name 'RuleLemmas.lean' \
          | sed 's|^\./||; s|\.lean$||; s|/|.|g' | sort )
  # The deeper test: run the generated project's *own* CI, which is what a
  # user gets. It builds the default targets, compiles every module it ships,
  # runs the regression proofs, cross-checks them against ethos, and verifies
  # the package has not drifted from its signature.
  if ! ( cd "${OUT}/${name}" && ./scripts/run-ci.sh ) >/dev/null 2>&1; then
    echo "  its own CI: FAILED"
    ( cd "${OUT}/${name}" && ./scripts/run-ci.sh 2>&1 | grep -E -- "----|==> Failed" | sed 's/^/    /' )
    failed+=("${name}"); continue
  fi
  echo "  ok ($(( $(date +%s) - start ))s)"
done

# CPC is generated and installed but not built: minutes, and 591 rule files that
# exercise the compiler rather than the generator.
echo
echo "############ Cpc (generate and install only) ############"
start=$(date +%s)
if ./scripts/new-checker.sh --checker Big --calculus Cpc --spec examples/cpc \
     --out "${OUT}" >/dev/null; then
  rm -rf "${OUT}/Big/install/deps"; ln -s "${SHARED_DEPS}" "${OUT}/Big/install/deps"
  if ( cd "${OUT}/Big" && ./install/install-cpc.sh --jobs "${JOBS}" ) >/dev/null 2>&1; then
    n=$(ls "${OUT}/Big/Cpc/Proofs/Rules"/*.lean 2>/dev/null | wc -l)
    echo "  ok ($(( $(date +%s) - start ))s, ${n} rule files)"
  else
    echo "  install: FAILED"; failed+=("Cpc/install")
  fi
else
  echo "  generate: FAILED"; failed+=("Cpc/generate")
fi

echo
if [ "${#failed[@]}" -eq 0 ]; then
  echo "==> All ${#CONFIGS[@]} configurations passed, and Cpc generated."
  exit 0
fi
echo "==> Failed: ${failed[*]}"
exit 1
