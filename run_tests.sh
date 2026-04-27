#!/bin/bash

# чтобы скрипт не падал сразу
set +e

# ===============================
# run_tests.sh
# ===============================

if ! command -v allure &> /dev/null; then
    echo "Error: Allure is not installed or not in PATH"
    exit 1
fi

# 1 Clear old test results
rm -rf "reports/allure-results"
mkdir -p "reports/allure-results"
mkdir -p "reports/allure-history"

echo "Folders prepared"

# 2 Copy history
if ls reports/allure-history/*.json 1> /dev/null 2>&1; then
    mkdir -p "reports/allure-results/history"
    cp reports/allure-history/*.json "reports/allure-results/history/" 2>/dev/null
    echo "History copied"
else
    echo "First run, no history"
fi

# 3 Run tests
echo "Running tests..."
python -m pytest tests/ --alluredir=reports/allure-results
TEST_EXIT_CODE=$?

# 4 Generate report (даже если тесты упали)
echo "Generating report..."
allure generate reports/allure-results -o reports/allure-report --clean

# 5 Save history
if [ -d "reports/allure-report/history" ]; then
    rm -rf reports/allure-history/*
    cp reports/allure-report/history/*.json "reports/allure-history/" 2>/dev/null
fi

echo "Done!"

# вернуть код pytest (чтобы CI видел фейл)
exit $TEST_EXIT_CODE