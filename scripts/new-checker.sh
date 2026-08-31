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
  --spec DIR            a directory holding all three of the below, named by
                        convention: <CALCULUS>.eo, <CALCULUS>.eos and smt.eos.
                        A file missing from it is a stub, and any of the three
                        options below overrides what it found
  --signature PATH      the Eunoia signature (.eo) to copy in
  --semantics PATH      the semantics of that signature (.eos) to copy in
  --smt-semantics PATH  the SMT-LIB semantics it is written against (.eos)
  --toolchain VERSION   the Lean toolchain the project pins
  --out DIR             where to write the project (default: checkers/ here)

 The calculus profile -- high-level facts about the calculus that decide what
 the generated checker needs, what it must prove, and what it can inherit. Each
 is recorded in install/defs/profile.conf, and install-<calc>.sh re-checks the
 ones visible in compiled output. Defaults are the conservative answers.

  --[no-]scopes         rules that discharge assumptions (`scope`/step-pop)
  --[no-]list-premises  rules that gather `:list` premises
  --[no-]datatypes      algebraic datatypes
  --[no-]binders        binder-sensitive rules (instantiate, skolemize, ...)
  --[no-]value-ordering a semantics leaning on a total order on values
  --[no-]parser         install the generated parser configuration
  --indexed-ops N       greatest number of indices an operator takes (0-3)

 Development scaffolding -- what the generated project contains, rather than
 facts about the calculus:

  --[no-]mini           also generate <CALCULUS>Mini: the same calculus reduced
                        to a few rules, so proofs about the checker can be
                        developed against something that builds in seconds
  --mini-rules "A B"    the rules that reduced package keeps. Taken from
                        <spec>/mini-rules when a --spec directory has one
  --[no-]hygiene-ci     whether CI rejects `sorry` from the first commit
  --theorems LIST       which front-end theorems to include, comma-separated
                        from: translation, nonvacuity, canonicity, modelwf.
                        `all` (the default) or `none`. Type preservation and
                        the invariant slot are always generated
  --dummy-rule          with no signature given, write a working starter
                        instead of a commented stub: a signature with one rule,
                        its semantics, and regression proofs covering every
                        verdict. The result compiles and runs, so a new calculus
                        starts from something that works rather than nothing
  --format-name NAME    the library that reads the input proof format
                        (default: Eunoia, which is what the format is called)
  --force               regenerate an existing project directory. It is
                        deleted and written again, so this replaces the
                        scaffolding and nothing is carried across. It refuses
                        if the directory holds rule proofs or a git repository,
                        since those cannot be put back
  --clobber             delete an existing project directory whatever is in it.
                        This is how to start over, and it is not recoverable
  -h, --help            show this message

Both names are used verbatim as Lean names, so both must be upper camel case
identifiers: a letter, then letters and digits.

A signature or semantics file that is not named is written as a commented stub
to fill in, which is the expected state before a calculus has been settled on.

Examples:
  scripts/new-checker.sh
  scripts/new-checker.sh --checker Apodeixis --calculus Lra
  scripts/new-checker.sh --calculus Lra --signature ~/sigs/Lra.eo
  scripts/new-checker.sh --checker Apodeixis --out ~/apodeixis
  scripts/new-checker.sh --checker Logos --calculus Cpc --spec examples/cpc
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
SPEC_DIR=""
PROFILE_SCOPES="${PROFILE_SCOPES:-yes}"
PROFILE_LIST_PREMISES="${PROFILE_LIST_PREMISES:-yes}"
PROFILE_DATATYPES="${PROFILE_DATATYPES:-yes}"
PROFILE_BINDERS="${PROFILE_BINDERS:-yes}"
PROFILE_VALUE_ORDERING="${PROFILE_VALUE_ORDERING:-yes}"
PROFILE_PARSER="${PROFILE_PARSER:-yes}"
PROFILE_INDEXED_OPS="${PROFILE_INDEXED_OPS:-3}"
MINI="${MINI:-no}"
MINI_RULES="${MINI_RULES:-}"
HYGIENE_CI="${HYGIENE_CI:-no}"
FORMAT="${FORMAT:-Eunoia}"
THEOREMS="${THEOREMS:-all}"
DUMMY_RULE="${DUMMY_RULE:-no}"
# shellcheck source=../config.sh
[ -f "${repo_root}/config.sh" ] && . "${repo_root}/config.sh"

