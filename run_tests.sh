#!/bin/bash
# ===============================
# run_tests.sh
# Script for running tests with Allure and displaying trends
# ===============================

# Определяем корневую директорию
ROOT_DIR="/app"
REPORTS_DIR="${ROOT_DIR}/reports"

# Создаем директории с правильными правами
mkdir -p "${REPORTS_DIR}/allure-results"
mkdir -p "${REPORTS_DIR}/allure-history"

echo "Folders prepared"

# 1 Clear old test results (но не удаляем саму директорию)
if [ -d "${REPORTS_DIR}/allure-results" ]; then
    rm -rf "${REPORTS_DIR}/allure-results"/*
fi

# 2 Copy history from previous runs to results folder
if ls ${REPORTS_DIR}/allure-history/*.json 1> /dev/null 2>&1; then
    mkdir -p "${REPORTS_DIR}/allure-results/history"
    cp ${REPORTS_DIR}/allure-history/*.json "${REPORTS_DIR}/allure-results/history/" 2>/dev/null
    echo "History copied. Comparison with previous run will be shown"
else
    echo "This is the first run. No history yet. Trends will appear after the second run"
fi

# 3 Run tests
echo "Running tests..."
python -m pytest tests/ --alluredir=${REPORTS_DIR}/allure-results

# Сохраняем код возврата pytest
PYTEST_EXIT_CODE=$?

# 4 Generate Allure report (только если есть результаты)
if [ -d "${REPORTS_DIR}/allure-results" ] && [ -n "$(ls -A ${REPORTS_DIR}/allure-results 2>/dev/null)" ]; then
    echo "Generating report..."
    allure generate ${REPORTS_DIR}/allure-results -o ${REPORTS_DIR}/allure-report --clean
    
    # 5 Save history from generated report for future runs
    if [ -d "${REPORTS_DIR}/allure-report/history" ]; then
        rm -rf ${REPORTS_DIR}/allure-history/*
        cp ${REPORTS_DIR}/allure-report/history/*.json "${REPORTS_DIR}/allure-history/" 2>/dev/null
        count=$(find ${REPORTS_DIR}/allure-history -name "*.json" 2>/dev/null | wc -l)
        echo "Saved $count history files for the next run"
    else
        echo "Warning: History folder not found"
    fi
    
    echo "Done! Report generated in ${REPORTS_DIR}/allure-report"
    echo "If this is the first run, run the script again to see trends"
else
    echo "Warning: No test results found in ${REPORTS_DIR}/allure-results"
fi

# Выходим с кодом возврата pytest
exit $PYTEST_EXIT_CODE