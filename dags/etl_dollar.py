import pandas as pd
import pendulum
import time
from datetime import datetime, timedelta

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from bs4 import BeautifulSoup

from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.microsoft.mssql.hooks.mssql import MsSqlHook

local_Iran = pendulum.timezone("Asia/Tehran")

default_args = {
    'owner': 'airflow',
    'start_date': datetime(2025, 5, 1, tzinfo=local_Iran),
    'retries': 3,
    'retry_delay': timedelta(minutes=5),
    'email_on_failure': False,
    'email_on_retry': False
}


def scrape_and_load(**context):
    # Start Chrome driver
    driver = webdriver.Chrome()
    driver.get('https://www.tgju.org/profile/price_dollar_rl')
    wait = WebDriverWait(driver, 10)

    # Click "view full history"
    view_full_history = wait.until(EC.element_to_be_clickable((By.LINK_TEXT, 'مشاهده لیست کامل تاریخچه')))
    view_full_history.click()

    # Try closing popup if exists
    try:
        popup = wait.until(EC.presence_of_element_located((By.ID, 'popup-layer-container')))
        close_button = popup.find_element(By.CLASS_NAME, 'close-button')
        time.sleep(2)
        close_button.click()
    except:
        pass

    # Scrape all pages
    data = []
    while True:
        wait.until(EC.presence_of_element_located((By.ID, "DataTables_Table_0")))
        time.sleep(1)

        html = driver.page_source
        soup = BeautifulSoup(html, 'html.parser')
        table = soup.find('table', id='DataTables_Table_0')

        if table:
            for row in table.find_all('tr'):
                cols = row.find_all('td')
                if cols:
                    data.append([col.get_text(strip=True) for col in cols])

        try:
            next_button = driver.find_element(By.ID, 'DataTables_Table_0_next')
            if 'disabled' in next_button.get_attribute('class'):
                break
            next_button.click()
            time.sleep(2)
        except Exception as e:
            print("Pagination ended or failed:", e)
            break

    driver.quit()

    # Create DataFrame
    columns = ['open_price', 'min_price', 'max_price', 'end', 'Change', 'Percent Change', 'Miladi', 'Date']
    df = pd.DataFrame(data, columns=columns)

    # Insert into SQL Server
    hook = MsSqlHook(mssql_conn_id='BulutWarehouse')
    target_table = 'sale.dollar_price'

    records = df.to_records(index=False)
    rows = list(records)

    hook.insert_rows(table=target_table, rows=rows, replace=False)
    print(f"Inserted {len(rows)} rows into {target_table}")


with DAG(
    dag_id='scrape_and_insert_tgju_dollar_price',
    default_args=default_args,
    schedule_interval='@daily',
    catchup=False,
) as dag:

    scrape_task = PythonOperator(
        task_id='scrape_and_load_to_sqlserver',
        python_callable=scrape_and_load,
        provide_context=True,
    )

    scrape_task
