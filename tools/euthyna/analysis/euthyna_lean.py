"""Shared Lean-source arithmetic for Euthyna's own analyses.

Three of the things Euthyna computes -- the rule-proof partition, the coreness
order, and the scatter behind it -- need the same primitives: a Lean-aware line
count, a module import graph, a definition call graph, and the exact file set
that `cpc-loc-summary.py` attributes to its rule-proof bucket. They live here so
the three agree by construction rather than by coincidence.

Every definition here is a faithful restatement of the corresponding one in the
vendored upstream scripts. That is a deliberate duplication and the one place
Euthyna carries a copy of upstream logic rather than reading upstream's output:
a partition that used a different line count, or a different notion of which
files belong to the rule layer, would not reconcile with the numbers Logos
reports about itself, and reconciliation is the whole guarantee. So
`bucket_f()` returns the layer total alongside the file set, and
`rule-partition.py` refuses to emit a partition that does not sum to it.

If upstream changes how it attributes buckets, that check fails loudly and this
file is what has to be brought back into step.
"""

from __future__ import annotations

import os
import re
from pathlib import Path

# --- Bucket configuration, from cpc-loc-summary.py -------------------------
# Priority order. A bucket owns the import closure of its roots plus the
# literal modules listed, minus whatever an earlier bucket claimed.
PROOF_BUCKETS = [
    ("a", ["Cpc.Proofs.TypePreservation"], []),
    ("b", ["Cpc.Proofs.Canonical"], []),
    ("c", ["Cpc.Proofs.Translation"], []),
    ("d", ["Cpc.Proofs.TypePreservation.Nonvacuity"], []),
    ("e", ["Cpc.Proofs.Closed.Support"], []),
    ("g", [], ["Cpc.Proofs.Checker", "Cpc.Proofs.RuleLemmas",
               "Cpc.Api", "Cpc.ApiChecks", "Cpc.ApiCorrect"]),
    ("f", ["Cpc.Proofs.Checker"], []),  # catch-all
]

CENTRAL_ROOTS = ["Cpc.Proofs.Checker"]
SPEC_ROOTS = ["Cpc.Spec"]
LOGOS_ROOTS = ["Cpc.Logos"]
PARSER_ROOTS = ["Cpc.Parser"]
LIBRARIES = ["Cpc", "Logos"]

RULES_SUBDIR = os.path.join("Cpc", "Proofs", "Rules")
RULE_MODULE_PREFIX = "Cpc.Proofs.Rules."

# Files defining the checker's executable rule implementations and everything
# they can call, from cpc-rule-loc.py.
CHECKER_FILES = ["Cpc/Logos.lean", "Cpc/LogosTerm.lean", "Cpc/SmtEval.lean"]

IMPORT_RE = re.compile(r"^\s*(?:public\s+)?import\s+(?:all\s+)?((?:Cpc|Logos)[\w.]*)")


# --- Lines of code ---------------------------------------------------------
def count_loc(text: str) -> int:
    """Non-blank, non-comment lines, stripping Lean comments.

    Handles `--` line comments and nested `/- ... -/` block comments
    (docstrings `/-- -/` are block comments too). Does not special-case `--`
    inside string literals, which is rare in proof code.
    """
    out: list[str] = []
    i, n, depth = 0, len(text), 0
    while i < n:
        if text.startswith("/-", i):
            depth += 1
            i += 2
            continue
        if depth > 0:
            if text.startswith("-/", i):
                depth -= 1
                i += 2
            else:
                if text[i] == "\n":
                    out.append("\n")
                i += 1
            continue
        if text.startswith("--", i):
            while i < n and text[i] != "\n":
                i += 1
            continue
        out.append(text[i])
        i += 1
    return sum(1 for line in "".join(out).splitlines() if line.strip())