FORCE=0
CLOBBER=0
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
    --scopes) PROFILE_SCOPES=yes; shift ;;
    --no-scopes) PROFILE_SCOPES=no; shift ;;
    --list-premises) PROFILE_LIST_PREMISES=yes; shift ;;
    --no-list-premises) PROFILE_LIST_PREMISES=no; shift ;;
    --datatypes) PROFILE_DATATYPES=yes; shift ;;
    --no-datatypes) PROFILE_DATATYPES=no; shift ;;
    --binders) PROFILE_BINDERS=yes; shift ;;
    --no-binders) PROFILE_BINDERS=no; shift ;;
    --value-ordering) PROFILE_VALUE_ORDERING=yes; shift ;;
    --no-value-ordering) PROFILE_VALUE_ORDERING=no; shift ;;
    --indexed-ops) PROFILE_INDEXED_OPS="${2:?--indexed-ops requires a value}"; shift 2 ;;
    --indexed-ops=*) PROFILE_INDEXED_OPS="${1#*=}"; shift ;;
    --mini) MINI=yes; shift ;;
    --no-mini) MINI=no; shift ;;
    --mini-rules) MINI_RULES="${2:?--mini-rules requires a value}"; MINI=yes; shift 2 ;;
    --mini-rules=*) MINI_RULES="${1#*=}"; MINI=yes; shift ;;
    --dummy-rule) DUMMY_RULE=yes; shift ;;
    --no-dummy-rule) DUMMY_RULE=no; shift ;;
    --theorems) THEOREMS="${2:?--theorems requires a value}"; shift 2 ;;
    --theorems=*) THEOREMS="${1#*=}"; shift ;;
    --format-name) FORMAT="${2:?--format-name requires a value}"; shift 2 ;;
    --format-name=*) FORMAT="${1#*=}"; shift ;;
    --hygiene-ci) HYGIENE_CI=yes; shift ;;
    --no-hygiene-ci) HYGIENE_CI=no; shift ;;
    --parser) PROFILE_PARSER=yes; shift ;;
    --no-parser) PROFILE_PARSER=no; shift ;;
    --spec) SPEC_DIR="${2:?--spec requires a value}"; shift 2 ;;
    --spec=*) SPEC_DIR="${1#*=}"; shift ;;
    --force) FORCE=1; shift ;;
    --clobber) CLOBBER=1; FORCE=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unrecognized option $1" >&2; usage >&2; exit 2 ;;
  esac
done

SIGNATURE="$(expand_tilde "${SIGNATURE}")"
SEMANTICS="$(expand_tilde "${SEMANTICS}")"
SMT_SEMANTICS="$(expand_tilde "${SMT_SEMANTICS}")"
OUT_DIR="$(expand_tilde "${OUT_DIR}")"
SPEC_DIR="$(expand_tilde "${SPEC_DIR}")"

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
check_name format "${FORMAT}"
if [ "${FORMAT}" = "${CALCULUS}" ] || [ "${FORMAT}" = "${CHECKER}" ]; then
  echo "error: --format-name ${FORMAT} collides with the ${CHECKER}/${CALCULUS} names." >&2
  echo "The format library and the calculus library are separate Lake targets," >&2
  echo "so they cannot share a name. Pick another." >&2
  exit 2
fi
[ -n "${TOOLCHAIN}" ] || { echo "error: no Lean toolchain. Set TOOLCHAIN in config.sh or use --toolchain." >&2; exit 2; }

# A specification is a signature and the two semantics it is read against, and
# --spec is the three of them named at once, by the convention the example in
# examples/cpc follows. It only fills a blank: naming one of the three
# explicitly overrides what the directory holds, and a file the directory does
# not have is left blank, so it becomes a stub like any other.
if [ -n "${SPEC_DIR}" ]; then
  [ -d "${SPEC_DIR}" ] || { echo "error: --spec directory ${SPEC_DIR} not found." >&2; exit 1; }
  [ -n "${SIGNATURE}" ]     || [ ! -f "${SPEC_DIR}/${CALCULUS}.eo" ]  || SIGNATURE="${SPEC_DIR}/${CALCULUS}.eo"
  [ -n "${SEMANTICS}" ]     || [ ! -f "${SPEC_DIR}/${CALCULUS}.eos" ] || SEMANTICS="${SPEC_DIR}/${CALCULUS}.eos"
  [ -n "${SMT_SEMANTICS}" ] || [ ! -f "${SPEC_DIR}/smt.eos" ]         || SMT_SEMANTICS="${SPEC_DIR}/smt.eos"
  if [ -z "${SIGNATURE}${SEMANTICS}${SMT_SEMANTICS}" ]; then
    echo "error: ${SPEC_DIR} holds none of ${CALCULUS}.eo, ${CALCULUS}.eos or smt.eos." >&2
    echo "A --spec directory names its files after the calculus; check --calculus." >&2
    exit 1
  fi
