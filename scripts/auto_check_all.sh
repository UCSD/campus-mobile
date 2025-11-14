#!/bin/bash
# Auto checks all the code to report violations back to the developer
# Usage:
# ./scripts/auto_check_all.sh
# ./scripts/auto_check_all.sh --dry-run # preview what would be fixed

# Catch errors early
set -e

# Set up working directory
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
cd "$repo_root"

# Check --dry-run flag
DRY_RUN=false
if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=true
fi

echo "==================================="
echo "Checking Current Code Style..."
echo "==================================="

if [[ "$DRY_RUN" == "true" ]]; then
    echo "DRY RUN MODE - No changes will be made"
    echo
    echo "Would run the following checks:"
    echo "1. Check static constants have FULL_UPPER_SNAKE_CASE"
    echo "2. Check package imports contain The/Full/Path"
    echo "3. Check classes have UpperCamelCase"
    echo "4. Check file and directory names have lower_snake_case"
    echo "5. Check variable and function names have lowerCamelCase"
    echo "6. Check very long if statement conditions"
    echo
    exit 0
fi

# Track fixes applied
violations=0
total_violations=0

# Create a temporary file to collect all violations
# Use existing VIOLATIONS_OUTPUT if set, otherwise create a new temp file
if [[ -n "${VIOLATIONS_OUTPUT:-}" ]]; then
    violations_file="$VIOLATIONS_OUTPUT"
    echo "Using existing violations file: $violations_file"
else
    violations_file=$(mktemp)
    echo "Created new violations file: $violations_file"
fi
export VIOLATIONS_OUTPUT="$violations_file"

# Array to store check results and violation counts
declare -A check_results
declare -A violation_counts

# First Check - Ensure all static const variables use FULL_UPPER_SNAKE_CASE
echo "1. Checking static constants have FULL_UPPER_SNAKE_CASE..."
if bash ./scripts/checking/check_static_const_upper_snake_case.sh check; then
    check_results["static_const"]="PASSED"
    violation_counts["static_const"]=0
    echo "All static constants follow UPPER_SNAKE_CASE naming convention."
else
    check_results["static_const"]="FAILED"
    # Count violations from the violations file
    static_const_violations=$(grep -A999 "STATIC_CONST_VIOLATIONS_START" "$violations_file" 2>/dev/null | grep -B999 "STATIC_CONST_VIOLATIONS_END" | grep -v "VIOLATIONS_" | wc -l || echo "0")
    violation_counts["static_const"]=$static_const_violations
    violations=$((violations + 1))
    total_violations=$((total_violations + static_const_violations))
fi
echo
echo "====================================================================="

# Second Check - Ensure all package imports contain The/Full/Path
echo "2. Checking package imports contain The/Full/Path..."
if bash ./scripts/checking/check_package_imports.sh check; then
    check_results["package_imports"]="PASSED"
    violation_counts["package_imports"]=0
    echo "All imports use package import paths."
else
    check_results["package_imports"]="FAILED"
    package_import_violations=$(grep -A999 "PACKAGE_IMPORT_VIOLATIONS_START" "$violations_file" 2>/dev/null | grep -B999 "PACKAGE_IMPORT_VIOLATIONS_END" | grep -v "VIOLATIONS_" | wc -l || echo "0")
    violation_counts["package_imports"]=$package_import_violations
    violations=$((violations + 1))
    total_violations=$((total_violations + package_import_violations))
fi
echo
echo "====================================================================="

# Third Check - Ensure all classes use UpperCamelCase
echo "3. Checking classes have UpperCamelCase..."
if bash ./scripts/checking/check_classes_have_upper_camel_case.sh check; then
    check_results["class_naming"]="PASSED"
    violation_counts["class_naming"]=0
    echo "All classes follow UpperCamelCase naming convention."
else
    check_results["class_naming"]="FAILED"
    class_naming_violations=$(grep -A999 "CLASS_NAMING_VIOLATIONS_START" "$violations_file" 2>/dev/null | grep -B999 "CLASS_NAMING_VIOLATIONS_END" | grep -v "VIOLATIONS_" | wc -l || echo "0")
    violation_counts["class_naming"]=$class_naming_violations
    violations=$((violations + 1))
    total_violations=$((total_violations + class_naming_violations))
fi
echo
echo "====================================================================="

# Fourth Check - Ensure all file and directory names use lower_snake_case
echo "4. Checking file and directory names have lower_snake_case..."
if bash ./scripts/checking/check_files_directories_have_snake_case.sh check; then
    check_results["file_dir_naming"]="PASSED"
    violation_counts["file_dir_naming"]=0
    echo "All files and directories follow snake_case naming convention."
