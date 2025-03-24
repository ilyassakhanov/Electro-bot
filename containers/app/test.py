from selenium import webdriver
from selenium.common.exceptions import WebDriverException
from flask import Flask, jsonify
import time

app = Flask(__name__)

@app.route('/', methods=['GET'])
def home():
    try:
        # Set up Selenium WebDriver
        options = webdriver.FirefoxOptions()
        options.add_argument("--headless")  # Run in headless mode (no GUI)

        # Retry connecting to Selenium if it isn't ready
        for attempt in range(5):  # Retry 5 times
            try:
                driver = webdriver.Remote(
                    command_executor='http://browser:4444/wd/hub',
                    options=options
                )
                break
            except WebDriverException as e:
                print(f"Attempt {attempt + 1}: Waiting for Selenium to be ready...")
                time.sleep(5)
        else:
            return jsonify({"status": "Selenium not available"}), 500

        # Visit the website and get the title
        driver.get('https://www.pre.cz/cs/moje-pre/neprihlaseny-uzivatel/prihlaseni-uzivatele/')
        title = driver.title
        driver.quit()

        # Return the page title
        return jsonify({"status": title})

    except Exception as e:
        print(f"Error: {e}")
        return jsonify({"status": "Failed", "error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
