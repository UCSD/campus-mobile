#!/bin/sh
# check-formatting.sh - Check Dart formatting for CodeMagic CI

set -e

echo "Checking Dart code formatting..."

# Change to project root
cd "$(dirname "$0")/../.."

# Check if format script exists
if [ ! -f "scripts/format-files.sh" ]; then
    echo "Error: Format script not found"
    exit 1
fi

# Make sure script is executable
chmod +x scripts/format-files.sh

# Run formatting check
if ./scripts/format-files.sh 100 check; then
    echo "All Dart files are properly formatted."
else
    echo "Formatting issues detected!"
    echo ""
    echo "Files that need formatting:"
    ./scripts/format-files.sh 100 dry
    echo ""
    echo "Run './scripts/format-files.sh' to fix formatting issues."
    exit 1
fi
