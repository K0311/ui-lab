# ui-lab

ITCS386 Software Verification and Validation, Lab: Automated UI Testing.

Tool parts that I chose: **Part 2, Selenium WebDriver in Java** and **Part 3, Robot Framework**.
Both parts automate test case QP-01 (A custom pizza reaches the admin list) on
https://quickpizza.grafana.com and test the Selenium web form at
https://www.selenium.dev/selenium/web/web-form.html.

Both parts read the path of ChromeDriver from the environment variable `CHROMEDRIVER`
(Step 0.3), so set it first, for example
`export CHROMEDRIVER="$HOME/drivers/chromedriver-mac-arm64/chromedriver"`.

## selenium-java (Part 2)

A Maven project with JUnit 6 and Selenium 4.52.0. `src/test/java/uilab` holds the first test, the
web form test, the wait test, QP-01 written step by step (`QP01Test`) and QP-01 written with the page
objects in `pages/` (`QP01PageObjectTest`). `screenshots/` holds the pictures of steps 3, 4, 5 and 7 of
each run, and `reports/` holds the Surefire report of QP01PageObjectTest from the second full run.

```
cd selenium-java
mvn test -Dheadless=true
```

## robot (Part 3)

Robot Framework 7.5.1 with SeleniumLibrary 6.9.0. `first.robot` and `web_form.robot` test the web
form, `pizza_scenario.robot` is QP-01, and `resources/quickpizza.resource` keeps the locators and
keywords of the QuickPizza pages. `results/run1` and `results/run2` hold the log, the report and the
four screenshots of two full runs.

```
cd robot
python3 -m venv .venv && source .venv/bin/activate && pip install -r requirements.txt
robot -d results/run1 -v BROWSER:headlesschrome pizza_scenario.robot
```

## Evidence in one go

`run-evidence.sh` (macOS or Linux, bash) runs both full Maven runs and both Robot runs, copies the
Surefire report into `selenium-java/reports`, and prints the times, test counts and pizza names
to copy into RESULTS.md.

```
./run-evidence.sh                                          # macOS or Linux
powershell -ExecutionPolicy Bypass -File .\run-evidence.ps1  # Windows
```