fi

# Which rules a reduced package keeps is a fact about the calculus, so a
# specification directory can name them, as it can carry its own tests.
if [ -z "${MINI_RULES}" ] && [ -n "${SPEC_DIR}" ] && [ -f "${SPEC_DIR}/mini-rules" ]; then
  MINI_RULES="$(tr '\n' ' ' < "${SPEC_DIR}/mini-rules" | tr -s ' ')"
fi
# The starter signature knows its own rule, so a starter project can have a
# reduced package without being told anything.
if [ -z "${MINI_RULES}" ] && [ "${DUMMY_RULE}" = "yes" ] && [ -z "${SIGNATURE}" ]; then
  MINI_RULES="$(tr -d '\n' < "${script_dir}/../templates/starter/mini-rules.in")"
fi

for named in "${SIGNATURE}" "${SEMANTICS}" "${SMT_SEMANTICS}"; do
  [ -z "${named}" ] || [ -f "${named}" ] || {
    echo "error: ${named} not found." >&2
    exit 1
  }
done

# How a generated path is named in the output: relative to this repository when
# it is inside it, and absolute when --out put it somewhere else, so what is
# printed is always a path that can be used from where the script was run.
rel() {
  case "$1" in
    "${repo_root}/"*) printf '%s\n' "${1#"${repo_root}/"}" ;;
    *) printf '%s\n' "$1" ;;
  esac
}

# The digest of the SMT-LIB semantics Logos is verified against, so a generated
# checker can tell whether the one it was given is that file unmodified. If it
# is, results Logos proves about SMT-LIB itself are candidates to reuse.
LOGOS_SMT_DIGEST="b3e8d1005cd5d4157647b13c24310ac6"

# Where a generated checker points for the documentation that is not its own.
# Anything that describes checkers in general -- the anatomy, the design
# principles, what each `sorry` costs, what is not done yet -- lives in
# Eudaimonia and evolves there, so a generated checker links rather than
# carrying a copy that goes stale the day it is written.
EUDAIMONIA="https://github.com/ajreynol/eudaimonia"

EXE="$(printf '%s' "${CHECKER}" | tr '[:upper:]' '[:lower:]')"
CALCLOWER="$(printf '%s' "${CALCULUS}" | tr '[:upper:]' '[:lower:]')"
MINI_CALC="${CALCULUS}Mini"
# checkers/ here unless told otherwise; see the note on --out in config.sh.
OUT_DIR="${OUT_DIR:-${repo_root}/checkers}"
DEST="${OUT_DIR}/${CHECKER}"

if [ -d "${DEST}" ] && [ "${FORCE}" = "0" ] && [ "${CLOBBER}" = "0" ]; then
  echo "error: ${DEST} already exists. Pass --force to regenerate it." >&2
  exit 1
fi

# Regenerating writes the scaffolding again, and the scaffolding is all it is
# meant to replace. A checker that has been worked in holds things this cannot
# put back -- discharged rule proofs above all -- so it refuses rather than
# deleting them, and says what it found. Refreshing the *calculus* of an
# existing checker is its own installer's job, not this script's.
if [ -d "${DEST}" ] && [ "${CLOBBER}" = "0" ]; then
  at_risk=()
  rules="$(find "${DEST}/${CALCULUS}/Proofs/Rules" -name '*.lean' 2>/dev/null | wc -l | tr -d ' ')"
  [ "${rules}" = "0" ] || at_risk+=("${rules} rule proof(s) under ${CALCULUS}/Proofs/Rules/")
  [ ! -d "${DEST}/.git" ] || at_risk+=("a git repository")
  if [ "${#at_risk[@]}" -gt 0 ]; then
    echo "error: ${DEST} has been worked in. It holds:" >&2
    printf '  %s\n' "${at_risk[@]}" >&2
    echo >&2
    echo "Regenerating deletes the directory, so this would destroy them." >&2
    echo >&2
    echo "To refresh the calculus from its signature instead, which keeps every" >&2
    echo "proof, use that checker's own installer:" >&2
    echo >&2
    echo "  cd $(rel "${DEST}") && install/install-${CALCLOWER}.sh" >&2
    echo >&2
    echo "To start over anyway and lose the above, pass --clobber." >&2
    exit 1
  fi
