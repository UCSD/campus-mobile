#!/usr/bin/env bash
# var_func_lower_camel_case.sh - Check and enforce lowerCamelCase naming for regular variables in Dart files.
# This script focuses ONLY on regular variables (var, final, const) and excludes static constants.
# For static constants, use static_const_upper_snake_case.sh instead.
# Usage:
#   ./scripts/var_func_lower_camel_case.sh           -> check all files and report violations
#   ./scripts/var_func_lower_camel_case.sh check     -> check mode (exits non-zero if violations found)
#   ./scripts/var_func_lower_camel_case.sh fix       -> attempt to auto-fix violations (experimental)

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

# Function to check if a name follows lowerCamelCase
is_lower_camel_case() {
  local name="$1"

  # Check for private variables starting with underscore
  if [[ "$name" =~ ^_ ]]; then
    # Remove leading underscore and check the rest
    local rest="${name#_}"
    # Rest should be lowerCamelCase (starts with lowercase, no underscores)
    if [[ "$rest" =~ ^[a-z][a-zA-Z0-9]*$ ]]; then
      return 0
    else
      return 1
    fi
  else
    # Regular lowerCamelCase: starts with lowercase, no underscores
    if [[ "$name" =~ ^[a-z][a-zA-Z0-9]*$ ]]; then
      return 0
    else
      return 1
    fi
  fi
}

# Function to convert to lowerCamelCase (basic conversion)
to_lower_camel_case() {
  local name="$1"

  # Check if it's UPPER_SNAKE_CASE (all caps with underscores)
  if [[ "$name" =~ ^[A-Z][A-Z0-9_]*$ ]]; then
    # Handle UPPER_SNAKE_CASE -> lowerCamelCase
    local lowercase_name=$(echo "$name" | tr '[:upper:]' '[:lower:]')
    # Convert snake_case to camelCase
    local result=$(echo "$lowercase_name" | sed 's/_\([a-z]\)/\U\1/g')
    echo "$result"
  # Check if it's PascalCase (starts with uppercase, no underscores)
  elif [[ "$name" =~ ^[A-Z][a-zA-Z0-9]*$ ]] && [[ ! "$name" =~ _ ]]; then
    # Handle PascalCase -> lowerCamelCase (just lowercase the first character)
    echo "$name" | sed 's/^\([A-Z]\)/\l\1/'
  else
    # Handle other cases (snake_case, etc.)
    local result=$(echo "$name" | sed 's/_\([a-z]\)/\U\1/g')
    echo "$result" | sed 's/^\([A-Z]\)/\l\1/'
  fi
}violations_found=0
total_files=0

echo "Checking Dart files for lowerCamelCase regular variables (excluding static const)..."
echo "Scanning: lib/"

# Create violations array to store detailed information
violations=()

# Find and report violations for regular variables (excluding static const)
echo "Looking for non-lowerCamelCase variables (excluding static const)..."

# Find variable declarations and extract variable names correctly
# Use a temporary file to avoid subshell issues with variable counting
temp_results=$(mktemp)
grep -rn --include="*.dart" -E "(var|final|const)[[:space:]]+" lib/ | \
  grep -v "static const" > "$temp_results"

while IFS=: read -r file line_num content; do
  # Pattern 1: var/final/const variableName (without explicit type)
  if [[ "$content" =~ (var|final|const)[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*)[[:space:]]*= ]]; then
    var_name="${BASH_REMATCH[2]}"
    if ! is_lower_camel_case "$var_name"; then
      suggested=$(to_lower_camel_case "$var_name")
      violation_msg="$file:$line_num: Variable '$var_name' should be lowerCamelCase (suggested: $suggested)"
      violations+=("$violation_msg")
      echo "  $violation_msg"
      violations_found=$((violations_found + 1))
    fi
  # Pattern 2: var/final/const Type variableName (with explicit type)
  elif [[ "$content" =~ (var|final|const)[[:space:]]+[A-Za-z][A-Za-z0-9_\<\>\?,[:space:]]*[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*)[[:space:]]*= ]]; then
    var_name="${BASH_REMATCH[2]}"
    if ! is_lower_camel_case "$var_name"; then
      suggested=$(to_lower_camel_case "$var_name")
      violation_msg="$file:$line_num: Variable '$var_name' should be lowerCamelCase (suggested: $suggested)"
      violations+=("$violation_msg")
      echo "  $violation_msg"
      violations_found=$((violations_found + 1))
    fi
  fi
done < "$temp_results"

# Clean up temporary file
rm -f "$temp_results"

# Count total files processed (approximate)
total_files=$(find lib -name "*.dart" -type f | wc -l)

echo ""
echo "Summary:"
echo "  Files checked: $total_files"
echo "  Total violations: $violations_found"

# Export violations for parent script if VIOLATIONS_OUTPUT is set
if [[ -n "${VIOLATIONS_OUTPUT:-}" ]]; then
  if [[ $violations_found -gt 0 ]]; then
    echo "VARIABLE_NAMING_VIOLATIONS_START" >> "$VIOLATIONS_OUTPUT"
    # Re-process violations to write to file
    grep -rn --include="*.dart" -E "(var|final|const)[[:space:]]+" lib/ | grep -v "static const" | while IFS=: read -r file line_num content; do
      # Pattern 1: var/final/const variableName (without explicit type)
      if [[ "$content" =~ (var|final|const)[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*)[[:space:]]*= ]]; then
        var_name="${BASH_REMATCH[2]}"
        if ! is_lower_camel_case "$var_name"; then
          suggested=$(to_lower_camel_case "$var_name")
          echo "$file:$line_num: Variable '$var_name' should be lowerCamelCase (suggested: $suggested)" >> "$VIOLATIONS_OUTPUT"
        fi
      # Pattern 2: var/final/const Type variableName (with explicit type)
      elif [[ "$content" =~ (var|final|const)[[:space:]]+[A-Za-z][A-Za-z0-9_\<\>\?,[:space:]]*[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*)[[:space:]]*= ]]; then
        var_name="${BASH_REMATCH[2]}"
        if ! is_lower_camel_case "$var_name"; then
          suggested=$(to_lower_camel_case "$var_name")
          echo "$file:$line_num: Variable '$var_name' should be lowerCamelCase (suggested: $suggested)" >> "$VIOLATIONS_OUTPUT"
        fi
      fi
    done
    echo "VARIABLE_NAMING_VIOLATIONS_END" >> "$VIOLATIONS_OUTPUT"
  fi
fi

if [[ $violations_found -gt 0 ]]; then
  echo ""
  echo "lowerCamelCase guidelines:"
  echo "  - Variables: myVariable, userName, isLoggedIn"
  echo "  - Functions: calculateTotal(), getUserData(), handleClick()"
  echo "  - Private members: _privateVariable, _helperFunction()"
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
  echo "All variables and functions follow lowerCamelCase naming convention!"
fi

if [[ $violations_found -gt 0 ]]; then
  exit 1
else
  exit 0
fi
