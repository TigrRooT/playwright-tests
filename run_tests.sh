#!/bin/bash
# ===============================
# run_tests.sh
# ===============================

# Check Allure
if ! command -v allure &> /dev/null; then
    echo "Error: Allure is not installed or not in PATH"
    exit 1
fi

# 1 Clear results
rm -rf reports/allure-results
mkdir -p reports/allure-results
mkdir -p reports/allure-history

echo "Folders prepared"

# 2 Copy history
if [ -d "reports/allure-history" ] && [ "$(ls -A reports/allure-history 2>/dev/null)" ]; then
    mkdir -p reports/allure-results/history
    cp -r reports/allure-history/* reports/allure-results/history/ 2>/dev/null
    echo "History copied"
else
    echo "No history yet"
fi

# 3 Run tests (❗ FIX: убрали || true)
echo "Running tests..."
python -m pytest tests/ --alluredir=reports/allure-results
TEST_EXIT_CODE=$?

echo "Tests finished with code: $TEST_EXIT_CODE"

# 4 Generate report
echo "Generating report..."
allure generate reports/allure-results -o reports/allure-report --clean

# 5 Save history
if [ -d "reports/allure-report/history" ]; then
    rm -rf reports/allure-history/*
    cp -r reports/allure-report/history/* reports/allure-history/ 2>/dev/null
    echo "History saved"
fi

echo "Done"

# ❗ ВАЖНО: возвращаем код тестов
exit $TEST_EXIT_CODE
