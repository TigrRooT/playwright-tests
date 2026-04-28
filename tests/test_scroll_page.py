# tests/test_2_scroll_page.py
import pytest
import allure

BASE_URL = "http://google.com"

@allure.feature("Главная страница")
@allure.story("Прокрутка страницы")
@allure.title("Проверка, что страницу можно прокручивать")
def test_page_can_scroll(page):

    with allure.step("Открываем страницу и скролим"):
        page.goto(BASE_URL)
        page.wait_for_selector("body", timeout=5000)
    
        scroll_height = page.evaluate("document.body.scrollHeight")
        viewport_height = page.evaluate("window.innerHeight")
        if scroll_height <= viewport_height:
            print("Страница не имеет прокрутки")
        else:
            print(f"Страница имеет прокрутку: {scroll_height}px контент, {viewport_height}px окно")
    
        initial_position = page.evaluate("window.pageYOffset")
        page.evaluate("window.scrollBy(0, 500)")
        page.wait_for_timeout(500)
        new_position = page.evaluate("window.pageYOffset")
        assert new_position > initial_position, "Страница не прокрутилась вниз"

        page.evaluate("window.scrollTo(0, document.body.scrollHeight)")
        page.wait_for_timeout(500)
        bottom_position = page.evaluate("window.pageYOffset")
        assert bottom_position >= scroll_height - viewport_height - 10, "Не удалось прокрутить до конца"
    

        page.evaluate("window.scrollTo(0, 0)")
        page.wait_for_timeout(500)
        top_position = page.evaluate("window.pageYOffset")
        assert top_position == 0, "Не удалось прокрутить страницу наверх"
    
    print("Все проверки прокрутки пройдены успешно")