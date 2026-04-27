#!/bin/bash
set -e

echo "==============================="
echo "Running tests with Allure"
echo "==============================="

# Check Allure
if ! command -v allure &> /dev/null; then
    echo "ERROR: Allure is not installed or not in PATH"
    exit 1
fi

# Prepare folders
rm -rf reports/allure-results
mkdir -p reports/allure-results
mkdir -p reports/allure-history

echo "Folders prepared"

# Restore history if exists
if ls reports/allure-history/*.json 1> /dev/null 2>&1; then
    mkdir -p reports/allure-results/history
    cp reports/allure-history/*.json reports/allure-results/history/ || true
    echo "History restored"
else
    echo "No history found (first run)"
fi

# Run tests
echo "Running pytest..."
python -m pytest tests/ --alluredir=reports/allure-results

echo "Tests finished"

# Validate results exist
if [ ! -d "reports/allure-results" ] || [ -z "$(ls -A reports/allure-results 2>/dev/null)" ]; then
    echo "ERROR: No allure-results generated!"
    exit 1
fi

# Generate report
echo "Generating Allure report..."
allure generate reports/allure-results -o reports/allure-report --clean

echo "Report generated"

# Save history for next run
if [ -d "reports/allure-report/history" ]; then
    rm -rf reports/allure-history/*
    cp reports/allure-report/history/*.json reports/allure-history/ || true
    echo "History saved"
fi

echo "DONE"
ls -R reports/allure-report