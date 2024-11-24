from selenium import webdriver
from flask import Flask, jsonify

options = webdriver.FirefoxOptions()
options.add_argument("--headless")  # Run in headless mode (no GUI)
driver = webdriver.Remote(
    command_executor='http://selenium-service:4444/wd/hub',
    options=options
)

driver.get('https://www.pre.cz/cs/moje-pre/neprihlaseny-uzivatel/prihlaseni-uzivatele/')
title = (driver.title)
driver.quit()


app = Flask(__name__)


@app.route('/', methods=['GET'])
def home():
    return jsonify({
        "status": title
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
