#!/bin/bash
set -e

echo "Preparing folders..."

mkdir -p /app/reports/allure-results
mkdir -p /app/reports/allure-history
mkdir -p /app/reports/allure-report

chmod -R 777 /app/reports

echo "Running tests..."

python -m pytest tests/ --alluredir=/app/reports/allure-results

echo "Generating report..."

allure generate /app/reports/allure-results -o /app/reports/allure-report --clean

echo "DONE"
ls -R /app/reports/allure-report || true