#!/bin/bash
# Enforce proper spacing after double slashes in comments
# Usage:
#   ./scripts/comment_space.sh [--fix]

set -e

MODE="check"
if [[ "$1" == "--fix" ]]; then
    MODE="fix"
fi

echo "Checking for proper spacing after // in comments..."

violations_found=0

# Create a temporary file to store results
temp_file=$(mktemp)

# Find all comments that don't have space after // (but aren't URLs or special cases)
# Use a simple approach: look for // followed immediately by alphanumeric characters
grep -rn --include="*.dart" "//[a-zA-Z0-9]" lib/ > "$temp_file" 2>/dev/null || true

# Process the results
while IFS=: read -r filepath line_number line_content; do
    if [[ -n "$filepath" && -n "$line_number" && -n "$line_content" ]]; then
        # Skip URLs (http://, https://, ftp://, etc.)
        if [[ "$line_content" =~ https?://|ftp://|file:// ]]; then
            continue
        fi

        # Skip documentation comments (///) - these are handled differently
        if [[ "$line_content" =~ /// ]]; then
            continue
        fi

        # Skip comment blocks that are intentionally formatted (like /////// separators)
        if [[ "$line_content" =~ ////+ ]]; then
            continue
        fi

        # Skip single-line comment disabling (like //ignore or //TODO without space might be intentional)
        # But still catch most cases
        echo "  $filepath:$line_number: Comment missing space after //"
        echo "    $line_content"
        violations_found=$((violations_found + 1))

        if [[ "$MODE" == "fix" ]]; then
            # Actually fix the file by adding space after //
            fixed_line=$(echo "$line_content" | sed 's|//\([^ /]\)|// \1|g')
            echo "    Fixing: $fixed_line"

            # Use a simpler approach to fix the line
            # Create backup first
            cp "$filepath" "$filepath.bak"

            # Use awk to fix the specific line
            awk -v ln="$line_number" -v new_line="$fixed_line" 'NR==ln {print new_line; next} {print}' "$filepath" > "$filepath.tmp" && mv "$filepath.tmp" "$filepath"
        fi
    fi
done < "$temp_file"

# Clean up
rm -f "$temp_file"

# Count total files scanned
total_files=$(find lib -type f -name "*.dart" | wc -l)

echo
echo "Comment spacing check complete."
echo "Files scanned: $total_files"
echo "Violations found: $violations_found"

if [[ $violations_found -gt 0 ]]; then
    if [[ "$MODE" == "fix" ]]; then
        echo "Fixed $violations_found comment spacing violation(s)."
        exit 0
    else
        echo "Comments should have a space after //"
        echo "   GOOD: // This is a proper comment"
        echo "   BAD:  //This comment is missing a space"
        exit 1
    fi
else
    echo "All comments have proper spacing after //"
    exit 0
fi
