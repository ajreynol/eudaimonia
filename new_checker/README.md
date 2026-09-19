# new_checker

The checker generator's implementation and inputs live in this directory.
For the signature contract, requirements and full usage, start at the
[repository front page](../README.md#usage).

From this directory:

```bash
./new-checker.sh --checker Demo --calculus Hello --spec examples/hello
./new-checker.sh --help
./run-ci.sh
```

`config.sh` supplies defaults; command-line options override them. `templates/`
holds the generated files and `examples/` holds worked specifications and their
regression proofs. Output defaults to `checkers/` beside this file and is ignored
by git. Relative input paths and `--out` are resolved from the caller's working
directory. The tool can run from any working directory or as a standalone copy
of `new_checker/`.

`bump-eoc.sh` updates the compiler pin and its semantics snapshots together.
The repository's `scripts/` commands are launchers for these three scripts.
