FROM python:3.13.1-slim

RUN apt-get update && apt-get install -y \
    wget curl gnupg openjdk-17-jre \
    libnss3 libatk1.0-0 libatk-bridge2.0-0 libcups2 \
    libdrm2 libxkbcommon0 libxcomposite1 libxdamage1 \
    libxrandr2 libgbm1 libasound2 libpangocairo-1.0-0 \
    libpango-1.0-0 libcairo2 fonts-liberation \
    libnspr4 lsb-release xdg-utils \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/allure-framework/allure2/releases/download/2.29.0/allure-2.29.0.tgz \
    && tar -xzf allure-2.29.0.tgz \
    && mv allure-2.29.0 /opt/allure \
    && ln -s /opt/allure/bin/allure /usr/local/bin/allure \
    && rm allure-2.29.0.tgz

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

RUN playwright install chromium

COPY . .

RUN chmod +x run_tests.sh

RUN mkdir -p reports/allure-results reports/allure-history reports/allure-report

CMD ["./run_tests.sh"]