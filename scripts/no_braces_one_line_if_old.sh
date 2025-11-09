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

echo ""
echo "Checking for multi-line if statements that could be single line..."

# Process each Dart file to find and fix multi-line if statements that should be single line
find lib -type f -name "*.dart" | while read -r filepath; do
    if [[ ! -f "$filepath" ]]; then
        continue
    fi

    # Use a simpler approach - read the file into memory and process line by line
    file_modified=false
    declare -a file_lines
    line_num=0

    # Read entire file into array
    while IFS= read -r line; do
        line_num=$((line_num + 1))
        file_lines[$line_num]="$line"
    done < "$filepath"

    # Process lines to find if statements
    i=1
    while [[ $i -le $line_num ]]; do
        current_line="${file_lines[$i]}"

        # Check for if statement opening: if (...) {
        if [[ "$current_line" =~ ^[[:space:]]*if[[:space:]]*\(.*\)[[:space:]]*\{[[:space:]]*$ ]]; then
            next_line_idx=$((i + 1))
            closing_brace_idx=$((i + 2))

            # Check if next line exists and is not empty/comment
            if [[ $next_line_idx -le $line_num && $closing_brace_idx -le $line_num ]]; then
                next_line="${file_lines[$next_line_idx]}"
                closing_line="${file_lines[$closing_brace_idx]}"

                # Check if next line is a statement and the line after is just }
                if [[ ! "$next_line" =~ ^[[:space:]]*$ ]] && \
                   [[ ! "$next_line" =~ ^[[:space:]]*// ]] && \
                   [[ "$closing_line" =~ ^[[:space:]]*\}[[:space:]]*$ ]]; then

                    echo "$filepath:$i: One-line if statement should not use braces"
                    violations_found=$((violations_found + 1))

                    if [[ "$MODE" == "fix" ]]; then
                        echo "    Fixing: Converting multi-line if to single line"

                        # Extract condition (remove trailing { and spaces)
                        condition=$(echo "$current_line" | sed 's/[[:space:]]*{[[:space:]]*$//')

                        # Extract statement (remove leading/trailing spaces but keep semicolon)
                        statement=$(echo "$next_line" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')

                        # Create fixed line
                        fixed_line="$condition $statement"

                        # Mark file as modified
                        file_modified=true

                        # Replace the three lines with one
                        file_lines[$i]="$fixed_line"
                        unset file_lines[$next_line_idx]
                        unset file_lines[$closing_brace_idx]

                        echo "    Fixed: $fixed_line"
                    fi

                    # Skip the processed lines
                    i=$((closing_brace_idx + 1))
                    continue
                fi
            fi
        fi

        i=$((i + 1))
    done

    # Write back modified file if changes were made
    if [[ "$file_modified" == "true" ]]; then
        # Create backup
        cp "$filepath" "$filepath.bak"

        # Write modified content
        > "$filepath"  # Clear file
        for ((j=1; j<=line_num; j++)); do
            if [[ -n "${file_lines[$j]+x}" ]]; then  # Check if element exists
                echo "${file_lines[$j]}" >> "$filepath"
            fi
        done
    fi

    unset file_lines
done# Summary
echo ""
if [[ $violations_found -gt 0 ]]; then
    if [[ "$MODE" == "fix" ]]; then
        echo "Fixed $violations_found one-line if brace violation(s)."
        exit 0
    else
        echo "Found $violations_found violation(s) of one-line if brace convention."
        echo "Run with --fix to see suggestions."
        exit 1
    fi
else
    echo "No violations found! All if statements follow the convention."
    exit 0
fi