fi

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
      -e "s|@CALCLOWER@|${CALCLOWER}|g" \
      -e "s|@MINI@|${MINI_CALC}|g" \
      -e "s|@FORMAT@|${FORMAT}|g" \
      -e "s|@MINI_RULES@|${MINI_RULES}|g" \
      -e "s|@EUDAIMONIA@|${EUDAIMONIA}|g" \
      -e "s|@TOOLCHAIN@|${TOOLCHAIN}|g" \
      "${template}" > "${out}"
}

# Render a template that is a script, and make it runnable.
render_exe() {
  render "$1" "$2"
  chmod +x "$2"
}

# A file the user supplies is copied verbatim; one they do not is the rendered
# stub, so the project has the file either way and says in it what it is for.
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

# A signature is normally a *tree*: a root .eo that pulls in theories, programs
# and rule files with (include ...), laid out however its author chose. That is
# the shape a signature is written in, and the framework keeps it -- the files
# are copied into install/defs/ with their relative layout intact, so the
# includes still resolve and the project stays self-contained.
#
# Nothing is flattened and nothing is cached. install/defs/<Calculus>.eo becomes
# a one-line root naming the signature's own root, so the installer has the
# fixed entry point it expects without the tree being rewritten.
copy_signature_tree() {
  local sig="$1" dest_dir="$2" root_name="$3"
  python3 - "${sig}" "${dest_dir}" "${root_name}" <<'TREE'
import os, re, shutil, sys

sig, dest_dir, root_name = sys.argv[1], sys.argv[2], sys.argv[3]
INCLUDE = re.compile(r'^\s*\((?:include|reference)\s+"([^"]+)"')

# The include closure, following relative paths from each file's own directory.
seen, order, stack = set(), [], [os.path.abspath(sig)]
missing = []
while stack:
    path = stack.pop()
    if path in seen:
        continue
    seen.add(path)
    order.append(path)
    try:
        with open(path, encoding='utf-8') as fh:
            text = fh.read()
    except OSError:
        continue
    for line in text.splitlines():
        m = INCLUDE.match(line)
        if not m:
            continue
        target = os.path.normpath(os.path.join(os.path.dirname(path), m.group(1)))
        if os.path.isfile(target):
            stack.append(target)
        else:
            missing.append((path, m.group(1)))

if missing:
    for owner, name in missing:
        sys.stderr.write("error: %s includes %s, which does not exist\n" % (owner, name))
    sys.exit(1)

# Lay the tree out under a common base so the relative includes still resolve.
base = os.path.dirname(os.path.commonpath(order)) if len(order) > 1 else os.path.dirname(order[0])
if len(order) > 1:
    base = os.path.commonpath([os.path.dirname(p) for p in order])

for path in order:
    rel = os.path.relpath(path, base)
    out = os.path.join(dest_dir, rel)
    os.makedirs(os.path.dirname(out), exist_ok=True)
    shutil.copyfile(path, out)

# The fixed entry point the installer expects, naming the signature's own root.
root_rel = os.path.relpath(os.path.abspath(sig), base)
with open(os.path.join(dest_dir, root_name), 'w', encoding='utf-8') as fh:
    fh.write('; The signature of this calculus. Its own root is %s;\n'
             '; this file exists so the installer has a fixed entry point.\n'
             '(include "%s")\n' % (root_rel, root_rel))
print("%d" % len(order))
TREE
}


echo "==> Generating ${CHECKER}, a checker for ${CALCULUS}"
echo "    directory   ${DEST}"
echo "    executable  ${EXE}"
echo "    toolchain   ${TOOLCHAIN}"

rm -rf "${DEST}"
mkdir -p "${DEST}/${CALCULUS}/Proofs/Rules" "${DEST}/${CALCULUS}/Proofs/RuleSupport" "${DEST}/${CALCULUS}/Proofs/Invariants" \
         "${DEST}/install/defs" "${DEST}/${FORMAT}" \
         "${DEST}/scripts" "${DEST}/docs" "${DEST}/test/regress" \
         "${DEST}/.github/workflows"

# The reduced package is a second library, and only when there is one.
if [ "${MINI}" = "yes" ]; then
  MINI_LIB="$(printf '%s\n' \
    "# The reduced calculus: the same signature with a few rules, for developing" \
    "# proofs against something that builds in seconds. See ${MINI_CALC}.lean." \
    "[[lean_lib]]" \
    "name = \"${MINI_CALC}\"" \
    "")"
  MINI_TARGET=", \"${MINI_CALC}\""
else
  MINI_LIB=""
  MINI_TARGET=""
