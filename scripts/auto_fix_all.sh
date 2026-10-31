#!/usr/bin/env bash
set -euo pipefail

if ! command -v dart >/dev/null 2>&1; then
    printf '%s\n' 'Error: dart is required. Install the Flutter SDK version documented in Readme.md.' >&2
    exit 127
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
cd "$repo_root"

case "${1:-}" in
    --dry-run)
        shift
        format_args=(--output=none --set-exit-if-changed)
        ;;
    "")
        format_args=()
        ;;
    *)
        printf '%s\n' "Usage: $0 [--dry-run]" >&2
        exit 2
        ;;
esac

if [[ $# -ne 0 ]]; then
    printf '%s\n' "Usage: $0 [--dry-run]" >&2
    exit 2
fi

exec dart format --line-length 120 "${format_args[@]}" lib test
