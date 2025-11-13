#!/usr/bin/env bash
# format-files.sh - Format all Dart files under lib/ with configurable line length.
# Usage:
#   ./scripts/dart_format_files.sh           -> default LINE_LENGTH=100
#   ./scripts/dart_format_files.sh 120       -> set LINE_LENGTH to 120
#   ./scripts/dart_format_files.sh 120 dry   -> dry-run (prints files that would change)
#   ./scripts/dart_format_files.sh 120 check -> check mode (exits non-zero if changes)
# The script changes to the project root (parent of scripts/) before running.

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
cd "$repo_root"

# Defaults
LINE_LENGTH=100
MODE=""

# Parse arguments: numeric -> line length, 'dry' -> --dry-run, 'check' -> --set-exit-if-changed
for arg in "$@"; do
  case "$arg" in
    dry)
      MODE="--dry-run"
      ;;
    check)
      MODE="--set-exit-if-changed"
      ;;
    *[!0-9]* )
      echo "Unknown argument: $arg"
      echo "Usage: $0 [LINE_LENGTH] [dry|check]"
      exit 2
      ;;
    *)
      LINE_LENGTH="$arg"
      ;;
  esac
done

# Prefer 'dart' but fall back to 'flutter' if not found.
if command -v dart >/dev/null 2>&1; then
  CMD=dart
elif command -v flutter >/dev/null 2>&1; then
  CMD=flutter
else
  echo "Error: Neither 'dart' nor 'flutter' was found on PATH. Install Dart SDK or Flutter."
  exit 1
fi

# Announce and run
echo "Running: $CMD format ${MODE} --line-length ${LINE_LENGTH} lib"
# shellcheck disable=SC2086
$CMD format ${MODE} --line-length "$LINE_LENGTH" lib