class Tree:
    """A Logos checkout, with its import graph and per-module line counts."""

    def __init__(self, root: str | os.PathLike):
        self.root = Path(root).resolve()
        self.imports: dict[str, set[str]] = {}
        self.modules: set[str] = set()
        self._loc: dict[str, int] = {}
        self._build_graph()

    # -- graph
    def _module_path(self, module: str) -> Path:
        return self.root / (module.replace(".", "/") + ".lean")

    def _build_graph(self) -> None:
        for library in LIBRARIES:
            base = self.root / library
            if not base.is_dir():
                continue
            for dirpath, _, files in os.walk(base):
                for name in files:
                    if not name.endswith(".lean"):
                        continue
                    path = Path(dirpath) / name
                    module = str(path.relative_to(self.root))[: -len(".lean")].replace("/", ".")
                    self.modules.add(module)
                    deps: set[str] = set()
                    with path.open(encoding="utf-8") as fh:
                        for line in fh:
                            m = IMPORT_RE.match(line)
                            if m:
                                deps.add(m.group(1))
                    self.imports[module] = deps

    def closure(self, roots) -> set[str]:
        seen: set[str] = set()
        stack = list(roots)
        while stack:
            module = stack.pop()
            if module in seen or module not in self.modules:
                continue
            seen.add(module)
            stack.extend(self.imports.get(module, ()))
        return seen

    # -- lines
    def loc(self, module: str) -> int:
        if module not in self._loc:
            path = self._module_path(module)
            self._loc[module] = (
                count_loc(path.read_text(encoding="utf-8")) if path.exists() else 0
            )
        return self._loc[module]

    def total_loc(self, modules) -> int:
        return sum(self.loc(m) for m in modules)

    # -- rules
    def rule_names(self) -> list[str]:
        """The rule file stems under Cpc/Proofs/Rules, sorted."""
        rules_dir = self.root / RULES_SUBDIR
        if not rules_dir.is_dir():
            return []
        return sorted(
            p.name[: -len(".lean")] for p in rules_dir.iterdir() if p.name.endswith(".lean")
        )

    def rule_cone(self, rule: str) -> set[str]:
        return self.closure([RULE_MODULE_PREFIX + rule])

    # -- the rule-proof layer
    def bucket_f(self) -> tuple[set[str], dict[str, set[str]]]:
        """The file set `cpc-loc-summary.py` attributes to bucket (f).

        Returns (bucket_f_modules, all_buckets). Replicates upstream exactly:
        definitions and the parser are excluded first, then each bucket claims
        its closure minus what earlier buckets took, in PROOF_BUCKETS order.
        """
        spec_cl = self.closure(SPEC_ROOTS)
        logos_cl = self.closure(LOGOS_ROOTS)
        parser_cl = self.closure(PARSER_ROOTS) - logos_cl
        excluded = spec_cl | logos_cl | parser_cl

        claimed = set(excluded)
        buckets: dict[str, set[str]] = {}
        for key, closure_roots, file_roots in PROOF_BUCKETS:
            cl = self.closure(closure_roots)
            cl |= {m for m in file_roots if m in self.modules}
            own = cl - claimed
            claimed |= own
            buckets[key] = own
        return buckets["f"], buckets


# --- Definition call graph, from cpc-rule-loc.py ---------------------------
DECL_RE = re.compile(
    r"^(?:private |public |noncomputable |partial |protected |unsafe )*"
    r"(?:def|abbrev|theorem|lemma|inductive|structure|instance)\s+"
    r"(?:@\[[^\]]*\]\s*)?([A-Za-z_][A-Za-z0-9_'!?]*)"
)
BOUNDARY_RE = re.compile(
    r"^(?:public )?"
    r"(mutual|end|namespace|open|set_option|import|attribute|section|variable|module)\b"
    r"|^/-"
)
TOKEN_RE = re.compile(r"[A-Za-z_][A-Za-z0-9_'!?]*")


def build_def_graph(root: Path, files=CHECKER_FILES):
    """(loc_by_name, deps_by_name) for the top-level decls of `files`.

    Names defined more than once (across `mutual` blocks) have their bodies
    concatenated, as upstream does.
    """
    bodies: dict[str, list[str]] = {}
    for rel in files:
        path = Path(root) / rel
        if not path.exists():
            continue
        current = None
        buf: list[str] = []
        for line in path.read_text(encoding="utf-8").split("\n"):
            decl = DECL_RE.match(line)
            if decl:
                if current is not None:
                    bodies.setdefault(current, []).append("\n".join(buf))
                current = decl.group(1)
                buf = [line]
            elif BOUNDARY_RE.match(line):
                if current is not None:
                    bodies.setdefault(current, []).append("\n".join(buf))
                current = None
                buf = []
            elif current is not None:
                buf.append(line)
        if current is not None:
            bodies.setdefault(current, []).append("\n".join(buf))

    names = set(bodies)
    loc_by_name: dict[str, int] = {}
    deps_by_name: dict[str, set[str]] = {}
    for name, parts in bodies.items():
        text = "\n".join(parts)
        loc_by_name[name] = count_loc(text)
        refs = set(TOKEN_RE.findall(text)) & names
        refs.discard(name)
        deps_by_name[name] = refs
    return loc_by_name, deps_by_name


def def_closure(start: str, deps_by_name: dict[str, set[str]]) -> set[str]:
    seen: set[str] = set()
    stack = [start]
    while stack:
        name = stack.pop()
        if name in seen or name not in deps_by_name:
            continue
        seen.add(name)
        stack.extend(deps_by_name[name])
    return seen


def prog_name(rule: str) -> str:
    """The checker definition implementing a rule, from its file stem."""
    return "__eo_prog_" + rule.lower()


# --- The coreness order ----------------------------------------------------
def read_order(path: str | os.PathLike) -> list[str]:
    """The rule names of an order file, in order. Blank and `#` lines ignored."""
    out: list[str] = []
    for line in Path(path).read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if line and not line.startswith("#"):
            out.append(line)
    return out
