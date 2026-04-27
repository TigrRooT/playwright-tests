#!/bin/bash
# ===============================
# run_tests.sh
# Script for running tests with Allure and displaying trends
# ===============================

# Проверяем права на запись
echo "Current user: $(whoami)"
echo "Reports directory permissions:"
ls -la /app/reports/ || echo "Reports dir not exists"

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
if ls reports/allure-history/*.json 1> /dev/null 2>&1; then
    mkdir -p "reports/allure-results/history"
    cp reports/allure-history/*.json "reports/allure-results/history/" 2>/dev/null
    echo "History copied. Comparison with previous run will be shown"
else
    echo "This is the first run. No history yet. Trends will appear after the second run"
fi

# 3 Run tests
echo "Running tests..."
python -m pytest tests/ --alluredir=reports/allure-results

# Сохраняем код возврата pytest
PYTEST_EXIT_CODE=$?

# 4 Generate Allure report
echo "Generating report..."
allure generate reports/allure-results -o reports/allure-report --clean

# Проверяем, создался ли отчет
if [ -d "reports/allure-report" ]; then
    echo "Report generated successfully"
    ls -la reports/allure-report/
else
    echo "ERROR: Report was not generated!"
    exit 1
fi

# 5 Save history from generated report for future runs
if [ -d "reports/allure-report/history" ]; then
    rm -rf reports/allure-history/*
    cp -r reports/allure-report/history/*.json "reports/allure-history/" 2>/dev/null
    count=$(find reports/allure-history -name "*.json" 2>/dev/null | wc -l)
    echo "Saved $count history files for the next run"
else
    echo "Warning: History folder not found"
fi

echo "Done! Test report generated"
echo "If this is the first run, run the script again to see trends"

# Возвращаем код ошибки pytest
exit $PYTEST_EXIT_CODE