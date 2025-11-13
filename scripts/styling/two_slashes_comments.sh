#!/bin/bash
# Script to fix comment formatting to use exactly two slashes
# This script ensures that regular comments and TODO comments use exactly two slashes (//)
# while preserving function headers, class headers, file headers, and comment divisors

set -euo pipefail

# Get script directory and repository root
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/../.." && pwd)"
cd "$repo_root"

# Default mode
MODE="fix"

# Parse command line arguments
for arg in "$@"; do
  case $arg in
    --dry-run)
      MODE="dry-run"
      shift
      ;;
    --check)
      MODE="check"
      shift
      ;;
    *)
      echo "Unknown option: $arg"
      echo "Usage: $0 [--dry-run|--check]"
      echo "  --dry-run: Show what would be changed without making changes"
      echo "  --check: Check for violations and exit with error code if found"
      exit 1
      ;;
  esac
done

echo "========================================"
echo "Fixing Comment Slash Formatting"
echo "========================================"
echo "Mode: $MODE"
echo

# Counters
files_processed=0
files_changed=0
total_changes=0

# Function to check if a line is a header comment (function, class, or file header)
is_header_comment() {
    local line="$1"

    # File headers (usually at the top, contain copyright, license, etc.)
    if [[ "$line" =~ ^[[:space:]]*///[[:space:]]*(Copyright|License|Author|File|Created|Modified|Description|@file|@author|@license|@copyright) ]]; then
        return 0
    fi

    # Documentation comments (dartdoc style)
    if [[ "$line" =~ ^[[:space:]]*///[[:space:]]*@(param|return|throws|example|since|deprecated) ]]; then
        return 0
    fi

    # Function/class/method documentation (dartdoc style - starts with ///)
    # These are typically followed by function/class declarations
    if [[ "$line" =~ ^[[:space:]]*///[[:space:]]*[A-Z] ]]; then
        return 0
    fi

    return 1
}

# Function to check if a line is a comment divisor (4+ slashes)
is_comment_divisor() {
    local line="$1"

    # Comment divisors: ////, /////, etc. (4 or more slashes)
    if [[ "$line" =~ ^[[:space:]]*/{4,}[[:space:]]*$ ]] || [[ "$line" =~ ^[[:space:]]*/{4,}[[:space:]]*[/=-]+[[:space:]]*$ ]]; then
        return 0
    fi

    return 1
}

# Function to process a single file
process_file() {
    local file_path="$1"
    local temp_file=$(mktemp)
    local file_changed=false
    local line_number=0
    local changes_in_file=0

    while IFS= read -r line; do
        ((line_number++))
        original_line="$line"

        # Check if this is a comment line that starts with /// (3 slashes)
        if [[ "$line" =~ ^([[:space:]]*)//// ]]; then
            # Skip lines with 4+ slashes (comment divisors)
            if is_comment_divisor "$line"; then
                echo "$line" >> "$temp_file"
                continue
            fi
        fi

        if [[ "$line" =~ ^([[:space:]]*)///([[:space:]]*.*) ]]; then
            # Extract indentation and comment content
            local indentation="${BASH_REMATCH[1]}"
            local comment_content="${BASH_REMATCH[2]}"

            # Skip comment divisors
            if is_comment_divisor "$line"; then
                echo "$line" >> "$temp_file"
                continue
            fi

            # Skip header comments
            if is_header_comment "$line"; then
                echo "$line" >> "$temp_file"
                continue
            fi

            # Convert /// to // for regular comments
            local new_line="${indentation}//${comment_content}"

            if [[ "$new_line" != "$original_line" ]]; then
                ((changes_in_file++))
                ((total_changes++))
                file_changed=true

                if [[ "$MODE" == "dry-run" ]]; then
                    echo "  Line $line_number: '$original_line' -> '$new_line'"
                fi
            fi

            echo "$new_line" >> "$temp_file"
        else
            # Not a comment line starting with ///, keep as is
            echo "$line" >> "$temp_file"
        fi
    done < "$file_path"

    if [[ "$file_changed" == true ]]; then
        ((files_changed++))

        if [[ "$MODE" == "dry-run" ]]; then
            echo "Would change $changes_in_file lines in: $file_path"
        elif [[ "$MODE" == "check" ]]; then
            echo "Found $changes_in_file comment formatting violations in: $file_path"
        else
            # Actually apply the changes
            mv "$temp_file" "$file_path"
            echo "Fixed $changes_in_file comment formatting issues in: $file_path"
        fi
    else
        if [[ "$MODE" == "dry-run" ]]; then
            echo "No changes needed in: $file_path"
        fi
    fi

    # Clean up temp file if not used
    if [[ -f "$temp_file" ]]; then
        rm -f "$temp_file"
    fi

    ((files_processed++))
}

# Find all Dart files and process them
echo "Processing Dart files in lib/ directory..."
echo

# Process all .dart files in lib/
find lib/ -name "*.dart" -type f | while read -r dart_file; do
    process_file "$dart_file"
done

echo
echo "========================================"
echo "Summary:"
echo "  Files processed: $files_processed"
echo "  Files with changes: $files_changed"
echo "  Total changes: $total_changes"

if [[ "$MODE" == "check" ]] && [[ $total_changes -gt 0 ]]; then
    echo
    echo "❌ Found comment formatting violations!"
    echo "Run this script without --check to fix them automatically."
    exit 1
elif [[ "$MODE" == "dry-run" ]] && [[ $total_changes -gt 0 ]]; then
    echo
    echo "Run this script without --dry-run to apply these changes."
elif [[ $total_changes -eq 0 ]]; then
    echo "✅ All comments are properly formatted with two slashes!"
fi

exit 0
