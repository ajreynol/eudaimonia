#!/usr/bin/env python3
"""Check the CPC theory tutorial's main and expert proof fixtures with Ethos.

Usage: python3 check.py /path/to/ethos /path/to/cvc5
This checks signature behavior; it does not build cvc5 or verify Logos proofs.
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
    ethos, cvc5 = sys.argv[1:]
    here = Path(__file__).resolve().parent
    signature = Path(cvc5).resolve() / "proofs" / "eo" / "cpc"
    main_signature = signature / "Cpc.eo"
    expert_signature = signature / "expert" / "CpcExpert.eo"
    for path in (main_signature, expert_signature):
        if not path.is_file():
            print(f"Missing signature: {path}", file=sys.stderr)
            return 2
    cases = [
        ("int-pow2", False, ""),
        ("int-pow2-wrong-type", False, "Type checking failed:"),
        ("finite-fields", False, "Could not find symbol FiniteField"),
        ("finite-fields", True, ""),
        ("finite-fields-wrong-type", True, "Type checking failed:"),
    ]
    failed = False
    for name, expert, diagnostic in cases:
        proof = str(here / "test" / f"{name}.cpc")
        args = [ethos, f"--include={main_signature}"]
        if expert:
            args.append(f"--include={expert_signature}")
        if not diagnostic:
            args.append("--require-proof-of-false")
        result = subprocess.run([*args, proof], text=True, stdout=subprocess.PIPE,
                                stderr=subprocess.STDOUT)
        if diagnostic:
            ok = result.returncode != 0 and diagnostic in result.stdout
        else:
            ok = result.returncode == 0 and result.stdout.strip() == "correct"
        label = "main + expert" if expert else "main only"
        print(f"{'PASS' if ok else 'FAIL'} {label}: {name}")
        if not ok:
            print(f"exit {result.returncode}\n{result.stdout}", file=sys.stderr)
            failed = True
    return int(failed)


if __name__ == "__main__":
    sys.exit(main())
