#!/bin/bash
# Enforce full package import paths (no relative imports)
# Usage:
#   ./scripts/enforce_package_imports.sh [--fix]

set -e

MODE="check"
if [[ "$1" == "--fix" ]]; then
    MODE="fix"
fi

# Get the package name from pubspec.yaml
get_package_name() {
    if [[ -f "pubspec.yaml" ]]; then
        grep "^name:" pubspec.yaml | sed 's/name: *//' | tr -d '"'"'"
    else
        echo "campus_mobile_experimental"  # fallback
    fi
}

PACKAGE_NAME=$(get_package_name)

echo "Checking for relative imports in Dart files..."
echo "Package name: $PACKAGE_NAME"

violations_found=0

# Simple approach: use grep to find all relative imports
echo "Scanning for relative imports..."

# Create a temporary file to store results
temp_file=$(mktemp)

# Find all relative imports and save to temp file
find lib -type f -name "*.dart" -exec grep -Hn "^[[:space:]]*import[[:space:]]*['\"][.][.]" {} \; > "$temp_file" 2>/dev/null || true

# Process the results
while IFS=: read -r filepath line_number line_content; do
    if [[ -n "$filepath" && -n "$line_number" && -n "$line_content" ]]; then
        echo "  $filepath:$line_number: Relative import found"
        echo "    $line_content"
        violations_found=$((violations_found + 1))

        if [[ "$MODE" == "fix" ]]; then
            # Extract the relative path
            rel_path=$(echo "$line_content" | sed -E "s/.*import[[:space:]]*['\"]([^'\"]+)['\"].*/\1/")

            # Simple suggestion: convert ../path to package:$PACKAGE_NAME/path
            suggested_path=$(echo "$rel_path" | sed 's|\.\./||g')

            # Determine quote style
            if [[ "$line_content" =~ \" ]]; then
                quote='"'
            else
                quote="'"
            fi

            echo "    Suggestion: import ${quote}package:${PACKAGE_NAME}/${suggested_path}${quote};"
        fi
    fi
done < "$temp_file"

# Clean up
rm -f "$temp_file"

# Count total files scanned
total_files=$(find lib -type f -name "*.dart" | wc -l)

echo
echo "Import path check complete."
echo "Files scanned: $total_files"
echo "Violations found: $violations_found"

if [[ $violations_found -gt 0 ]]; then
    echo "Use package imports instead of relative imports"
    echo "   GOOD: import 'package:$PACKAGE_NAME/core/providers/map.dart';"
    echo "   BAD:  import '../../core/providers/map.dart';"
    exit 1
else
    echo "All imports use package import paths"
    exit 0
fi
