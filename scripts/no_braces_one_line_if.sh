#!/bin/bash
# Enforce no curly braces for one-line if statements
# Usage:
#   ./scripts/no_braces_one_line_if.sh [--fix]

set -e

MODE="check"
if [[ "$1" == "--fix" ]]; then
    MODE="fix"
fi

echo "Checking for unnecessary braces in one-line if statements..."

violations_found=0

# Find single-line if statements with braces - simple approach
# Pattern: if (...) { ... }
while IFS= read -r line; do
    filepath=$(echo "$line" | cut -d: -f1)
    line_number=$(echo "$line" | cut -d: -f2)
    line_content=$(echo "$line" | cut -d: -f3-)

    # Skip empty results
    if [[ -z "$filepath" ]]; then
        continue
    fi

    # Check if it's a true single-line if with braces: if (...) { statement; }
    if echo "$line_content" | grep -q "^[[:space:]]*if[[:space:]]*(" && \
       echo "$line_content" | grep -q ")[[:space:]]*{.*}[[:space:]]*$" && \
       ! echo "$line_content" | grep -q '\${'; then

        # Count semicolons to ensure it's a single statement
        semicolon_count=$(echo "$line_content" | tr -cd ';' | wc -c)

        if [[ $semicolon_count -eq 1 ]]; then
            echo "  $filepath:$line_number: One-line if statement should not use braces"
            echo "    $line_content"
            violations_found=$((violations_found + 1))

            if [[ "$MODE" == "fix" ]]; then
                # Extract if condition and statement
                if_part=$(echo "$line_content" | sed 's/{.*$//')
                statement=$(echo "$line_content" | sed 's/^.*{//' | sed 's/}[[:space:]]*$//')
                echo "    Suggestion: ${if_part} ${statement}"
            fi
        fi
    fi
done < <(grep -rn --include="*.dart" "if.*{.*}" lib/ 2>/dev/null || true)

# Check for multi-line if statements that could be single line
echo ""
echo "Checking for multi-line if statements that could be single line..."

# Simple pattern: if (...) { followed by single statement followed by }
temp_results=$(mktemp)

find lib -type f -name "*.dart" -exec awk '
BEGIN {
    in_if = 0
    if_line_num = 0
    if_content = ""
    statement_count = 0
    statements = ""
}
/^[[:space:]]*if[[:space:]]*\(.*\)[[:space:]]*{[[:space:]]*$/ {
    if (in_if == 0) {
        in_if = 1
        if_line_num = NR
        if_content = $0
        statement_count = 0
        statements = ""
    }
    next
}
in_if == 1 && /^[[:space:]]*}[[:space:]]*$/ {
    if (statement_count == 1) {
        print FILENAME ":" if_line_num ": One-line if statement should not use braces"
        print "    " if_content
        print "    " statements
        print "    }"
    }
    in_if = 0
    next
}
in_if == 1 && !/^[[:space:]]*$/ && !/^[[:space:]]*\/\// {
    statement_count++
    if (statements == "") {
        statements = $0
    } else {
        statements = statements "\n    " $0
    }
}
' {} \; > "$temp_results"

# Count and display multi-line violations
if [[ -s "$temp_results" ]]; then
    cat "$temp_results"
    multiline_violations=$(grep -c "should not use braces" "$temp_results")
    violations_found=$((violations_found + multiline_violations))
fi

rm -f "$temp_results"

# Summary
echo ""
if [[ $violations_found -gt 0 ]]; then
    echo "Found $violations_found violation(s) of one-line if brace convention."
    if [[ "$MODE" != "fix" ]]; then
        echo "Run with --fix to see suggestions."
    fi
    exit 1
else
    echo "No violations found! All if statements follow the convention."
    exit 0
fi
