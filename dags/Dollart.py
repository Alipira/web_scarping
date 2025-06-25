import time
import pandas as pd

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from bs4 import BeautifulSoup


# Setup driver
driver = webdriver.Chrome()
driver.get('https://www.tgju.org/profile/price_dollar_rl')
wait = WebDriverWait(driver, 10)


view_full_history = wait.until(EC.element_to_be_clickable((By.LINK_TEXT, 'مشاهده لیست کامل تاریخچه')))
view_full_history.click()

# Handle potential popup
try:
    popup = wait.until(EC.presence_of_element_located((By.ID, 'popup-layer-container')))
    close_button = popup.find_element(By.CLASS_NAME, 'close-button')
    time.sleep(2)
    close_button.click()
except:
    pass

# Collect all data from all pages
data = []
while True:
    wait.until(EC.presence_of_element_located((By.ID, "DataTables_Table_0")))
    time.sleep(1)

    # Parse current page
    html = driver.page_source
    soup = BeautifulSoup(html, 'html.parser')
    table = soup.find('table', id='DataTables_Table_0')

    if table:
        for row in table.find_all('tr'):
            cols = row.find_all('td')
            if cols:
                data.append([col.get_text(strip=True) for col in cols])

    # Find the "Next" button
    try:
        next_button = driver.find_element(By.ID, 'DataTables_Table_0_next')
        if 'disabled' in next_button.get_attribute('class'):
            break  # No more pages
        next_button.click()
        time.sleep(2)  # Wait for new page data
    except Exception as e:
        print("Pagination ended or failed:", e)
        break

# Cleanup
driver.quit()

# Build DataFrame
table_columns = ['open_price', 'min_price', 'max_price', 'end', 'Change', 'Percent Change', 'Miladi', 'Date']
df = pd.DataFrame(data, columns=table_columns)
