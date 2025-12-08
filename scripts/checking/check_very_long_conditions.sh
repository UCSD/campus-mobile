#!/usr/bin/env bash
# check_very_long_conditions.sh - Check for overly long if statement conditions that should be split into separate variables.
# This script detects if statements with complex conditions spanning multiple lines or exceeding reasonable length limits.
# Long conditions make code harder to read and should be broken down into meaningful variable assignments.
# Usage:
#   ./scripts/checking/check_very_long_conditions.sh           -> check all files and report violations
#   ./scripts/checking/check_very_long_conditions.sh check     -> check mode (exits non-zero if violations found)

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
    *)
      echo "Unknown argument: $arg"
      echo "Usage: $0 [check]"
      exit 2
      ;;
  esac
done

violations_found=0

echo "Checking Dart files for overly long if statement conditions..."
echo "Scanning: lib/"
echo "Looking for complex if conditions that should be split into variables..."

# Create temporary file for all violations
violations_temp=$(mktemp)

# Find if statements and check them efficiently
# This approach is much faster as it processes files in bulk
find lib -name "*.dart" -exec grep -l "if[[:space:]]*(" {} \; | \
xargs grep -Hn "if[[:space:]]*(" | \
while IFS=: read -r file line_num line_content; do
  # Quick heuristic checks for potentially long conditions
  if [[ ${#line_content} -gt 80 ]] || [[ "$line_content" == *"&&"* ]] || [[ "$line_content" == *"||"* ]]; then
    # Extract condition between if( and matching ) - handle nested parentheses
    if [[ "$line_content" =~ if[[:space:]]*\( ]]; then
      # Find the matching closing parenthesis by counting parentheses
      temp_line="$line_content"
      # Remove everything up to and including "if ("
      temp_line=${temp_line#*if*\(}

      # Extract condition by counting parentheses
      paren_count=1
      condition=""
      for (( i=0; i<${#temp_line}; i++ )); do
        char="${temp_line:$i:1}"
        if [[ "$char" == "(" ]]; then
          ((paren_count++))
        elif [[ "$char" == ")" ]]; then
          ((paren_count--))
          if [[ $paren_count -eq 0 ]]; then
            break
          fi
        fi
        condition+="$char"
      done

      # Clean up any whitespace
      condition=$(echo "$condition" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

      # Check if it's a long/complex condition
      should_flag=false

      # Check for complex expressions that should be refactored

      # Simple condition with only variable names and logical operators should NOT be flagged
      # Pattern: variable && variable or variable || variable (no dots, no method calls, etc.)
      simple_condition=false
      if [[ "$condition" =~ ^[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*(\|\||&&)[[:space:]]*[!]?[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        simple_condition=true
      fi

      # Don't flag simple conditions
      if [[ "$simple_condition" == true ]]; then
        should_flag=false
      # Don't flag simple string contains checks like e.toString().contains("401")
      elif [[ "$condition" =~ ^[a-zA-Z_][a-zA-Z0-9_]*\.toString\(\)\.contains\([^\)]+\)$ ]]; then
        should_flag=false
      # Flag complex conditions
      else
        # Flag if condition contains property access (dots)
        if [[ "$condition" == *"."* ]]; then
          should_flag=true
        fi

        # Flag if condition contains method calls (parentheses after words)
        if [[ "$condition" == *"("* ]]; then
          should_flag=true
        fi

        # Flag if condition contains null coalescing operator
        if [[ "$condition" == *"??"* ]]; then
          should_flag=true
        fi

        # Flag if condition is very long (regardless of content)
        if [[ ${#condition} -gt 100 ]]; then
          should_flag=true
        fi

        # Flag if has logical operators with non-simple patterns
        if [[ "$condition" == *"&&"* ]] || [[ "$condition" == *"||"* ]]; then
          if [[ ${#condition} -gt 60 ]]; then
            should_flag=true
          fi
        fi
      fi

      if [[ "$should_flag" == true ]]; then
        # Export violation for parent script if needed
        if [[ -n "${VIOLATIONS_OUTPUT:-}" ]]; then
          echo "$file:$line_num: If condition is too long and should be split into variables" >> "$violations_temp"
        else
          echo "$file:$line_num: If condition is too long and should be split into variables" | tee -a "$violations_temp"
        fi

        # Truncate condition for display
        display_condition="$condition"
        if [[ ${#display_condition} -gt 100 ]]; then
          display_condition="${display_condition:0:100}..."
        fi
        echo "    Condition: $display_condition"
      fi
    fi
  fi
done

# Count violations
violations_found=$(wc -l < "$violations_temp" 2>/dev/null || echo "0")
total_files=$(find lib -name "*.dart" -type f | wc -l)

echo ""
echo "Summary:"
echo "  Files checked: $total_files"
echo "  Total violations: $violations_found"

# Export violations markers for parent script if needed
if [[ -n "${VIOLATIONS_OUTPUT:-}" && $violations_found -gt 0 ]]; then
  echo "LONG_CONDITIONS_VIOLATIONS_START" >> "$VIOLATIONS_OUTPUT"
  cat "$violations_temp" >> "$VIOLATIONS_OUTPUT"
  echo "LONG_CONDITIONS_VIOLATIONS_END" >> "$VIOLATIONS_OUTPUT"
fi

# Clean up
rm -f "$violations_temp"

if [[ $violations_found -gt 0 ]]; then
  echo
  echo "Guidelines for if statement conditions:"
  echo "  - BAD:"
  echo "    if (userDataProvider.isLoggedIn &&"
  echo "        (userDataProvider.userProfileModel.classifications?.staff ?? false)) {"
  echo "      // action"
  echo "    }"
  echo
  echo "  + GOOD:"
  echo "    var isLoggedIn = userDataProvider.isLoggedIn;"
  echo "    var isStaff = userDataProvider.userProfileModel.classifications?.staff ?? false;"
  echo "    if (isLoggedIn && isStaff) {"
  echo "      // action"
  echo "    }"
  echo
  echo "Benefits of splitting long conditions:"
  echo "  - Improved readability and maintainability"
  echo "  - Easier debugging and testing"
  echo "  - Better variable naming provides self-documentation"
  echo "  - Reduced cognitive complexity"

  if [[ "$MODE" == "check" ]]; then
    exit 1
  else
    echo "Run with 'check' argument for CI/CD integration."
  fi
fi

if [[ $violations_found -gt 0 ]]; then
  exit 1
else
  exit 0
fi
