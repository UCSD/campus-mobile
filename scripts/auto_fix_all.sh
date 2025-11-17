#!/bin/bash
# Auto-fix all code quality violations
# Usage:
# ./scripts/auto_fix_all.sh --dry-run  # Preview what would be fixed
# ./scripts/auto_fix_all.sh            # Apply all auto-fixes

set -e

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
cd "$repo_root"

DRY_RUN=false
if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=true
fi

echo
echo "===================================="
echo "Auto Code Styling Process Started..."

# Track fixes applied
fixes_applied=0

if [[ "$DRY_RUN" == "true" ]]; then
    echo "DRY RUN MODE - No changes will be made"
    echo
    echo "Would run the following fixes:"
    echo "1. Comment spacing fixes"
    echo "2. TODO dating fixes"
    echo "3. Ensure one-line if statements are without braces"
    echo "4. Ensure one-line functions use arrow syntax"
    echo "5. Dart formatting"
    echo
    exit 0
fi

echo "------------------------------------"
# First fix is to change all //Comments to // Comments
echo "1. Ensuring all comments have a space after the slashes..."
if bash scripts/styling/add_space_after_comment_slashes.sh --fix; then
    echo "Comment spacing fixes completed."
    fixes_applied=$((fixes_applied + 1))
else
    echo "Nothing to fix, moving on..."
fi

echo "------------------------------------"
# Second fix is to ensure all TODOs have a date
echo "2. Ensuring all TODO comments have a date..."
if bash scripts/styling/add_date_to_todo_comment.sh --fix; then
    echo "TODO dates fixes completed."
    fixes_applied=$((fixes_applied + 1))
else
    echo "Nothing to fix, moving on..."
fi

echo "------------------------------------"
# Third fix is to ensure all if statements that can be one-liners are one-liners without braces
echo "3. Ensuring all one-line if statements are without braces..."
if bash scripts/styling/one_line_if_statement_fix.sh --fix; then
    echo "One-line if statements have been fixed."
    fixes_applied=$((fixes_applied + 1))
else
    echo "Nothing to fix, moving on..."
fi

echo "------------------------------------"
# Fourth fix is to ensure all functions that can be one-liners use arrow syntax
echo "4. Ensuring all functions that can be one-liners use arrow syntax..."
if bash scripts/styling/one_line_function_fix.sh --fix; then
    echo "One-line functions have been fixed."
    fixes_applied=$((fixes_applied + 1))
else
    echo "Nothing to fix, moving on..."
fi

echo "------------------------------------"
# Fifth fix is to run dart format
echo "5. Running dart format..."
if bash scripts/styling/dart_format_files.sh; then
    echo "Dart formatting completed"
else
    echo "Nothing to fix, moving on..."
fi

echo "===================================="
echo "Total fixes applied: $fixes_applied/5"
echo "Auto Code Styling Process Completed!"
