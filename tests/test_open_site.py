# tests/test_1_open_page.py
import pytest
import allure

BASE_URL = "http://host.docker.internal:8080"

@allure.feature("Главная страница")
@allure.story("Открытие страницы")
@allure.title("Проверка, что страница успешно открывается")
def test_page_opens_successfully(page):
    """
    Тест 1: Проверить, что страница успешно открывается
    """
    with allure.step("Открыть страницу"):
        # Используем domcontentloaded вместо networkidle для ускорения
        page.goto(BASE_URL, wait_until="domcontentloaded", timeout=30000)
        # Даем время на базовый рендеринг
        page.wait_for_timeout(1000)
    
    with allure.step("Проверить что страница содержит контент"):
        title = page.title()
        assert title, "Заголовок страницы пустой"
        print(f"Заголовок страницы: {title}")
        
        # Проверяем наличие body
        page.wait_for_selector("body", timeout=5000)
        body_text = page.inner_text("body")
        assert body_text.strip(), "Страница не содержит текста"
        print(f"Страница содержит текст (первые 50 символов): {body_text[:50]}...")
    
    with allure.step("Проверить отсутствие ошибок"):
        title_lower = title.lower()
        assert "404" not in title_lower, "Страница вернула ошибку 404"
        assert "error" not in title_lower, "Страница показывает ошибку"
    
    print("Страница успешно открылась и содержит контент")