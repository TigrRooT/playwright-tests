#!/bin/bash

echo "Folders prepared"

mkdir -p reports/allure-results
mkdir -p reports/allure-history
mkdir -p reports/allure-report

echo "Running tests..."

python -m pytest tests/ --alluredir=reports/allure-results

echo "Generating report..."

allure generate reports/allure-results -o reports/allure-report --clean

echo "Saving history..."

if [ -d "reports/allure-report/history" ]; then
    rm -rf reports/allure-history/*
    cp -r reports/allure-report/history/* reports/allure-history/ 2>/dev/null || true
fi

echo "Done!"