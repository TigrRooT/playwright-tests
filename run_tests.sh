#!/bin/bash
# ===============================
# run_tests.sh
# ===============================

set +e

# Check Allure
if ! command -v allure &> /dev/null; then
    echo "Error: Allure is not installed or not in PATH"
    exit 1
fi

# Prepare folders
rm -rf reports/allure-results
mkdir -p reports/allure-results
mkdir -p reports/allure-history
mkdir -p reports/allure-report

echo "Folders prepared"

# Copy history
if [ -d "reports/allure-history" ] && [ "$(ls -A reports/allure-history 2>/dev/null)" ]; then
    mkdir -p reports/allure-results/history
    cp -r reports/allure-history/* reports/allure-results/history/ 2>/dev/null
    echo "History copied"
fi

# Run tests (НЕ ломаем выполнение)
echo "Running tests..."
python -m pytest tests/ --alluredir=reports/allure-results
TEST_EXIT_CODE=$?

echo $TEST_EXIT_CODE > reports/exit_code.txt
echo "Test exit code: $TEST_EXIT_CODE"

# Generate report (ВСЕГДА пробуем)
echo "Generating report..."
allure generate reports/allure-results -o reports/allure-report --clean || true

# Save history
if [ -d "reports/allure-report/history" ]; then
    rm -rf reports/allure-history/*
    cp -r reports/allure-report/history/* reports/allure-history/ 2>/dev/null
fi

echo "Done"

exit 0