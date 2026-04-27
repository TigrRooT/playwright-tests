#!/bin/bash
set -e

echo "==============================="
echo "Running tests with Allure"
echo "==============================="

BASE_DIR=/app/reports

echo "Preparing folders..."
mkdir -p $BASE_DIR/allure-results
mkdir -p $BASE_DIR/allure-history
mkdir -p $BASE_DIR/allure-report

chmod -R 777 $BASE_DIR || true

echo "Running tests..."
python -m pytest tests/ --alluredir=$BASE_DIR/allure-results

echo "Checking results..."
if [ -z "$(ls -A $BASE_DIR/allure-results 2>/dev/null)" ]; then
    echo "ERROR: No test results generated"
    exit 1
fi

echo "Generating report..."
allure generate $BASE_DIR/allure-results -o $BASE_DIR/allure-report --clean

echo "Saving history..."
if [ -d "$BASE_DIR/allure-report/history" ]; then
    rm -rf $BASE_DIR/allure-history/*
    cp $BASE_DIR/allure-report/history/*.json $BASE_DIR/allure-history/ || true
fi

echo "DONE"
ls -R $BASE_DIR/allure-report || true