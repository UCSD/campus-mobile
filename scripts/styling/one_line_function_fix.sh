#!/bin/bash
# Enforce arrow syntax for one-line functions
# Usage:
#   ./scripts/styling/one_line_function_fix.sh [--fix] [files...]

set -e

MODE="check"
FILES_TO_PROCESS=()

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --fix)
            MODE="fix"
            shift
            ;;
        *)
            FILES_TO_PROCESS+=("$1")
            shift
            ;;
    esac
done

# If no files specified, find all Dart files in lib
if [[ ${#FILES_TO_PROCESS[@]} -eq 0 ]]; then
    echo "No specific files provided, scanning lib directory..."
    mapfile -t FILES_TO_PROCESS < <(find lib -type f -name "*.dart")
else
    echo "Processing specific files: ${FILES_TO_PROCESS[*]}"
fi

echo "Checking for functions that should use arrow syntax..."

violations_found=0

echo ""
echo "Checking for multi-line functions that could be single line with arrow syntax..."

# Process each specified Dart file
while IFS= read -r filepath; do
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

    # Process lines to find function declarations
    i=1
    while [[ $i -le $line_num ]]; do
        current_line="${file_lines[$i]}"

        # Check for function declaration ending with ) {
        # This matches: returnType functionName(...) {
        if [[ "$current_line" =~ ^[[:space:]]*[a-zA-Z_]+.*[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*\(.*\)[[:space:]]*\{[[:space:]]*$ ]]; then
            next_line_idx=$((i + 1))
            closing_brace_idx=$((i + 2))

            # Check if next line exists and is not empty/comment
            if [[ $next_line_idx -le $line_num && $closing_brace_idx -le $line_num ]]; then
                next_line="${file_lines[$next_line_idx]}"
                closing_line="${file_lines[$closing_brace_idx]}"

                # Check if next line is a return statement and the line after is just }
                if [[ "$next_line" =~ ^[[:space:]]*return[[:space:]]+.*\;[[:space:]]*$ ]] && \
                   [[ "$closing_line" =~ ^[[:space:]]*\}[[:space:]]*$ ]]; then

                    echo "$filepath:$i: Function with single return should use arrow syntax"
                    violations_found=$((violations_found + 1))

                    if [[ "$MODE" == "fix" ]]; then
                        echo "    Fixing: Converting multi-line function to arrow syntax"

                        # Extract function signature (remove trailing { and spaces)
                        function_sig=$(echo "$current_line" | sed 's/[[:space:]]*{[[:space:]]*$//')

                        # Extract return value (remove 'return' and semicolon, keep spaces around operators)
                        return_value=$(echo "$next_line" | sed 's/^[[:space:]]*return[[:space:]]*//' | sed 's/[[:space:]]*;[[:space:]]*$//')

                        # Create fixed line with arrow syntax
                        fixed_line="$function_sig => $return_value;"

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
done < <(printf '%s\n' "${FILES_TO_PROCESS[@]}")

# Summary
echo ""
if [[ $violations_found -gt 0 ]]; then
    if [[ "$MODE" == "fix" ]]; then
        echo "Fixed $violations_found function arrow syntax violation(s)."
        exit 0
    else
        echo "Found $violations_found violation(s) of function arrow syntax convention."
        echo "Run with --fix to see suggestions."
        exit 1
    fi
else
    echo "No violations found! All functions follow the arrow syntax convention."
    exit 0
fi
