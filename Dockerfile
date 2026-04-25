# Используем Python 3.13.1
FROM python:3.13.1-slim

# Настройка DNS внутри контейнера
RUN echo "nameserver 8.8.8.8" > /etc/resolv.conf
RUN echo "nameserver 1.1.1.1" >> /etc/resolv.conf

# Установка системных зависимостей для Playwright и Allure
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    gnupg \
    openjdk-17-jre \
    libnss3 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    libgbm1 \
    libasound2 \
    libpangocairo-1.0-0 \
    libpango-1.0-0 \
    libcairo2 \
    fonts-liberation \
    libappindicator3-1 \
    libnspr4 \
    lsb-release \
    xdg-utils \
    && rm -rf /var/lib/apt/lists/*

# Установка Allure
RUN wget https://github.com/allure-framework/allure2/releases/download/2.29.0/allure-2.29.0.tgz \
    && tar -xzf allure-2.29.0.tgz \
    && mv allure-2.29.0 /opt/allure \
    && ln -s /opt/allure/bin/allure /usr/local/bin/allure \
    && rm allure-2.29.0.tgz

WORKDIR /app

# Копируем зависимости
COPY requirements.txt .

# Устанавливаем Python зависимости (включая pytest, allure-pytest, pytest-cov, playwright, pytest-playwright)
RUN pip install --no-cache-dir -r requirements.txt

# Установка браузеров Playwright
RUN playwright install chromium

# Копируем проект
COPY . .

# Делаем скрипт исполняемым
RUN chmod +x run_tests.sh

# Создаем директории для отчетов
RUN mkdir -p reports/allure-results reports/allure-history reports/allure-report

# Команда запуска тестов
CMD ["./run_tests.sh"]