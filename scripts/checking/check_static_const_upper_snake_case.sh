#!/usr/bin/env bash
# static_const_upper_snake_case.sh - Enforce UPPER_SNAKE_CASE naming for static constants in Dart files.
# Usage:
#   ./scripts/static_const_upper_snake_case.sh           -> check all files and report violations
#   ./scripts/static_const_upper_snake_case.sh check     -> check mode (exits non-zero if violations found)
#   ./scripts/static_const_upper_snake_case.sh fix       -> attempt to auto-fix violations (experimental)

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

# Function to check if a name follows UPPER_SNAKE_CASE
is_upper_snake_case() {
  local name="$1"
  # UPPER_SNAKE_CASE: starts with uppercase letter, can contain uppercase letters, numbers, and underscores
  if [[ "$name" =~ ^[A-Z][A-Z0-9_]*$ ]]; then
    return 0
  else
    return 1
  fi
}

# Function to convert to UPPER_SNAKE_CASE (basic conversion)
to_upper_snake_case() {
  local name="$1"
  # Convert lowerCamelCase to UPPER_SNAKE_CASE
  echo "$name" | sed 's/\([a-z]\)\([A-Z]\)/\1_\2/g' | tr '[:lower:]' '[:upper:]'
}

violations_found=0
total_files=0

echo "Checking Dart files for UPPER_SNAKE_CASE static constants..."
echo "Scanning: lib/"
echo "Looking for static const variables that should be UPPER_SNAKE_CASE..."

# Create violations array to store detailed information
violations=()

# Find static const violations
# Use a temporary file to avoid subshell issues with variable counting
temp_results=$(mktemp)
grep -rn --include="*.dart" "static const" lib/ > "$temp_results"

while IFS=: read -r file line_num content; do
  # Pattern 1: static const variableName (without explicit type)
  if [[ "$content" =~ static[[:space:]]+const[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*)[[:space:]]*= ]]; then
    var_name="${BASH_REMATCH[1]}"
    if ! is_upper_snake_case "$var_name"; then
      suggested=$(to_upper_snake_case "$var_name")
      violation_msg="$file:$line_num: Static const '$var_name' should be UPPER_SNAKE_CASE (suggested: $suggested)"
      violations+=("$violation_msg")
      echo "  $violation_msg"
      violations_found=$((violations_found + 1))
    fi
  # Pattern 2: static const Type variableName (with explicit type)
  elif [[ "$content" =~ static[[:space:]]+const[[:space:]]+[A-Za-z][A-Za-z0-9_\<\>\?,[:space:]]*[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*)[[:space:]]*= ]]; then
    var_name="${BASH_REMATCH[1]}"
    if ! is_upper_snake_case "$var_name"; then
      suggested=$(to_upper_snake_case "$var_name")
      violation_msg="$file:$line_num: Static const '$var_name' should be UPPER_SNAKE_CASE (suggested: $suggested)"
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
    echo "STATIC_CONST_VIOLATIONS_START" >> "$VIOLATIONS_OUTPUT"
    # Re-process violations to write to file (since array was in subshell)
    grep -rn --include="*.dart" "static const" lib/ | while IFS=: read -r file line_num content; do
      # Pattern 1: static const variableName (without explicit type)
      if [[ "$content" =~ static[[:space:]]+const[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*)[[:space:]]*= ]]; then
        var_name="${BASH_REMATCH[1]}"
        if ! is_upper_snake_case "$var_name"; then
          suggested=$(to_upper_snake_case "$var_name")
          echo "$file:$line_num: Static const '$var_name' should be UPPER_SNAKE_CASE (suggested: $suggested)" >> "$VIOLATIONS_OUTPUT"
        fi
      # Pattern 2: static const Type variableName (with explicit type)
      elif [[ "$content" =~ static[[:space:]]+const[[:space:]]+[A-Za-z][A-Za-z0-9_\<\>\?,[:space:]]*[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*)[[:space:]]*= ]]; then
        var_name="${BASH_REMATCH[1]}"
        if ! is_upper_snake_case "$var_name"; then
          suggested=$(to_upper_snake_case "$var_name")
          echo "$file:$line_num: Static const '$var_name' should be UPPER_SNAKE_CASE (suggested: $suggested)" >> "$VIOLATIONS_OUTPUT"
        fi
      fi
    done
    echo "STATIC_CONST_VIOLATIONS_END" >> "$VIOLATIONS_OUTPUT"
  fi
fi

if [[ $violations_found -gt 0 ]]; then
  echo ""
  echo "UPPER_SNAKE_CASE guidelines for static constants:"
  echo "  - Good: PAYMENT_FILTER_TYPES, MAX_RETRY_COUNT, API_BASE_URL"
  echo "  - Bad: payment_filter_types, paymentFilterTypes, Payment_Filter_Types"
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
  echo "All static constants follow UPPER_SNAKE_CASE naming convention!"
fi

if [[ $violations_found -gt 0 ]]; then
  exit 1
else
  exit 0
fi