fi
render lakefile.toml.in   "${DEST}/lakefile.toml"
# Substituted after rendering: the value is multi-line, which sed cannot carry
# through a s|| replacement.
python3 - "${DEST}/lakefile.toml" "${MINI_LIB}" "${MINI_TARGET}" "${FORMAT}" <<'PYLAKE'
import sys, pathlib
path, lib, target, fmt = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
p = pathlib.Path(path); t = p.read_text()
t = t.replace("@MINI_LIB@", lib)
# Keyed on the format library's actual name, which --format-name can change.
anchor = 'defaultTargets = ["%s", ' % fmt
assert anchor in t, "lakefile default targets not found"
t = t.replace(anchor, 'defaultTargets = ["%s"%s, ' % (fmt, target))
p.write_text(t)
PYLAKE
render lean-toolchain.in  "${DEST}/lean-toolchain"
render Main.lean.in       "${DEST}/Main.lean"
render Root.lean.in       "${DEST}/${CALCULUS}.lean"
render README.md.in       "${DEST}/README.md"

# The package, in the layout Logos's install/install-cpc.sh produces: the
# modules the signature compiler writes, and the hand-written ones it leaves
# alone. Each is a stub saying what belongs in it, which one it corresponds to
# in Logos, and which of the two kinds it is; the banner a stub carries is the
# difference, since a regeneration overwrites the one kind and not the other.
#
# Two of them are named after the checker rather than fixed, because that is
# what they are: the core checker and the term datatype it is written over.
# Logos calls them Cpc/Logos.lean and Cpc/LogosTerm.lean.
# Reading the Eunoia proof format. Hand-written, calculus-independent, and the
# thing the generated operator table plugs into.
render eunoia/Root.lean.in    "${DEST}/${FORMAT}.lean"
render eunoia/Sexp.lean.in    "${DEST}/${FORMAT}/Sexp.lean"
render eunoia/Parser.lean.in  "${DEST}/${FORMAT}/Parser.lean"

render pkg/SmtEval.lean.in        "${DEST}/${CALCULUS}/SmtEval.lean"
render pkg/Term.lean.in           "${DEST}/${CALCULUS}/${CHECKER}Term.lean"
render pkg/SmtModelDefs.lean.in   "${DEST}/${CALCULUS}/SmtModelDefs.lean"
render pkg/SmtValueOrder.lean.in  "${DEST}/${CALCULUS}/SmtValueOrder.lean"
render pkg/SmtModel.lean.in       "${DEST}/${CALCULUS}/SmtModel.lean"
render pkg/Spec.lean.in           "${DEST}/${CALCULUS}/Spec.lean"
render pkg/Checker.lean.in        "${DEST}/${CALCULUS}/${CHECKER}.lean"
render pkg/Parser.lean.in         "${DEST}/${CALCULUS}/Parser.lean"
render pkg/Api.lean.in            "${DEST}/${CALCULUS}/Api.lean"
render pkg/ApiChecks.lean.in      "${DEST}/${CALCULUS}/ApiChecks.lean"
render pkg/ApiCorrect.lean.in     "${DEST}/${CALCULUS}/ApiCorrect.lean"
render pkg/Diagnostics.lean.in    "${DEST}/${CALCULUS}/Diagnostics.lean"

render pkg/Proofs/Assumptions.lean.in  "${DEST}/${CALCULUS}/Proofs/Assumptions.lean"
render pkg/Proofs/CheckerCore.lean.in  "${DEST}/${CALCULUS}/Proofs/CheckerCore.lean"
render pkg/Proofs/RuleLemmas.lean.in   "${DEST}/${CALCULUS}/Proofs/RuleLemmas.lean"
render pkg/Proofs/Checker.lean.in      "${DEST}/${CALCULUS}/Proofs/Checker.lean"
# The front-end theorems: what the rule proofs stand on. The invariant slot and
# type preservation are always generated; the rest are opt-out, because a
# checker may not owe them -- a calculus whose translation is total needs no
# translation bridge, and one over Booleans alone owes little canonicity.
#
# Each is a leaf, importing none of the others. That is deliberate: this package
# builds with warnings as errors, so a `sorry` in one would otherwise stop the
# rest from building and they could not be worked on independently.
render pkg/Proofs/Invariants/Extra.lean.in \
       "${DEST}/${CALCULUS}/Proofs/Invariants/Extra.lean"
# Ported from Logos and proven: measured there to be byte-identical across two
# genuinely different calculi, and depending on nothing but the generated
# SmtModel. Shipped finished rather than stubbed.
render pkg/Proofs/TypePredicates.lean.in \
       "${DEST}/${CALCULUS}/Proofs/TypePredicates.lean"
