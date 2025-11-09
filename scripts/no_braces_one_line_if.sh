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
echo ""
echo "Checking for multi-line if statements that could be single line..."

violations_found=0

# Process each Dart file
while IFS= read -r filepath; do
    if [[ ! -f "$filepath" ]]; then
        continue
    fi

    file_violations=0

    # First pass - count violations and report them
    awk '
    BEGIN {
        violations = 0
        line_num = 0
    }
    {
        line_num++
        # Store current line
        current_line = $0

        # Check if this is an if statement with opening brace
        if ($0 ~ /^[[:space:]]*if[[:space:]]*\(.*\)[[:space:]]*{[[:space:]]*$/) {
            # Read next line
            if ((getline next_line) > 0) {
                line_num++
                # Read third line
                if ((getline third_line) > 0) {
                    line_num++
                    # Check if it matches our pattern
                    if (third_line ~ /^[[:space:]]*}[[:space:]]*$/ &&
                        next_line !~ /^[[:space:]]*$/ &&
                        next_line !~ /^[[:space:]]*\/\//) {

                        print FILENAME ":" (line_num - 2) ": One-line if statement should not use braces"
                        violations++
                    }
                }
            }
        }
    }
    END {
        if (violations > 0) exit 1
        else exit 0
    }
    ' "$filepath"

    # Check if violations were found
    if [[ $? -eq 1 ]]; then
        file_violations=1
        violations_found=$((violations_found + 1))

        if [[ "$MODE" == "fix" ]]; then
            echo "    Fixing violations in $filepath"

            # Create backup
            cp "$filepath" "$filepath.bak"

            # Second pass - actually fix the file
            awk '
            BEGIN { line_num = 0 }
            {
                line_num++
                current_line = $0

                # Check for if statement with opening brace
                if ($0 ~ /^[[:space:]]*if[[:space:]]*\(.*\)[[:space:]]*{[[:space:]]*$/) {
                    # Peek at next two lines
                    if ((getline next_line) > 0) {
                        line_num++
                        if ((getline third_line) > 0) {
                            line_num++
                            # Check if it matches our fix pattern
                            if (third_line ~ /^[[:space:]]*}[[:space:]]*$/ &&
                                next_line !~ /^[[:space:]]*$/ &&
                                next_line !~ /^[[:space:]]*\/\//) {

                                # Create fixed line
                                gsub(/[[:space:]]*{[[:space:]]*$/, "", current_line)
                                gsub(/^[[:space:]]*/, "", next_line)
                                gsub(/[[:space:]]*$/, "", next_line)

                                fixed_line = current_line " " next_line
                                print fixed_line

                                # Skip the closing brace (third_line)
                                continue
                            } else {
                                # Not our pattern, print all three lines
                                print current_line
                                print next_line
                                print third_line
                            }
                        } else {
                            # Only two lines, print both
                            print current_line
                            print next_line
                        }
                    } else {
                        # Only one line, print it
                        print current_line
                    }
                } else {
                    # Regular line, print it
                    print current_line
                }
            }
            ' "$filepath" > "$filepath.tmp" && mv "$filepath.tmp" "$filepath"
        fi
    fi
done < <(find lib -type f -name "*.dart")

echo ""
if [[ $violations_found -gt 0 ]]; then
    if [[ "$MODE" == "fix" ]]; then
        echo "Fixed $violations_found one-line if brace violation(s)."
        exit 0
    else
        echo "Found $violations_found violation(s) of one-line if brace convention."
        echo "Run with --fix to automatically fix them."
        exit 1
    fi
else
    echo "No violations found! All if statements follow the convention."
    exit 0
fi
