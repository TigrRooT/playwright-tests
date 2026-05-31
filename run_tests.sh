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

# 3. Generate AI tests before pytest
echo "Generating AI tests..."

if [ -z "$YANDEX_API_KEY" ]; then
    echo "Error: YANDEX_API_KEY is not set"
    exit 1
fi

if [ -z "$YANDEX_FOLDER_ID" ]; then
    echo "Error: YANDEX_FOLDER_ID is not set"
    exit 1
fi

if [ -z "$SITE_URL" ]; then
    echo "SITE_URL is not set, using default: http://10.0.2.2:8080"
    export SITE_URL="http://10.0.2.2:8080"
fi

# Удаляем старый AI-файл, чтобы не запускать устаревшие тесты
rm -f tests/test_ai_generated.py

# Запускаем генератор, он должен создать tests/test_ai_generated.py
python tools/yandex_generator.py
GENERATOR_EXIT_CODE=$?

if [ "$GENERATOR_EXIT_CODE" -ne 0 ]; then
    echo "Error: AI test generation failed"
    exit $GENERATOR_EXIT_CODE
fi

if [ ! -f "tests/test_ai_generated.py" ]; then
    echo "Error: tests/test_ai_generated.py was not created"
    exit 1
fi

echo "AI tests generated successfully"

# 4. Show collected tests
echo "Collected tests:"
python -m pytest tests/ --collect-only -q

# 5. Run tests
echo "Running tests..."
python -m pytest tests/ --alluredir=reports/allure-results
TEST_EXIT_CODE=$?

# 6. Generate report ALWAYS
echo "Generating report..."
allure generate reports/allure-results -o reports/allure-report --clean

# 7. Save history
if [ -d "reports/allure-report/history" ]; then
    rm -rf reports/allure-history/*
    cp -r reports/allure-report/history/* reports/allure-history/
fi

echo "Exit code: $TEST_EXIT_CODE"

# ВАЖНО: возвращаем реальный статус тестов
exit $TEST_EXIT_CODE