render pkg/Proofs/TypeDefaults.lean.in \
       "${DEST}/${CALCULUS}/Proofs/TypeDefaults.lean"
render pkg/Proofs/TypePreservation.lean.in \
       "${DEST}/${CALCULUS}/Proofs/TypePreservation.lean"
case ",${THEOREMS}," in *,all,*|*,none,*) ;; esac
want_theorem() {
  case "${THEOREMS}" in
    all) return 0 ;;
    none) return 1 ;;
    *) case ",${THEOREMS}," in *",$1,"*) return 0 ;; *) return 1 ;; esac ;;
  esac
}
want_theorem modelwf      && render pkg/ModelWf.lean.in \
       "${DEST}/${CALCULUS}/ModelWf.lean" || true
want_theorem translation  && render pkg/Proofs/TranslationTypePreservation.lean.in \
       "${DEST}/${CALCULUS}/Proofs/TranslationTypePreservation.lean" || true
want_theorem nonvacuity   && render pkg/Proofs/NonVacuity.lean.in \
       "${DEST}/${CALCULUS}/Proofs/NonVacuity.lean" || true
want_theorem canonicity   && render pkg/Proofs/Canonicity.lean.in \
       "${DEST}/${CALCULUS}/Proofs/Canonicity.lean" || true
render pkg/Proofs/RuleSupport/Support.lean.in \
       "${DEST}/${CALCULUS}/Proofs/RuleSupport/Support.lean"
render pkg/Proofs/Rules/README.md.in   "${DEST}/${CALCULUS}/Proofs/Rules/README.md"

# The development infrastructure, in the shape Logos has it: the checker owns
# the compiler that regenerates it, the scripts that build and check it, and
# the documentation of its own calculus. A generated directory is a project to
# work in, not only a package to build.
if [ "${MINI}" = "yes" ]; then
  echo "==> Generating ${MINI_CALC}, the reduced package"
  mkdir -p "${DEST}/${MINI_CALC}/Proofs/Rules" "${DEST}/${MINI_CALC}/Proofs/RuleSupport" \
           "${DEST}/${MINI_CALC}/Proofs/Invariants"
  render MiniRoot.lean.in "${DEST}/${MINI_CALC}.lean"
  # The same modules as the full package, under the reduced name. Api*, Parser
  # and Diagnostics are left out: nothing here reads a proof file.
  for spec in \
    "pkg/SmtEval.lean.in:SmtEval.lean" \
    "pkg/Term.lean.in:${CHECKER}Term.lean" \
    "pkg/SmtModelDefs.lean.in:SmtModelDefs.lean" \
    "pkg/SmtValueOrder.lean.in:SmtValueOrder.lean" \
    "pkg/SmtModel.lean.in:SmtModel.lean" \
    "pkg/Spec.lean.in:Spec.lean" \
    "pkg/Checker.lean.in:${CHECKER}.lean" \
    "pkg/Proofs/Assumptions.lean.in:Proofs/Assumptions.lean" \
    "pkg/Proofs/CheckerCore.lean.in:Proofs/CheckerCore.lean" \
    "pkg/Proofs/RuleLemmas.lean.in:Proofs/RuleLemmas.lean" \
    "pkg/Proofs/Checker.lean.in:Proofs/Checker.lean" \
    "pkg/Proofs/Invariants/Extra.lean.in:Proofs/Invariants/Extra.lean" \
    "pkg/Proofs/TypePredicates.lean.in:Proofs/TypePredicates.lean" \
    "pkg/Proofs/TypeDefaults.lean.in:Proofs/TypeDefaults.lean" \
    "pkg/Proofs/TypePreservation.lean.in:Proofs/TypePreservation.lean" \
    "pkg/ModelWf.lean.in:ModelWf.lean" \
    "pkg/Proofs/RuleSupport/Support.lean.in:Proofs/RuleSupport/Support.lean" \
    "pkg/Proofs/Rules/README.md.in:Proofs/Rules/README.md" ; do
    src="${spec%%:*}"; dst="${spec#*:}"
    mkdir -p "$(dirname "${DEST}/${MINI_CALC}/${dst}")"
    sed -e "s|@CHECKER@|${CHECKER}|g" \
        -e "s|@CALCULUS@|${MINI_CALC}|g" \
        -e "s|@EXE@|${EXE}|g" \
        -e "s|@CALCLOWER@|${CALCLOWER}|g" \
        -e "s|@MINI@|${MINI_CALC}|g" \
        -e "s|@FORMAT@|${FORMAT}|g" \
        -e "s|@EUDAIMONIA@|${EUDAIMONIA}|g" \
        -e "s|@TOOLCHAIN@|${TOOLCHAIN}|g" \
        "${templates_dir}/${src}" > "${DEST}/${MINI_CALC}/${dst}"
  done
  echo "    ${MINI_CALC}/ (rules: ${MINI_RULES:-none chosen yet})"
