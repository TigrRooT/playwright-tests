import os
import allure

BASE_URL = os.getenv("SITE_URL", "http://10.0.2.2:8080")

@allure.feature("Главная страница")
@allure.story("Открытие страницы")
@allure.title("Проверка, что страница успешно открывается1")
def test_page_opens_successfully(page):
    with allure.step("Открыть страницу"):
        page.goto(BASE_URL)
        page.wait_for_load_state("networkidle")

    with allure.step("Проверить, что страница содержит контент"):
        title = page.title()
        assert title, "Заголовок страницы пустой"

        body_text = page.inner_text("body")
        assert body_text.strip(), "Страница не содержит текста"

    with allure.step("Проверить отсутствие ошибок в заголовке"):
        title_lower = title.lower()
        assert "404" not in title_lower, "Страница вернула ошибку 404"
        assert "error" not in title_lower, "Страница показывает ошибку"


@allure.feature("Главная страница")
@allure.story("Прокрутка страницы")
@allure.title("Проверка, что страницу можно прокручивать1")
def test_page_can_scroll(page):
    with allure.step("Открыть страницу"):
        page.goto(BASE_URL)
        page.wait_for_selector("body", timeout=5000)

    with allure.step("Проверить возможность прокрутки"):
        scroll_height = page.evaluate("document.body.scrollHeight")
        viewport_height = page.evaluate("window.innerHeight")

        if scroll_height <= viewport_height:
            print("Страница не имеет прокрутки")
            return

        initial_position = page.evaluate("window.pageYOffset")

        page.evaluate("window.scrollBy(0, 500)")
        page.wait_for_timeout(500)

        new_position = page.evaluate("window.pageYOffset")
        assert new_position > initial_position, "Страница не прокрутилась вниз"

    with allure.step("Прокрутить страницу до конца"):
        page.evaluate("window.scrollTo(0, document.body.scrollHeight)")
        page.wait_for_timeout(500)

        bottom_position = page.evaluate("window.pageYOffset")
        assert bottom_position >= scroll_height - viewport_height - 10, "Не удалось прокрутить до конца"

    with allure.step("Вернуться наверх"):
        page.evaluate("window.scrollTo(0, 0)")
        page.wait_for_timeout(500)

        top_position = page.evaluate("window.pageYOffset")
        assert top_position == 0, "Не удалось прокрутить страницу наверх"
    