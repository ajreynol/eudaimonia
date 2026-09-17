#!/usr/bin/env python3
"""Run the theory tutorial's proof tests with Ethos and its generated checker.

Usage: python3 check.py /path/to/ethos /path/to/theorydemo
This checks executable behavior; Semantics.lean checks the translation lemmas.
"""

from pathlib import Path
import resource
import subprocess
import sys


def main():
    if len(sys.argv) != 3:
        print(__doc__, file=sys.stderr)
        return 2
    resource.setrlimit(resource.RLIMIT_CORE, (0, 0))
    ethos, checker = sys.argv[1:]
    here = Path(__file__).resolve().parent
    cases = [
        ("nand", True, "", ""),
        ("nor", True, "", ""),
        ("wrong-conclusion", False,
         "Unexpected conclusion for rule nand-elim:", "stuck at step @false"),
        ("wrong-type", False, "Type checking failed:", "stuck loading assumption 1"),
    ]
    failed = False
    for name, valid, ethos_error, checker_error in cases:
        proof = str(here / "test" / f"{name}.cpc")
        ethos_args = [ethos, f"--include={here / 'gates.eo'}"]
        if valid:
            ethos_args.append("--require-proof-of-false")
        for label, args, diagnostic in (
            ("ethos", [*ethos_args, proof], ethos_error),
            ("theorydemo", [checker, proof], checker_error),
        ):
            result = subprocess.run(args, text=True, stdout=subprocess.PIPE,
                                    stderr=subprocess.STDOUT)
            if valid:
                ok = result.returncode == 0 and result.stdout.strip() == "correct"
            elif label == "ethos":
                ok = result.returncode != 0 and diagnostic in result.stdout
            else:
                ok = (result.returncode == 1 and diagnostic in result.stdout
                      and result.stdout.strip().endswith("incorrect"))
            print(f"{'PASS' if ok else 'FAIL'} {label}: {name}")
            if not ok:
                print(f"exit {result.returncode}\n{result.stdout}", file=sys.stderr)
                failed = True
    return int(failed)


if __name__ == "__main__":
    sys.exit(main())