fi

render     install/README.md.in           "${DEST}/install/README.md"
render_exe install/get-eo-compiler.sh.in  "${DEST}/install/get-eo-compiler.sh"
render_exe install/install-sig.sh.in      "${DEST}/install/install-${CALCLOWER}.sh"

render_exe scripts/build.sh.in                "${DEST}/scripts/build.sh"
render_exe scripts/check-proof-hygiene.sh.in  "${DEST}/scripts/check-proof-hygiene.sh"
render_exe scripts/run-ci.sh.in               "${DEST}/scripts/run-ci.sh"
# Whether an unproven rule can land silently. Off by default because a freshly
# generated checker has one `sorry` per rule of the signature, so a project that
# starts with hundreds of stubs would start red.
if [ "${HYGIENE_CI}" = "yes" ]; then
  sed -i.bak -e 's|^CI_GROUPS=(build regress ethos regeneration)|CI_GROUPS=(build regress ethos hygiene regeneration)|' \
    "${DEST}/scripts/run-ci.sh"
  rm -f "${DEST}/scripts/run-ci.sh.bak"
fi
render_exe scripts/build-rules.sh.in          "${DEST}/scripts/build-rules.sh"
render_exe scripts/rule-status.sh.in          "${DEST}/scripts/rule-status.sh"
render_exe scripts/check-with-ethos.sh.in     "${DEST}/scripts/check-with-ethos.sh"

render docs/calculus.md.in     "${DEST}/docs/calculus.md"
render docs/development.md.in  "${DEST}/docs/development.md"

render gitignore.in            "${DEST}/.gitignore"
render ci/ci.yml.in            "${DEST}/.github/workflows/ci.yml"
render     test/regress-README.md.in "${DEST}/test/regress/README.md"
render_exe test/run.sh.in              "${DEST}/test/regress/run.sh"

