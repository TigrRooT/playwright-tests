#!/bin/bash
set -e

echo "==============================="
echo "Running tests"
echo "==============================="

mkdir -p reports/allure-results
mkdir -p reports/allure-history

echo "Folders ready"

# history restore
if ls reports/allure-history/*.json 1> /dev/null 2>&1; then
    mkdir -p reports/allure-results/history
    cp reports/allure-history/*.json reports/allure-results/history/ || true
fi

echo "Running pytest..."
python -m pytest tests/ --alluredir=reports/allure-results

echo "Checking results..."
ls -R reports/allure-results || true

echo "Generating Allure report..."
allure generate reports/allure-results -o reports/allure-report --clean

echo "DONE"
ls -R reports/allure-report || true