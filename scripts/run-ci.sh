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
  --quiet, -q  only the one-line verdicts, not each step's output
  -h, --help   show this message

The Eunoia compiler is built once and shared by every configuration, which is
what keeps this under a few minutes.
USAGE
}

JOBS=""; KEEP=0; LIST=0; QUIET=0
while [ $# -gt 0 ]; do
  case "$1" in
    --jobs) JOBS="${2:?}"; shift 2 ;;
    --jobs=*) JOBS="${1#*=}"; shift ;;
    --keep) KEEP=1; shift ;;
    --list) LIST=1; shift ;;
    --quiet|-q) QUIET=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unrecognized option $1" >&2; usage >&2; exit 2 ;;
  esac
done
[ -n "${JOBS}" ] || JOBS="$(nproc 2>/dev/null || echo 4)"

# Every step's output is shown, so a failure in a generated checker is
# diagnosable from the log alone rather than only reproducible locally. On
# GitHub Actions each step is wrapped in a ::group::, which the runner renders
# as a collapsible section -- the detail is all there, folded away, and the
# one-line verdicts stay readable. `--quiet` restores the terse form.
in_gha() { [ -n "${GITHUB_ACTIONS:-}" ]; }

# run_in <title> <dir> <cmd...> -- run a command in a directory, showing its
# output indented under a heading. This is for the step whose output is the
# point: the generated checker's own CI. Returns the command's own status.
run_in() {
  local title="$1" dir="$2"; shift 2
  if [ "${QUIET}" = "1" ]; then
    ( cd "${dir}" && "$@" ) >/dev/null 2>&1
    return $?
  fi
  in_gha && echo "::group::${title}" || echo "  -- ${title}"
  ( cd "${dir}" && "$@" ) 2>&1 | sed 's/^/  | /'
  local rc=${PIPESTATUS[0]}
  in_gha && echo "::endgroup::"
  return "${rc}"
}

# run_logged <title> <dir> <cmd...> -- the same, for steps whose output is
# noise until it isn't: a C++ build, an install. Captured, and printed only if
# the step fails, so a red run is still diagnosable from the log alone.
run_logged() {
  local title="$1" dir="$2"; shift 2
  local log="${OUT}/.log"
  ( cd "${dir}" && "$@" ) >"${log}" 2>&1
  local rc=$?
  if [ "${rc}" -ne 0 ]; then
    in_gha && echo "::group::${title} (FAILED)" || echo "  -- ${title} (FAILED)"
    sed 's/^/  | /' "${log}" | tail -80
    in_gha && echo "::endgroup::"
  fi
  return "${rc}"
}

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
if ! run_logged "Eunoia compiler" "${OUT}/Shared" ./install/get-eo-compiler.sh --pinned --jobs "${JOBS}"; then
  echo "error: the compiler did not build." >&2; exit 1
fi
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
  if ! run_logged "${name}: install" "${OUT}/${name}" "./install/install-${lower}.sh" --jobs "${JOBS}"; then
    echo "  install: FAILED"; failed+=("${name}/install"); continue
  fi
  case "${opts}" in *--mini*)
    if ! run_logged "${name}: install --mini" "${OUT}/${name}" \
           "./install/install-${lower}.sh" --mini --jobs "${JOBS}"; then
      echo "  install --mini: FAILED"; failed+=("${name}/mini"); continue
    fi ;;
  esac

  # The deeper test: run the generated project's *own* CI, which is what a
  # user gets. It builds the default targets, compiles every module it ships,
  # runs the regression proofs, cross-checks them against ethos, and verifies
  # the package has not drifted from its signature. Its output is shown rather
  # than swallowed, so a failure here is diagnosable from the log -- and it
  # runs once, not twice.
  if ! run_in "${name}: its own CI" "${OUT}/${name}" ./scripts/run-ci.sh; then
    echo "  its own CI: FAILED"; failed+=("${name}"); continue
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
  if run_logged "Cpc: install" "${OUT}/Big" ./install/install-cpc.sh --jobs "${JOBS}"; then
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
