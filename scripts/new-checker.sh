#!/usr/bin/env bash

# Generate the Lake project for a proof checker. See --help.

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"
templates_dir="${repo_root}/templates"

usage() {
  cat <<'USAGE'
Usage: scripts/new-checker.sh [OPTION]...

Generate the Lake project for a proof checker, as <CHECKER>/<CALCULUS>/: a
package that builds, an executable that runs, and a place for the calculus to
go once there is one.

It is written under checkers/ in this repository by default, which is not kept
in git, so trying the generator out and working on the templates leaves nothing
behind. A checker being developed for its own sake belongs in its own
repository, which is what --out is for.

Defaults come from config.sh, and every option below overrides what is set
there. With none of them, the settings in that file are used as they stand.

Options:
  --checker NAME        the checker: the generated directory, the Lake package,
                        and, lowercased, the executable it builds
  --calculus NAME       the calculus: the Lean library under it
  --signature PATH      the Eunoia signature (.eo) to copy in
  --semantics PATH      the semantics of that signature (.eos) to copy in
  --smt-semantics PATH  the SMT-LIB semantics it is written against (.eos)
  --toolchain VERSION   the Lean toolchain the project pins
  --out DIR             where to write the project (default: checkers/ here)
  --force               delete and regenerate an existing project directory.
                        Everything under it goes, hand-written Lean included;
                        nothing is preserved across a regeneration.
  -h, --help            show this message

Both names are used verbatim as Lean names, so both must be upper camel case
identifiers: a letter, then letters and digits.

A signature or semantics file that is not named is written as a commented stub
to fill in, which is the expected state before a calculus has been settled on.

Examples:
  scripts/new-checker.sh
  scripts/new-checker.sh --checker Aletheia --calculus Lra
  scripts/new-checker.sh --calculus Lra --signature ~/sigs/Lra.eo
  scripts/new-checker.sh --checker Aletheia --out ~/aletheia
USAGE
}

# A leading ~ in --option=VALUE is not the shell's to expand: it does that at
# the start of a word, and there the word starts with --option. So the tilde
# arrives here as a character, and every option taking a path expands it the
# way the shell would have.
expand_tilde() {
  case "$1" in
    "~") printf '%s\n' "${HOME}" ;;
    "~/"*) printf '%s\n' "${HOME}/${1#\~/}" ;;
    *) printf '%s\n' "$1" ;;
  esac
}

# config.sh holds the defaults; the options below override it, so it is read
# first and each option assigns over what it set.
CHECKER=""
CALCULUS=""
SIGNATURE=""
SEMANTICS=""
SMT_SEMANTICS=""
TOOLCHAIN=""
OUT_DIR=""
# shellcheck source=../config.sh
[ -f "${repo_root}/config.sh" ] && . "${repo_root}/config.sh"

FORCE=0
while [ $# -gt 0 ]; do
  case "$1" in
    --checker) CHECKER="${2:?--checker requires a value}"; shift 2 ;;
    --checker=*) CHECKER="${1#*=}"; shift ;;
    --calculus) CALCULUS="${2:?--calculus requires a value}"; shift 2 ;;
    --calculus=*) CALCULUS="${1#*=}"; shift ;;
    --signature) SIGNATURE="${2:?--signature requires a value}"; shift 2 ;;
    --signature=*) SIGNATURE="${1#*=}"; shift ;;
    --semantics) SEMANTICS="${2:?--semantics requires a value}"; shift 2 ;;
    --semantics=*) SEMANTICS="${1#*=}"; shift ;;
    --smt-semantics) SMT_SEMANTICS="${2:?--smt-semantics requires a value}"; shift 2 ;;
    --smt-semantics=*) SMT_SEMANTICS="${1#*=}"; shift ;;
    --toolchain) TOOLCHAIN="${2:?--toolchain requires a value}"; shift 2 ;;
    --toolchain=*) TOOLCHAIN="${1#*=}"; shift ;;
    --out) OUT_DIR="${2:?--out requires a value}"; shift 2 ;;
    --out=*) OUT_DIR="${1#*=}"; shift ;;
    --force) FORCE=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unrecognized option $1" >&2; usage >&2; exit 2 ;;
  esac
done

SIGNATURE="$(expand_tilde "${SIGNATURE}")"
SEMANTICS="$(expand_tilde "${SEMANTICS}")"
SMT_SEMANTICS="$(expand_tilde "${SMT_SEMANTICS}")"
OUT_DIR="$(expand_tilde "${OUT_DIR}")"

