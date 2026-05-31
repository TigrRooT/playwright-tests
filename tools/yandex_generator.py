import os
from pathlib import Path

import requests
from playwright.sync_api import sync_playwright


API_KEY = os.getenv("YANDEX_API_KEY")
FOLDER_ID = os.getenv("YANDEX_FOLDER_ID")
SITE_URL = os.getenv("SITE_URL", "http://10.0.2.2:8080")

YANDEX_URL = "https://llm.api.cloud.yandex.net/foundationModels/v1/completion"

OUTPUT_FILE = Path("tests/test_ai_generated.py")

# Ограничиваем HTML, чтобы YandexGPT не получил слишком большой prompt
MAX_HTML_CHARS = 30000


def require_env(name: str, value: str | None) -> str:
    if not value:
        raise RuntimeError(
            f"Environment variable {name} is not set. "
            f"Set it in GitHub Secrets, Docker Compose, or PowerShell."
        )

    return value


def disable_proxies() -> None:
    proxy_variables = [
        "HTTP_PROXY",
        "HTTPS_PROXY",
        "ALL_PROXY",
        "http_proxy",
        "https_proxy",
        "all_proxy",
    ]

    for variable in proxy_variables:
        os.environ.pop(variable, None)


def limit_html(html: str) -> str:
    if len(html) <= MAX_HTML_CHARS:
        return html

    return html[:MAX_HTML_CHARS] + "\n<!-- HTML was truncated for YandexGPT prompt -->"


def clean_generated_code(code: str) -> str:
    code = code.strip()

    if code.startswith("```python"):
        code = code.removeprefix("```python").strip()

    if code.startswith("```"):
        code = code.removeprefix("```").strip()

    if code.endswith("```"):
        code = code.removesuffix("```").strip()

    return code


def get_page_html(url: str) -> str:
    with sync_playwright() as playwright:
        browser = playwright.chromium.launch(headless=True)
        page = browser.new_page()

        try:
            page.goto(url, wait_until="networkidle", timeout=60000)
            html = page.content()
            return html
        finally:
            browser.close()


def generate_test(prompt: str) -> str:
    api_key = require_env("YANDEX_API_KEY", API_KEY)
    folder_id = require_env("YANDEX_FOLDER_ID", FOLDER_ID)

    disable_proxies()

    session = requests.Session()
    session.trust_env = False
    session.proxies = {}

    headers = {
        "Authorization": f"Api-Key {api_key}",
        "Content-Type": "application/json",
    }

    payload = {
        "modelUri": f"gpt://{folder_id}/yandexgpt/latest",
        "completionOptions": {
            "stream": False,
            "temperature": 0.2,
            "maxTokens": "3000",
        },
        "messages": [
            {
                "role": "system",
                "text": (
                    "Ты QA Automation инженер. "
                    "Пишешь автотесты на pytest + sync Playwright + Allure. "
                    "Каждый тест должен иметь allure.feature, allure.story, allure.title и allure.step. "
                    "Не используй Page Object Model. "
                    "Не используй классы. "
                    "Не используй helper-функции. "
                    "Не используй async Playwright. "
                    "Не добавляй объяснения. "
                    "Верни только чистый Python-код без markdown."
                ),
            },
            {
                "role": "user",
                "text": prompt,
            },
        ],
    }

    response = session.post(
        YANDEX_URL,
        headers=headers,
        json=payload,
        timeout=60,
    )

    if not response.ok:
        print("YandexGPT request failed")
        print(f"Status code: {response.status_code}")
        print("Response body:")
        print(response.text)
        response.raise_for_status()

    generated_code = response.json()["result"]["alternatives"][0]["message"]["text"]

    return clean_generated_code(generated_code)


def save_generated_tests(generated_test: str) -> None:
    OUTPUT_FILE.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT_FILE.write_text(generated_test + "\n", encoding="utf-8")


