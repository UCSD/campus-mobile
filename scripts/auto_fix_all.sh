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

echo "==================================="
echo "Auto Code Styling Process Started..."
echo "==================================="
echo

# Track fixes applied
fixes_applied=0

if [[ "$DRY_RUN" == "true" ]]; then
    echo "DRY RUN MODE - No changes will be made"
    echo
    echo "Would run the following fixes:"
    echo "1. Comment spacing fixes"
    echo "2. TODO format fixes"
    echo "3. One-line if brace removal"
    echo "4. Dart formatting"
    echo
    exit 0
fi

echo "🔍 1. Fixing comment spacing..."
if bash scripts/comment_space.sh --fix; then
    echo "✅ Comment spacing fixes completed"
    fixes_applied=$((fixes_applied + 1))
else
    echo "❌ Comment spacing fixes failed"
fi
echo

echo "🔍 2. Fixing TODO comment formats..."
if bash scripts/todo_date_check.sh --fix; then
    echo "✅ TODO format fixes completed"
    fixes_applied=$((fixes_applied + 1))
else
    echo "❌ TODO format fixes failed"
fi
echo

echo "🔍 3. Fixing one-line if statement braces..."
if bash scripts/no_braces_one_line_if.sh --fix; then
    echo "✅ One-line if brace fixes completed"
    fixes_applied=$((fixes_applied + 1))
else
    echo "❌ One-line if brace fixes failed"
fi
echo

# echo "🔍 4. Fixing file and directory naming..."
# if bash scripts/file_dir_snake_case.sh --fix; then
#     echo "✅ File/directory naming fixes completed"
#     fixes_applied=$((fixes_applied + 1))
# else
#     echo "❌ File/directory naming fixes failed"
# fi
# echo

echo "🔍 4. Running dart format..."
if bash scripts/dart_format_files.sh; then
    echo "✅ Dart formatting completed"
else
    echo "❌ Dart formatting failed"
fi
echo

echo "==============================="
echo "Auto-fix Summary"
echo "==============================="
echo "Fix operations completed: $fixes_applied/4"
echo

if [[ $fixes_applied -gt 0 ]]; then
    echo "Changes made - you can now commit them:"
    echo "  git add -A"
    echo "  git commit -m 'Auto-fix: Code quality improvements'"
    echo

    echo "Final quality check..."
    echo

    echo "Comment spacing status:"
    bash scripts/comment_space.sh | tail -2
    echo

    echo "TODO format status:"
    bash scripts/todo_date_check.sh | tail -2
    echo

    echo "One-line if braces status:"
    bash scripts/no_braces_one_line_if.sh | tail -2
    echo

    # echo "File/directory naming status:"
    # bash scripts/file_dir_snake_case.sh | tail -2
else
    echo "No fixes were needed or all fixes failed."
fi

echo
echo "Auto Code Styling Process Completed!"