else
    check_results["file_dir_naming"]="FAILED"
    file_dir_violations=$(grep -A999 "FILE_DIR_NAMING_VIOLATIONS_START" "$violations_file" 2>/dev/null | grep -B999 "FILE_DIR_NAMING_VIOLATIONS_END" | grep -v "VIOLATIONS_" | wc -l || echo "0")
    violation_counts["file_dir_naming"]=$file_dir_violations
    violations=$((violations + 1))
    total_violations=$((total_violations + file_dir_violations))
fi
echo
echo "====================================================================="

# Fifth Check - Ensure all variable and function names use lowerCamelCase
echo "5. Checking variable and function names have lowerCamelCase..."
if bash ./scripts/checking/check_var_func_lower_camel_case.sh check; then
    check_results["variable_naming"]="PASSED"
    violation_counts["variable_naming"]=0
    echo "All variables and functions follow lowerCamelCase naming convention."
else
    check_results["variable_naming"]="FAILED"
    variable_violations=$(grep -A999 "VARIABLE_NAMING_VIOLATIONS_START" "$violations_file" 2>/dev/null | grep -B999 "VARIABLE_NAMING_VIOLATIONS_END" | grep -v "VIOLATIONS_" | wc -l || echo "0")
    violation_counts["variable_naming"]=$variable_violations
    violations=$((violations + 1))
    total_violations=$((total_violations + variable_violations))
fi
echo
echo "====================================================================="

# Sixth Check - Ensure no very long if statement conditions
echo "6. Checking very long if statement conditions..."
if bash ./scripts/checking/check_very_long_conditions.sh check; then
    check_results["long_conditions"]="PASSED"
    violation_counts["long_conditions"]=0
    echo "No very long if statement conditions found."
else
    check_results["long_conditions"]="FAILED"
    long_condition_violations=$(grep -A999 "LONG_CONDITIONS_VIOLATIONS_START" "$violations_file" 2>/dev/null | grep -B999 "LONG_CONDITIONS_VIOLATIONS_END" | grep -v "VIOLATIONS_" | wc -l || echo "0")
    violation_counts["long_conditions"]=$long_condition_violations
    violations=$((violations + 1))
    total_violations=$((total_violations + long_condition_violations))
fi
echo
echo "====================================================================="
echo "Code Style Check Summary"
echo "Total violation categories: $violations/6"
echo "Total individual violations: $total_violations"

if [[ $violations -eq 0 ]]; then
    echo "All checks passed! Your code follows all style guidelines."
    echo
    # Clean up
    rm -f "$violations_file"
    exit 0
else
    echo "Code style violations found. Please address the following issues:"
    echo

    # Export detailed violations for the GitHub workflow
    if [[ -s "$violations_file" ]]; then
        echo "VIOLATIONS_DETAILS_START" >> "$violations_file"
        echo "Total Categories Failed: $violations/6" >> "$violations_file"
        echo "Total Individual Violations: $total_violations" >> "$violations_file"
        echo "Check Results:" >> "$violations_file"
        echo "- Static Constants (UPPER_SNAKE_CASE): ${check_results[static_const]} (${violation_counts[static_const]} violations)" >> "$violations_file"
        echo "- Package Imports: ${check_results[package_imports]} (${violation_counts[package_imports]} violations)" >> "$violations_file"
        echo "- Class Naming (UpperCamelCase): ${check_results[class_naming]} (${violation_counts[class_naming]} violations)" >> "$violations_file"
        echo "- File/Directory Naming (snake_case): ${check_results[file_dir_naming]} (${violation_counts[file_dir_naming]} violations)" >> "$violations_file"
        echo "- Variable Naming (lowerCamelCase): ${check_results[variable_naming]} (${violation_counts[variable_naming]} violations)" >> "$violations_file"
        echo "- Very Long If Statement Conditions: ${check_results[long_conditions]} (${violation_counts[long_conditions]} violations)" >> "$violations_file"
        echo "VIOLATIONS_DETAILS_END" >> "$violations_file"
    fi

    # Display summary to user
    echo "Failed checks:"
    [[ "${check_results[static_const]}" == "FAILED" ]] && echo "  - Static Constants: ${violation_counts[static_const]} violations"
    [[ "${check_results[package_imports]}" == "FAILED" ]] && echo "  - Package Imports: ${violation_counts[package_imports]} violations"
    [[ "${check_results[class_naming]}" == "FAILED" ]] && echo "  - Class Naming: ${violation_counts[class_naming]} violations"
    [[ "${check_results[file_dir_naming]}" == "FAILED" ]] && echo "  - File/Directory Naming: ${violation_counts[file_dir_naming]} violations"
    [[ "${check_results[variable_naming]}" == "FAILED" ]] && echo "  - Variable Naming: ${violation_counts[variable_naming]} violations"
    [[ "${check_results[long_conditions]}" == "FAILED" ]] && echo "  - Very Long If Statement Conditions: ${violation_counts[long_conditions]} violations"
    echo "Please review the detailed output above and fix the violations before committing."
    exit 1
fi