echo "==> Installing the specification into install/defs"
if [ "${DUMMY_RULE}" = "yes" ] && [ -z "${SIGNATURE}" ] && [ -z "${SEMANTICS}" ]; then
  # A starter rather than a stub: one rule, its semantics, and proofs covering
  # every verdict. The point is that a new calculus begins from something that
  # compiles and runs, so the first thing to do is change a working checker
  # rather than fill in blanks.
  render starter/signature.eo.in   "${DEST}/install/defs/${CALCULUS}.eo"
  render starter/semantics.eos.in  "${DEST}/install/defs/${CALCULUS}.eos"
  echo "    $(rel "${DEST}/install/defs/${CALCULUS}.eo")  (starter, one rule)"
  echo "    $(rel "${DEST}/install/defs/${CALCULUS}.eos")  (starter)"
  for f in "${templates_dir}"/starter/test/*; do
    base="$(basename "${f}")"
    case "${base}" in
      *.in) render "starter/test/${base}" "${DEST}/test/regress/${base%.in}" ;;
      *) cp "${f}" "${DEST}/test/regress/${base}" ;;
    esac
  done
  echo "    $(rel "${DEST}/test/regress")  (starter proofs, one per verdict)"
else
  if [ -n "${SIGNATURE}" ] && grep -qE '^[[:space:]]*\((include|reference)[[:space:]]' "${SIGNATURE}" 2>/dev/null; then
    mkdir -p "${DEST}/install/defs"
    n_files="$(copy_signature_tree "${SIGNATURE}" "${DEST}/install/defs" "${CALCULUS}.eo")" || exit 1
    echo "    $(rel "${DEST}/install/defs")/  <- ${SIGNATURE} and its includes (${n_files} files)"
  else
    install_or_stub "${SIGNATURE}"     signature.eo.in  "${DEST}/install/defs/${CALCULUS}.eo"
  fi
  install_or_stub "${SEMANTICS}"     semantics.eos.in "${DEST}/install/defs/${CALCULUS}.eos"
fi
# The SMT-LIB semantics is the one file with no stub: leaving it out means the
# calculus is written against whatever base semantics the toolchain supplies,
# which is a choice rather than something left to fill in.
if [ -n "${SPEC_DIR}" ] && [ -d "${SPEC_DIR}/test" ]; then
  # A proof is written in the calculus its signature declares, so regression
  # proofs belong with the specification rather than with the generator.
  copied=0
  for f in "${SPEC_DIR}"/test/*; do
    [ -f "${f}" ] || continue
    cp "${f}" "${DEST}/test/regress/"
    copied=$((copied + 1))
  done
  [ "${copied}" = "0" ] || echo "    $(rel "${DEST}/test/regress")  <- ${SPEC_DIR}/test (${copied} file(s))"
fi

if [ -n "${SMT_SEMANTICS}" ]; then
  cp "${SMT_SEMANTICS}" "${DEST}/install/defs/smt.eos"
  echo "    $(rel "${DEST}/install/defs/smt.eos")  <- ${SMT_SEMANTICS}"
fi

# A specification directory can state its own profile, as it can carry its
# tests and its mini rules: these are facts about the calculus it describes.
if [ -n "${SPEC_DIR}" ] && [ -f "${SPEC_DIR}/profile" ]; then
  # shellcheck source=/dev/null
  . "${SPEC_DIR}/profile"
fi

# The starter signature is known: one rule, no assumption discharge, no list
# premises, no indexed operators. Recording that rather than the conservative
# defaults means a starter project's profile is right from the first install.
if [ "${DUMMY_RULE}" = "yes" ] && [ -z "${SIGNATURE}" ]; then
  PROFILE_SCOPES=no
  PROFILE_LIST_PREMISES=no
  PROFILE_INDEXED_OPS=0
fi

# Whether the SMT-LIB semantics is Logos's is a property of the file, so it is
# measured rather than asked. Anything else -- absent, or modified -- is `no`.
PROFILE_LOGOS_SMT="no"
if [ -f "${DEST}/install/defs/smt.eos" ]; then
  [ "$(file_digest "${DEST}/install/defs/smt.eos" 2>/dev/null || true)" != "${LOGOS_SMT_DIGEST}" ] \
    || PROFILE_LOGOS_SMT="yes"
fi

echo "==> Recording the calculus profile"
render profile.conf.in "${DEST}/install/defs/profile.conf"
sed -i.bak \
  -e "s|^PROFILE_SCOPES=.*|PROFILE_SCOPES=${PROFILE_SCOPES}|" \
  -e "s|^PROFILE_LIST_PREMISES=.*|PROFILE_LIST_PREMISES=${PROFILE_LIST_PREMISES}|" \
  -e "s|^PROFILE_DATATYPES=.*|PROFILE_DATATYPES=${PROFILE_DATATYPES}|" \
  -e "s|^PROFILE_BINDERS=.*|PROFILE_BINDERS=${PROFILE_BINDERS}|" \
  -e "s|^PROFILE_VALUE_ORDERING=.*|PROFILE_VALUE_ORDERING=${PROFILE_VALUE_ORDERING}|" \
  -e "s|^PROFILE_LOGOS_SMT=.*|PROFILE_LOGOS_SMT=${PROFILE_LOGOS_SMT}|" \
  -e "s|^PROFILE_INDEXED_OPS=.*|PROFILE_INDEXED_OPS=${PROFILE_INDEXED_OPS}|" \
  -e "s|^PROFILE_PARSER=.*|PROFILE_PARSER=${PROFILE_PARSER}|" \
  "${DEST}/install/defs/profile.conf"
rm -f "${DEST}/install/defs/profile.conf.bak"
case "${PROFILE_INDEXED_OPS}" in
  0|1|2|3) ;;
  *) echo "error: --indexed-ops must be 0, 1, 2 or 3 (eoc's ladder stops at 3)." >&2; exit 2 ;;
esac
for k in SCOPES LIST_PREMISES DATATYPES BINDERS VALUE_ORDERING INDEXED_OPS LOGOS_SMT PARSER; do
  eval "v=\${PROFILE_${k}}"
  printf '    %-22s %s\n' "$(printf '%s' "${k}" | tr 'A-Z_' 'a-z-')" "${v}"
done

if [ "${MINI}" = "yes" ]; then
  MINI_HINT="  install/install-${CALCLOWER}.sh --mini    # the reduced package
"
else
  MINI_HINT=""
fi

cat <<DONE

==> Done.

  cd $(rel "${DEST}")
  scripts/build.sh                    # the stubs build as they stand

To replace the stubs with the calculus compiled from install/defs:

  install/get-eo-compiler.sh          # once: build the Eunoia compiler
  install/install-${CALCLOWER}.sh
${MINI_HINT}  scripts/build.sh

See its README.md, docs/development.md and install/README.md.
DONE
