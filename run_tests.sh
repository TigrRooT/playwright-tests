#!/bin/bash

# Check Allure
if ! command -v allure &> /dev/null; then
    echo "Error: Allure is not installed"
    exit 1
fi

# 1. Clear old results
rm -rf reports/allure-results
mkdir -p reports/allure-results
mkdir -p reports/allure-history

echo "Folders prepared"

# 2. Copy history
if [ -d "reports/allure-history" ] && [ "$(ls -A reports/allure-history 2>/dev/null)" ]; then
    mkdir -p reports/allure-results/history
    cp -r reports/allure-history/* reports/allure-results/history/
    echo "History copied"
else
    echo "No history yet"
fi

# 3. Run tests
echo "Running tests..."
python -m pytest tests/ --alluredir=reports/allure-results
TEST_EXIT_CODE=$?

# 4. Generate report (ВСЕГДА)
echo "Generating report..."
allure generate reports/allure-results -o reports/allure-report --clean

# 5. Save history
if [ -d "reports/allure-report/history" ]; then
    rm -rf reports/allure-history/*
    cp -r reports/allure-report/history/* reports/allure-history/
fi

echo "Exit code: $TEST_EXIT_CODE"

# ВАЖНО: возвращаем реальный статус
exit $TEST_EXIT_CODE
