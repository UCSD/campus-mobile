#!/bin/bash
# Enforce TODO comments format: two slashes and include month/year date
# Usage:
#   ./scripts/todo_date_check.sh [--fix]

set -e

MODE="check"
if [[ "$1" == "--fix" ]]; then
    MODE="fix"
fi

# Function to check if a TODO has proper date format
has_valid_date() {
    local todo_text="$1"

    # Pattern 1: Full month name + year (e.g., "November 2025", "Dec 2024")
    if [[ "$todo_text" =~ (January|February|March|April|May|June|July|August|September|October|November|December|Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[[:space:]]+20[0-9]{2} ]]; then
        return 0
    fi

    # Pattern 2: Short month + 2-digit year (e.g., "Nov 25", "Dec 24")
    if [[ "$todo_text" =~ (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[[:space:]]+[0-9]{2}[[:space:]] ]]; then
        return 0
    fi

    # Pattern 3: Numeric month/year format (e.g., "11/2025", "12/24")
    if [[ "$todo_text" =~ [0-9]{1,2}/20[0-9]{2} ]] || [[ "$todo_text" =~ [0-9]{1,2}/[0-9]{2}[[:space:]] ]]; then
        return 0
    fi

    return 1
}

# Function to suggest a date format
suggest_date_format() {
    local current_date=$(date "+%B %Y")
    echo "$current_date"
}

echo "Checking TODO comments for proper format (// with date)..."

violations_found=0

# Create a temporary file to store results
temp_file=$(mktemp)

# Find all TODO comments
grep -rn --include="*.dart" "TODO" lib/ > "$temp_file" 2>/dev/null || true

# Process the results
while IFS=: read -r filepath line_number line_content; do
    if [[ -n "$filepath" && -n "$line_number" && -n "$line_content" ]]; then
        # Check if it's a TODO comment (not just TODO in string or other context)
        if [[ "$line_content" =~ //.*TODO ]] || [[ "$line_content" =~ ///.*TODO ]]; then

            # Check if it uses three slashes (should use two)
            if [[ "$line_content" =~ ///.*TODO ]]; then
                echo "  $filepath:$line_number: TODO should use // not ///"
                echo "    $line_content"
                violations_found=$((violations_found + 1))

                if [[ "$MODE" == "fix" ]]; then
                    # Suggest changing /// to //
                    fixed_line=$(echo "$line_content" | sed 's|///\(.*TODO\)|//\1|')
                    echo "    Suggestion: $fixed_line"
                fi
                continue
            fi

            # Check if it has proper date format
            if ! has_valid_date "$line_content"; then
                echo "  $filepath:$line_number: TODO missing date (month and year)"
                echo "    $line_content"
                violations_found=$((violations_found + 1))

                if [[ "$MODE" == "fix" ]]; then
                    # Suggest adding current date
                    suggested_date=$(suggest_date_format)
                    # Try to add date before any existing description
                    if [[ "$line_content" =~ TODO:[[:space:]]* ]]; then
                        fixed_line=$(echo "$line_content" | sed "s|TODO:[[:space:]]*|TODO: |" | sed "s|TODO: \(.*\)|TODO: \1 - $suggested_date|")
                    else
                        fixed_line=$(echo "$line_content" | sed "s|TODO\(.*\)|TODO\1 - $suggested_date|")
                    fi
                    echo "    Suggestion: $fixed_line"
                fi
            fi
        fi
    fi
done < "$temp_file"

# Clean up
rm -f "$temp_file"

# Count total files scanned
total_files=$(find lib -type f -name "*.dart" | wc -l)

echo
echo "TODO comment check complete."
echo "Files scanned: $total_files"
echo "Violations found: $violations_found"

if [[ $violations_found -gt 0 ]]; then
    echo "TODO comments must use // (not ///) and include month/year date"
    echo "   GOOD: // TODO: Fix this issue - November 2025"
    echo "   GOOD: // TODO: Update code Nov 25"
    echo "   GOOD: // TODO: Refactor - 11/2025"
    echo "   BAD:  /// TODO: Fix this (wrong slashes)"
    echo "   BAD:  // TODO: Fix this (missing date)"
    exit 1
else
    echo "All TODO comments follow proper format"
    exit 0
fi
