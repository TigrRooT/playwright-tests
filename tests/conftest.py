# tests/conftest.py
import pytest
import allure
from allure_commons.types import AttachmentType
import os

@pytest.hookimpl(hookwrapper=True)
def pytest_runtest_makereport(item, call):
    outcome = yield
    rep = outcome.get_result()
    
    if rep.when == "call" and rep.failed:
        page = item.funcargs.get("page", None)
        if page:
            try:
                # Сохраняем скриншот в файл
                os.makedirs("reports/allure-results", exist_ok=True)
                screenshot_path = f"reports/allure-results/{item.name}_screenshot.png"
                page.screenshot(path=screenshot_path, full_page=True)
                print(f"Screenshot saved: {screenshot_path}")
                
                # Прикрепляем к Allure
                with open(screenshot_path, "rb") as f:
                    allure.attach(
                        f.read(),
                        name="screenshot_on_failure",
                        attachment_type=AttachmentType.PNG
                    )
                print(f"Screenshot attached to Allure")
                
            except Exception as e:
                print(f"Error: {e}")