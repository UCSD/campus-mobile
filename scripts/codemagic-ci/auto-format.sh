#!/bin/sh
# auto-format.sh - Automatically format Dart code and commit changes if needed

set -e

echo "🔍 Checking Dart code formatting..."

# Change to project root
cd "$(dirname "$0")/../.."

# Check if format script exists
if [ ! -f "scripts/format-files.sh" ]; then
    echo "❌ Error: Format script not found"
    exit 1
fi

# Make sure script is executable
chmod +x scripts/format-files.sh

# Check if formatting is needed
if ./scripts/format-files.sh 100 check; then
    echo "✅ All Dart files are properly formatted!"
    exit 0
else
    echo "🔧 Formatting issues detected! Auto-fixing..."

    # Configure git user for the CI environment
    git config user.name "CodeMagic Auto-Formatter"
    git config user.email "ci@codemagic.io"

    # Format all files
    echo "📝 Running dart format..."
    ./scripts/format-files.sh 100

    # Check if there are any changes to commit
    if git diff --quiet; then
        echo "✅ No changes needed after formatting"
        exit 0
    else
        echo "📤 Committing formatting changes..."

        # Add all dart files that were changed
        git add lib/**/*.dart

        # Create a commit with the formatting changes
        git commit -m "🎨 Auto-format Dart code to 100-character line length

This commit was automatically created by CodeMagic CI to ensure
consistent code formatting across the project.

- Applied dart format with --line-length 100
- All Dart files in lib/ directory formatted
- No functional changes, formatting only"

        # Push the changes back to the PR branch
        if [ -n "$CM_PULL_REQUEST_NUMBER" ]; then
            echo "📤 Pushing formatting changes to PR #$CM_PULL_REQUEST_NUMBER..."
            git push origin HEAD
        else
            echo "📤 Pushing formatting changes to branch..."
            git push origin HEAD
        fi

        echo "✅ Formatting complete! Changes committed and pushed."
        echo "📋 Summary:"
        git log --oneline -1
    fi
fi
