#!/usr/bin/env bash
# Repository launcher for the self-contained new_checker tool.
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "${script_dir}/../new_checker/bump-eoc.sh" "$@"
