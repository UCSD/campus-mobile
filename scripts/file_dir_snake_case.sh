#!/bin/bash
# Enforce snake_case naming for files and directories in lib/
# Usage:
#   ./scripts/file_dir_snake_case.sh

set -e

MODE="check"
if [[ "$1" == "--fix" ]]; then
    MODE="fix"
fi

# Function to check if name follows snake_case convention
is_snake_case() {
    local name="$1"
    # Remove .dart extension if present
    name="${name%.dart}"
    # Also handle generated files like .g.dart, .freezed.dart, etc.
    name="${name%.g}"
    name="${name%.freezed}"
    name="${name%.mocks}"

    # Basic snake_case: lowercase letters, digits, and underscores only
    if ! [[ "$name" =~ ^[a-z][a-z0-9_]*$ ]]; then
        return 1
    fi

    # Additional check: reject names that look like they have concatenated words
    # This catches cases like "mystudentchart" which should be "my_student_chart"
    # Look for patterns where lowercase is followed by another word that should be separated
    if [[ "$name" =~ (my|student|chart|ucsd|page|view|card|list|item|data|info|home|main|app|user|profile|settings|detail|edit|create|update|delete) ]] && [[ ! "$name" =~ _ ]]; then
        # If it contains common words but no underscores, it might need separation
        # But allow single word names and properly separated names
        local word_count=$(echo "$name" | grep -o -E "(my|student|chart|ucsd|page|view|card|list|item|data|info|home|main|app|user|profile|settings|detail|edit|create|update|delete)" | wc -l)
        if [[ $word_count -gt 1 ]]; then
            return 1
        fi
    fi

    return 0
}

# Function to convert to snake_case
to_snake_case() {
    local name="$1"
    local result="$name"

    # Handle PascalCase/camelCase first
    result=$(echo "$result" | sed -E 's/([A-Z])/_\L\1/g' | sed 's/^_//' | tr '[:upper:]' '[:lower:]')

    # Handle common word patterns for concatenated lowercase words
    result=$(echo "$result" | sed -E 's/my([a-z])/my_\1/g')
    result=$(echo "$result" | sed -E 's/student([a-z])/student_\1/g')
    result=$(echo "$result" | sed -E 's/chart([a-z])/chart_\1/g')
    result=$(echo "$result" | sed -E 's/ucsd([a-z])/ucsd_\1/g')
    result=$(echo "$result" | sed -E 's/([a-z])chart/\1_chart/g')
    result=$(echo "$result" | sed -E 's/([a-z])page/\1_page/g')
    result=$(echo "$result" | sed -E 's/([a-z])view/\1_view/g')
    result=$(echo "$result" | sed -E 's/([a-z])card/\1_card/g')

    echo "$result"
}

echo "Checking file and directory naming conventions..."

violations_found=0

# Check files
echo "Checking files in lib/..."
while IFS= read -r filepath; do
    if [[ -n "$filepath" ]]; then
        filename=$(basename "$filepath")

        if ! is_snake_case "$filename"; then
            echo "  $filepath: File '$filename' should be snake_case"
            violations_found=$((violations_found + 1))
            if [[ "$MODE" == "fix" ]]; then
                suggested=$(to_snake_case "$filename")
                echo "    Suggestion: $filename -> $suggested"
            fi
        fi
    fi
done < <(find lib -type f -name "*.dart")

# Check directories
echo "Checking directories in lib/..."
while IFS= read -r dirpath; do
    if [[ -n "$dirpath" && "$dirpath" != "lib" ]]; then
        dirname=$(basename "$dirpath")

        if ! is_snake_case "$dirname"; then
            echo "  $dirpath/: Directory '$dirname' should be snake_case"
            violations_found=$((violations_found + 1))
            if [[ "$MODE" == "fix" ]]; then
                suggested=$(to_snake_case "$dirname")
                echo "    Suggestion: $dirname -> $suggested"
            fi
        fi
    fi
done < <(find lib -type d -not -path "lib")

echo
echo "File and Directory naming check complete."
echo "Violations found: $violations_found"

if [[ $violations_found -gt 0 ]]; then
    echo "Files and directories should use snake_case naming convention"
    exit 1
else
    echo "All files and directories follow snake_case naming convention"
    exit 0
fi
