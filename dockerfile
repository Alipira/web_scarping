# Base Airflow image
FROM dockerreg.shonizcloud.ir/apache/airflow:2.1.1

# Switch to root to install system packages
USER root

# Install system dependencies, Xvfb, and fonts
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        wget \
        gnupg \
        unzip \
        xvfb \
        libxi6 \
        libgconf \
        libnss3 \
        libxss1 \
        libasound2 \
        fonts-noto-cjk \
        fonts-noto-cjk-extra \
        fonts-ipafont-gothic \
        fonts-wqy-zenhei \
        fonts-thai-tlwg \
        fonts-kacst \
        fonts-freefont-ttf && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Google Chrome Stable
RUN curl -fsSL https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/googlechromekey.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/googlechromekey.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && \
    apt-get install -y google-chrome-stable --allow-unauthenticated && \
    rm -rf /var/lib/apt/lists/*

# Install matching ChromeDriver dynamically
RUN CHROME_VERSION=$(google-chrome --version | grep -oP '\d+\.\d+\.\d+') && \
    CHROMEDRIVER_VERSION=$(curl -sS "https://chromedriver.storage.googleapis.com/LATEST_RELEASE_${CHROME_VERSION%.*}") && \
    curl -fsSLO "https://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_linux64.zip" && \
    unzip chromedriver_linux64.zip && \
    mv chromedriver /usr/local/bin/ && \
    chmod +x /usr/local/bin/chromedriver && \
    rm chromedriver_linux64.zip

# Install required Python packages
RUN pip install --no-cache-dir \
    selenium==4.15.2 \
    beautifulsoup4==4.12.2 \
    pandas==2.1.3 \
    pendulum==2.1.2 \
    lxml==4.9.3 \
    webdriver-manager==4.0.1

# Set environment variables
ENV CHROME_BIN=/usr/bin/google-chrome
ENV CHROME_DRIVER_PATH=/usr/local/bin/chromedriver
ENV DISPLAY=:99
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV DBUS_SESSION_BUS_ADDRESS=/dev/null

# Add entrypoint wrapper to start Xvfb before launching Airflow
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Use the default Airflow entrypoint, wrapped with Xvfb
ENTRYPOINT ["/entrypoint.sh"]
CMD ["webserver"]

# Revert to Airflow user
USER ${AIRFLOW_UID}