# Both names become Lean names, and the checker also becomes a directory, so
# neither can be anything the two would not accept.
check_name() {
  local what="$1" name="$2"
  [ -n "${name}" ] || { echo "error: the ${what} name is empty. Set it in config.sh or with --${what}." >&2; exit 2; }
  [[ "${name}" =~ ^[A-Za-z][A-Za-z0-9]*$ ]] || {
    echo "error: the ${what} name '${name}' is not a Lean identifier: it must be" >&2
    echo "a letter followed by letters and digits." >&2
    exit 2
  }
}
check_name checker "${CHECKER}"
check_name calculus "${CALCULUS}"
[ -n "${TOOLCHAIN}" ] || { echo "error: no Lean toolchain. Set TOOLCHAIN in config.sh or use --toolchain." >&2; exit 2; }

for named in "${SIGNATURE}" "${SEMANTICS}" "${SMT_SEMANTICS}"; do
  [ -z "${named}" ] || [ -f "${named}" ] || {
    echo "error: ${named} not found." >&2
    exit 1
  }
done

EXE="$(printf '%s' "${CHECKER}" | tr '[:upper:]' '[:lower:]')"
# checkers/ here unless told otherwise; see the note on --out in config.sh.
OUT_DIR="${OUT_DIR:-${repo_root}/checkers}"
DEST="${OUT_DIR}/${CHECKER}"

if [ -d "${DEST}" ] && [ "${FORCE}" = "0" ]; then
  echo "error: ${DEST} already exists. Pass --force to overwrite it." >&2
  exit 1
fi

# How a generated path is named in the output: relative to this repository when
# it is inside it, and absolute when --out put it somewhere else, so what is
# printed is always a path that can be used from where the script was run.
rel() {
  case "$1" in
    "${repo_root}/"*) printf '%s\n' "${1#"${repo_root}/"}" ;;
    *) printf '%s\n' "$1" ;;
  esac
}

# Substitute the four names into a template. The values are Lean identifiers, a
# toolchain version and a lowercased identifier, so none of them contains a
# character sed would read as part of the replacement.
render() {
  local template="${templates_dir}/$1" out="$2"
  [ -f "${template}" ] || { echo "error: template ${template} is missing." >&2; exit 1; }
  mkdir -p "$(dirname "${out}")"
  sed -e "s|@CHECKER@|${CHECKER}|g" \
      -e "s|@CALCULUS@|${CALCULUS}|g" \
      -e "s|@EXE@|${EXE}|g" \
      -e "s|@TOOLCHAIN@|${TOOLCHAIN}|g" \
      "${template}" > "${out}"
}

# A file the user supplies is copied verbatim; one they do not is the rendered
# stub, so the project has the file either way and says in it what it is for.
install_or_stub() {
  local given="$1" template="$2" out="$3"
  if [ -n "${given}" ]; then
    mkdir -p "$(dirname "${out}")"
    cp "${given}" "${out}"
    echo "    $(rel "${out}")  <- ${given}"
  else
    render "${template}" "${out}"
    echo "    $(rel "${out}")  (stub)"
  fi
}

echo "==> Generating ${CHECKER}, a checker for ${CALCULUS}"
echo "    directory   ${DEST}"
echo "    executable  ${EXE}"
echo "    toolchain   ${TOOLCHAIN}"

rm -rf "${DEST}"
mkdir -p "${DEST}/${CALCULUS}" "${DEST}/signature"

render lakefile.toml.in   "${DEST}/lakefile.toml"
render lean-toolchain.in  "${DEST}/lean-toolchain"
render Main.lean.in       "${DEST}/Main.lean"
render Calculus.lean.in   "${DEST}/${CALCULUS}.lean"
render Basic.lean.in      "${DEST}/${CALCULUS}/Basic.lean"
render README.md.in       "${DEST}/README.md"

echo "==> Installing the signature and its semantics"
install_or_stub "${SIGNATURE}"     signature.eo.in  "${DEST}/signature/${CALCULUS}.eo"
install_or_stub "${SEMANTICS}"     semantics.eos.in "${DEST}/signature/${CALCULUS}.eos"
# The SMT-LIB semantics is the one file with no stub: leaving it out means the
# calculus is written against whatever base semantics the toolchain supplies,
# which is a choice rather than something left to fill in.
if [ -n "${SMT_SEMANTICS}" ]; then
  cp "${SMT_SEMANTICS}" "${DEST}/signature/smt.eos"
  echo "    $(rel "${DEST}/signature/smt.eos")  <- ${SMT_SEMANTICS}"
fi

cat <<DONE

==> Done.

Build it with:

  cd $(rel "${DEST}") && lake build

DONE
