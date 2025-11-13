#!/usr/bin/env bash
# classes_upper_camel_case.sh - Enforce UpperCamelCase (PascalCase) naming for class names in Dart files.
# Usage:
#   ./scripts/classes_upper_camel_case.sh           -> check all files and report violations
#   ./scripts/classes_upper_camel_case.sh check     -> check mode (exits non-zero if violations found)
#   ./scripts/classes_upper_camel_case.sh fix       -> attempt to auto-fix violations (experimental)

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/../.." && pwd)"
cd "$repo_root"

# Defaults
MODE="report"

# Parse arguments
for arg in "$@"; do
  case "$arg" in
    check)
      MODE="check"
      ;;
    fix)
      MODE="fix"
      ;;
    *)
      echo "Unknown argument: $arg"
      echo "Usage: $0 [check|fix]"
      exit 2
      ;;
  esac
done

# Function to check if a name follows UpperCamelCase (PascalCase)
is_upper_camel_case() {
  local name="$1"

  # Check for private classes starting with underscore
  if [[ "$name" =~ ^_ ]]; then
    # Remove leading underscore and check the rest
    local rest="${name#_}"
    # Rest should be UpperCamelCase (starts with uppercase, no underscores)
    if [[ "$rest" =~ ^[A-Z][a-zA-Z0-9]*$ ]]; then
      return 0
    else
      return 1
    fi
  else
    # Regular UpperCamelCase: starts with uppercase letter, can contain letters and numbers, no underscores
    if [[ "$name" =~ ^[A-Z][a-zA-Z0-9]*$ ]]; then
      return 0
    else
      return 1
    fi
  fi
}

# Function to convert to UpperCamelCase (basic conversion)
to_upper_camel_case() {
  local name="$1"
  # Convert snake_case to UpperCamelCase
  echo "$name" | sed 's/_\([a-z]\)/\U\1/g' | sed 's/^./\U&/'
}

violations_found=0
total_files=0

echo "Checking Dart files for UpperCamelCase class names..."
echo "Scanning: lib/"
echo "Looking for class names that should be UpperCamelCase..."

# Create violations array to store detailed information
violations=()

# Find class declarations and extract class names correctly
# Use a temporary file to avoid subshell issues with variable counting
temp_results=$(mktemp)

# Find regular class declarations
grep -rn --include="*.dart" -E "^[[:space:]]*class[[:space:]]+" lib/ > "$temp_results" 2>/dev/null || true

while IFS=: read -r file line_num content; do
  # Pattern: class ClassName or class ClassName extends/implements/with
  if [[ "$content" =~ class[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*) ]]; then
    class_name="${BASH_REMATCH[1]}"
    if ! is_upper_camel_case "$class_name"; then
      suggested=$(to_upper_camel_case "$class_name")
      violation_msg="$file:$line_num: Class '$class_name' should be UpperCamelCase (suggested: $suggested)"
      violations+=("$violation_msg")
      echo "  $violation_msg"
      violations_found=$((violations_found + 1))
    fi
  fi
done < "$temp_results"

# Also check for abstract classes
grep -rn --include="*.dart" -E "^[[:space:]]*abstract[[:space:]]+class[[:space:]]+" lib/ > "$temp_results" 2>/dev/null || true

while IFS=: read -r file line_num content; do
  # Pattern: abstract class ClassName
  if [[ "$content" =~ abstract[[:space:]]+class[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*) ]]; then
    class_name="${BASH_REMATCH[1]}"
    if ! is_upper_camel_case "$class_name"; then
      suggested=$(to_upper_camel_case "$class_name")
      violation_msg="$file:$line_num: Abstract class '$class_name' should be UpperCamelCase (suggested: $suggested)"
      violations+=("$violation_msg")
      echo "  $violation_msg"
      violations_found=$((violations_found + 1))
    fi
  fi
done < "$temp_results"

# Clean up temporary file
rm -f "$temp_results"

# Count total files processed
total_files=$(find lib -name "*.dart" -type f | wc -l)

echo ""
echo "Summary:"
echo "  Files checked: $total_files"
echo "  Total violations: $violations_found"

# Export violations for parent script if VIOLATIONS_OUTPUT is set
if [[ -n "${VIOLATIONS_OUTPUT:-}" ]]; then
  if [[ $violations_found -gt 0 ]]; then
    echo "CLASS_NAMING_VIOLATIONS_START" >> "$VIOLATIONS_OUTPUT"
    # Re-process violations to write to file
    grep -rn --include="*.dart" -E "^[[:space:]]*class[[:space:]]+" lib/ 2>/dev/null | while IFS=: read -r file line_num content; do
      if [[ "$content" =~ class[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*) ]]; then
        class_name="${BASH_REMATCH[1]}"
        if ! is_upper_camel_case "$class_name"; then
          suggested=$(to_upper_camel_case "$class_name")
          echo "$file:$line_num: Class '$class_name' should be UpperCamelCase (suggested: $suggested)" >> "$VIOLATIONS_OUTPUT"
        fi
      fi
    done
    grep -rn --include="*.dart" -E "^[[:space:]]*abstract[[:space:]]+class[[:space:]]+" lib/ 2>/dev/null | while IFS=: read -r file line_num content; do
      if [[ "$content" =~ abstract[[:space:]]+class[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*) ]]; then
        class_name="${BASH_REMATCH[1]}"
        if ! is_upper_camel_case "$class_name"; then
          suggested=$(to_upper_camel_case "$class_name")
          echo "$file:$line_num: Abstract class '$class_name' should be UpperCamelCase (suggested: $suggested)" >> "$VIOLATIONS_OUTPUT"
        fi
      fi
    done
    echo "CLASS_NAMING_VIOLATIONS_END" >> "$VIOLATIONS_OUTPUT"
  fi
fi

if [[ $violations_found -gt 0 ]]; then
  echo ""
  echo "UpperCamelCase guidelines for classes:"
  echo "  - Good: UserProfile, NetworkHelper, DatabaseManager"
  echo "  - Bad: userProfile, network_helper, databaseManager"
  echo ""

  if [[ "$MODE" == "fix" ]]; then
    echo "Auto-fix mode is experimental and may require manual review."
    echo "Please verify changes before committing."
  elif [[ "$MODE" == "check" ]]; then
    exit 1
  else
    echo "Run with 'fix' argument to see suggested corrections."
    echo "Run with 'check' argument for CI/CD integration."
  fi
else
  echo "All classes follow UpperCamelCase naming convention!"
fi

if [[ $violations_found -gt 0 ]]; then
  exit 1
else
  exit 0
fi