def main() -> None:
    print("Opening site and extracting HTML...")
    print(f"SITE_URL: {SITE_URL}")

    html = limit_html(get_page_html(SITE_URL))

    print(f"HTML collected. Length after limit: {len(html)} characters")
    print("Sending HTML to YandexGPT...")

    prompt = f"""
Ты QA Automation Engineer.

Вот URL сайта:
{SITE_URL}

Вот HTML страницы:
{html}

Сгенерируй pytest-playwright автотесты для этого сайта.

Требования к коду:
- использовать Python
- использовать pytest
- использовать sync Playwright
- использовать фикстуру page от pytest-playwright
- использовать Allure
- обязательно добавить import os
- обязательно добавить import allure
- обязательно добавить from playwright.sync_api import expect
- не использовать Page Object Model
- не использовать классы
- не использовать helper-функции
- не использовать async Playwright
- не писать async код
- не добавлять объяснения
- вернуть только Python-код
- не оборачивать код в markdown
- не оборачивать код в ```python
- не добавлять текстовые пояснения до или после кода

Требования к BASE_URL:
- в начале файла создай переменную:
  BASE_URL = os.getenv("SITE_URL", "{SITE_URL}")

Требования к Allure:
- каждый тест должен иметь декораторы:
  @allure.feature(...)
  @allure.story(...)
  @allure.title(...)
- внутри каждого теста используй:
  with allure.step(...):
- названия feature, story и title должны быть на русском языке
- Allure title должен быть понятным для отчёта
- тесты должны красиво отображаться в Allure-отчёте

Сгенерируй минимум эти тесты:

1. Тест открытия главной страницы:
- имя функции: test_page_opens_successfully_ai
- feature: "AI-тесты"
- story: "Открытие главной страницы"
- title: "AI: Проверка, что главная страница успешно открывается"
- шаги Allure:
  - "Открыть страницу"
  - "Проверить, что страница содержит контент"
  - "Проверить отсутствие ошибок в заголовке"
- тест должен открыть BASE_URL
- тест должен дождаться загрузки страницы
- проверить, что title страницы не пустой
- проверить, что body содержит текст
- проверить, что в title нет "404" и "error"

2. Тест прокрутки страницы:
- имя функции: test_page_can_scroll_ai
- feature: "AI-тесты"
- story: "Прокрутка страницы"
- title: "AI: Проверка, что страницу можно прокручивать"
- шаги Allure:
  - "Открыть страницу"
  - "Проверить возможность прокрутки"
  - "Прокрутить страницу до конца"
  - "Вернуться наверх"
- тест должен открыть BASE_URL
- тест должен дождаться появления body
- проверить высоту страницы
- если страница не имеет прокрутки, вывести:
  print("Страница не имеет прокрутки")
  и завершить тест без ошибки
- если прокрутка есть, проверить, что страница прокручивается вниз
- проверить, что можно прокрутить страницу до конца
- проверить, что можно вернуться наверх

Дополнительные проверки на основе HTML:
- если в HTML есть header, div-header, шапка сайта или похожий блок, добавь тест на наличие шапки
- если в HTML есть footer, div-footer, подвал сайта или похожий блок, добавь тест на наличие подвала
- если в HTML есть ссылки, кнопки или элементы навигации, добавь разумные проверки их видимости
- все дополнительные тесты тоже должны иметь allure.feature, allure.story, allure.title и allure.step
- все дополнительные тестовые функции должны начинаться с test_
- названия дополнительных функций должны заканчиваться на _ai

Важно:
- итоговый код должен быть готов для сохранения в файл tests/test_ai_generated.py
- код должен запускаться командой:
  python -m pytest tests/ --alluredir=reports/allure-results
- тесты должны отображаться в Allure с русскими названиями из allure.title
- не генерируй тесты с такими же именами функций, как уже существующие ручные тесты
- не используй имена:
  test_page_opens_successfully
  test_page_can_scroll

Верни только Python-код.
"""

    generated_test = generate_test(prompt)

    save_generated_tests(generated_test)

    print(f"Generated tests saved to {OUTPUT_FILE}")

    print("\n========== GENERATED TEST ==========\n")
    print(generated_test)
    print("\n====================================\n")


if __name__ == "__main__":
    main()