import re
import time
import json
from datetime import date
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver import FirefoxOptions
# from selenium.webdriver import ChromeOptions
from bs4 import BeautifulSoup


def get_timepage(driver, creds):
    # Returns an html page with times
    WebDriverWait(driver, 10).until(EC.presence_of_element_located(
        (By.ID, "username"))).send_keys(creds["login"])
    WebDriverWait(driver, 10).until(EC.presence_of_element_located(
        (By.ID, "password"))).send_keys(creds["password"], Keys.ENTER)
    # waits till JS loads
    WebDriverWait(driver, 30).until(
        EC.presence_of_element_located((By.ID, "component-hdo-dnes")))
    page = driver.page_source
    soup = BeautifulSoup(page, "html.parser")
    return soup


def find_dates(soup):
    data_dates = soup.find_all(attrs={'class': 'blue-text pull-left'})

    structured_dates = []
    for data_date in data_dates:
        structured_dates.append(
            re.search(r'.* (\d\d.\d\d)\.<\/div>', str(data_date)).group(1))
    return structured_dates


def find_intervals(soup):
    data = soup.find_all(attrs={'class': 'span-overflow'})
    time_intervals = []
    for span in data:
        span = str(span)
        interval = re.search(
            r'.*title=\"(\d\d:\d\d - \d\d:\d\d)\"', span).group(1)
        time_intervals.append(interval)

    return time_intervals


def cache_file(final_response):
    with open('/app/data/times.json', 'w') as f:
        json.dump(final_response, f)


def read_file():
    # Return empty list if file is not found
    try:
        f = open('/app/data/times.json')
    except FileNotFoundError:
        return {}
    # Pass cached data if file was found
    final_response = json.load(f)
    return final_response


def get_creds():
    with open('/creds/login') as f:
        login = f.read()

    with open('/creds/password') as f:
        password = f.read()

    creds = {
        "login": login[:-1],
        "password": password[:-1]
    }
    return creds


def main():
    creds = get_creds()

    # Don't launch selenium if result is cached
    final_response = read_file()
    today = date.today().strftime("%d.%m")
    if today in final_response:
        return final_response
    else:

        options = FirefoxOptions()
        options.add_argument("--headless")  # Run Chrome in headless mode

        # service = webdriver.ChromeService(executable_path='./chromedriver')
        # driver = webdriver.Chrome(service=service, options=options)
        driver = webdriver.Remote(
            command_executor='http://selenium:4444/wd/hub', options=options)
        driver.get(
            'https://www.pre.cz/cs/moje-pre/neprihlaseny-uzivatel/prihlaseni-uzivatele/')
        time.sleep(3)

        timepage = get_timepage(driver, creds)
        dates = find_dates(timepage)

        intervals = find_intervals(timepage)

        final_response = {
            dates[0]: [intervals[1], intervals[3]],
            dates[1]: [intervals[6], intervals[7]]
        }
        driver.quit()
        cache_file(final_response)
        return final_response


if __name__ == '__main__':
    try:
        main()
    except Exception as e:
        print("There was an error in retrieving data: {}".format(e))
