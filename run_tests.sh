#!/bin/bash
set -e

echo "Running tests..."

mkdir -p /app/reports/allure-results
mkdir -p /app/reports/allure-report

python -m pytest tests/ --alluredir=/app/reports/allure-results

echo "Generating report..."

allure generate /app/reports/allure-results -o /app/reports/allure-report --clean

echo "DONE"