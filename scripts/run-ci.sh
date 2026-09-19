#!/usr/bin/env bash
# Repository launcher for the self-contained new_checker tool.
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Informational invocations must not start the test suite.
case " $* " in
  *" --help "*|*" -h "*|*" --list "*) ;;
  *) python3 -m unittest discover -s "${script_dir}/../tests" -p 'test_*.py' ;;
esac
exec "${script_dir}/../new_checker/run-ci.sh" "$@"
