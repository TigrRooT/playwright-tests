# tests/test_1_open_page.py
import pytest
import allure

import os

BASE_URL = os.getenv("BASE_URL", "http://app:8080")

@allure.feature("Главная страница")
@allure.story("Открытие страницы")
@allure.title("Проверка, что страница успешно открывается")
def test_page_opens_successfully(page):
    """
    Тест 1: Проверить, что страница успешно открывается
    """
    with allure.step("Открыть страницу"):
        page.goto(BASE_URL)
        page.wait_for_load_state("networkidle")
    
    with allure.step("Проверить что страница содержит контент"):
        title = page.title()
        assert title, "Заголовок страницы пустой"
        print(f"Заголовок страницы: {title}")
        
        body_text = page.inner_text("body")
        assert body_text.strip(), "Страница не содержит текста"
        print(f"Страница содержит текст (первые 50 символов): {body_text[:50]}...")
    
    with allure.step("Проверить отсутствие ошибок"):
        title_lower = title.lower()
        assert "404" not in title_lower, "Страница вернула ошибку 404"
        assert "error" not in title_lower, "Страница показывает ошибку"
    
    print("Страница успешно открылась и содержит контент")