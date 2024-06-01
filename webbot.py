import re
import time
import json
from selenium import webdriver
import selenium.webdriver.chrome.service as service
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from bs4 import BeautifulSoup

def get_timepage(driver, creds):
    #Returns an html page with times
    WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.ID, "login_name"))).send_keys(creds["login"])
    WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.ID, "login_password"))).send_keys(creds["password"], Keys.ENTER)
    # waits till JS loads
    WebDriverWait(driver, 30).until(EC.presence_of_element_located((By.ID, "component-hdo-dnes")))
    page = driver.page_source
    soup = BeautifulSoup(page, "html.parser")
    return soup



def find_dates(soup):
    data_dates = soup.find_all(attrs={'class':'blue-text pull-left'})

    structured_dates = []
    for data_date in data_dates:
        structured_dates.append(re.search(r'.* (\d\d.\d\d)\.<\/div>', str(data_date)).group(1))
    return structured_dates


def find_intervals(soup):
    data =soup.find_all(attrs={'class':'span-overflow'})
    time_intervals = []
    for span in data:
        span = str(span)
        interval = re.search(r'.*title=\"(\d\d:\d\d - \d\d:\d\d)\"', span).group(1)
        time_intervals.append(interval)
    
    return time_intervals





def main():
    with open('credentials.json') as f:
        creds = json.load(f)
    
    service = webdriver.ChromeService(executable_path = './chromedriver')
    driver = webdriver.Chrome(service=service)
    driver.get('https://www.pre.cz/cs/moje-pre/neprihlaseny-uzivatel/prihlaseni-uzivatele/')
    time.sleep(3)

    timepage = get_timepage(driver, creds)
    dates = find_dates(timepage)

    intervals = find_intervals(timepage)

    final_response ={
        dates[0]: [intervals[1], intervals[3]],
        dates[1]: [intervals[6], intervals[7]]
    }
    driver.quit()
    return final_response

    


if __name__ == '__main__':
    try:
        main()
    except Exception as e:
        print("There was an error in retrieving data: {}".format(e))