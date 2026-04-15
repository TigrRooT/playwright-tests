# ===============================
# run_tests.ps1
# Script for running tests with Allure and displaying trends
# ===============================

# 1 Clear old test results
if (Test-Path "reports\allure-results") { 
    Remove-Item "reports\allure-results" -Recurse -Force 
}
New-Item "reports\allure-results" -ItemType Directory -Force

# Create history folder if it doesn't exist
if (-not (Test-Path "reports\allure-history")) { 
    New-Item "reports\allure-history" -ItemType Directory -Force 
}

Write-Host "Folders prepared"

# 2 Copy history from previous runs to results folder
# This is the most important step! Without it Allure won't see previous data
if (Test-Path "reports\allure-history\*.json") {
    # Create history folder inside results
    New-Item "reports\allure-results\history" -ItemType Directory -Force
    
    # Copy all history json files
    Copy-Item "reports\allure-history\*.json" "reports\allure-results\history\" -Force
    Write-Host "History copied. Comparison with previous run will be shown"
} else {
    Write-Host "This is the first run. No history yet. Trends will appear after the second run"
}

# 3 Run tests
Write-Host "Running tests..."
python -m pytest tests/ --alluredir=reports/allure-results

# 4 Generate Allure report
Write-Host "Generating report..."
allure generate reports/allure-results -o reports/allure-report --clean

# 5 Save history from generated report for future runs
if (Test-Path "reports\allure-report\history") {
    # Clear old history
    Remove-Item "reports\allure-history\*" -Force -Recurse -ErrorAction SilentlyContinue
    
    # Save new history
    Copy-Item "reports\allure-report\history\*.json" "reports\allure-history\" -Force
    
    $count = (Get-ChildItem "reports\allure-history" -Filter "*.json").Count
    Write-Host "Saved $count history files for the next run"
} else {
    Write-Host "Warning: History folder not found"
}

# 6 Open report in browser
Write-Host "Opening report..."
allure open reports/allure-report

Write-Host "Done! Report opened in browser"
Write-Host "If this is the first run, run the script again to see trends"