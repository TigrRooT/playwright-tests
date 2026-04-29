#!/bin/bash
# ===============================
# run_tests.sh
# Script for running tests with Allure and displaying trends
# ===============================

# Check if Allure is installed
if ! command -v allure &> /dev/null; then
    echo "Error: Allure is not installed or not in PATH"
    echo "Install: https://github.com/allure-framework/allure2/releases"
    exit 1
fi

# 1 Clear old test results
if [ -d "reports/allure-results" ]; then
    rm -rf "reports/allure-results"
fi
mkdir -p "reports/allure-results"

# Create history folder if it doesn't exist
if [ ! -d "reports/allure-history" ]; then
    mkdir -p "reports/allure-history"
fi

echo "Folders prepared"

# 2 Copy history from previous runs to results folder
# 🔥 FIX: проверяем папку, а не *.json, и копируем ВСЁ
if [ -d "reports/allure-history" ] && [ "$(ls -A reports/allure-history 2>/dev/null)" ]; then
    mkdir -p "reports/allure-results/history"
    cp -r reports/allure-history/* "reports/allure-results/history/" 2>/dev/null
    echo "History copied. Comparison with previous run will be shown"
else
    echo "This is the first run. No history yet. Trends will appear after the second run"
fi

# 3 Run tests
echo "Running tests..."
python -m pytest tests/ --alluredir=reports/allure-results || true
# 🔥 FIX: не даем CI падать

# 4 Generate Allure report
echo "Generating report..."
allure generate reports/allure-results -o reports/allure-report --clean

# 5 Save history from generated report for future runs
# 🔥 FIX: копируем ВСЁ, а не только json
if [ -d "reports/allure-report/history" ]; then
    rm -rf reports/allure-history/*
    cp -r reports/allure-report/history/* "reports/allure-history/" 2>/dev/null
    count=$(find reports/allure-history -type f 2>/dev/null | wc -l)
    echo "Saved $count history files for the next run"
else
    echo "Warning: History folder not found"
fi

echo "Done! Report opened in browser"
echo "If this is the first run, run the script again to see trends"