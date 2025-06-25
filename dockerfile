# Base Airflow image
FROM dockerreg.shonizcloud.ir/apache/airflow:2.1.1

COPY sources.list /etc/apt/sources.list
# Switch to root to install system packages
USER root

# Install system dependencies, Xvfb, and fonts
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        freetds-dev \
        freetds-bin \
        libssl-dev \
        unixodbc-dev \
        wget \
        gnupg \
        unzip \
        xvfb \
        libxi6 \
        libgconf-2-4 \
        libnss3 \
        libxss1 \
        jq \
        build-essential \
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


    # Install compatible ChromeDriver
RUN set -ex && \
    FULL_VERSION=$(google-chrome --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+') && \
    MAJOR_VERSION=$(echo "$FULL_VERSION" | cut -d. -f1) && \
    MATCHING_VERSION=$(curl -s https://googlechromelabs.github.io/chrome-for-testing/known-good-versions-with-downloads.json \
      | jq -r --arg MAJOR "$MAJOR_VERSION." \
         '.versions | map(select(.version | startswith($MAJOR))) | last.version') && \
    echo "Resolved ChromeDriver version: $MATCHING_VERSION" && \
    wget -q "https://storage.googleapis.com/chrome-for-testing-public/${MATCHING_VERSION}/linux64/chromedriver-linux64.zip" -O chromedriver.zip && \
    unzip chromedriver.zip -d /usr/local/bin && \
    mv /usr/local/bin/chromedriver-linux64/chromedriver /usr/local/bin/chromedriver && \
    chmod +x /usr/local/bin/chromedriver && \
    rm -rf chromedriver.zip /usr/local/bin/chromedriver-linux64


# Install required Python packages
RUN pip install --no-cache-dir \
    selenium \
    beautifulsoup4 \
    pandas \
    pendulum \
    lxml \
    webdriver-manager

# Install pymssql (requires freetds-dev to be present)
RUN pip install --no-cache-dir pymssql

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