# UI lab results

Tool parts that I chose: Part 2, Selenium WebDriver in Java, and Part 3, Robot Framework

## Part 0
- Step 0.1, Chrome version: Google Chrome 158.0.8127.37 (Official Build) (64-bit), Windows 10 x64
- Step 0.3, ChromeDriver version: ChromeDriver 158.0.8127.36 (14d6f648e8cd7ad750a4044200ce94d3321be260-refs/branch-heads/8127@{#1691}). Chrome for Testing had no build for 158.0.8127.37, and ChromeDriver only needs the same major version, 158
- Step 0.4, locator of Pizza, Please!: `name=pizza-please`, as CSS `button[name="pizza-please"]`, 1 match
- Step 0.4, locator of Excluded tools: `select`, the only select element on the page, as XPath `//select[option[normalize-space()='Knife']]`, 1 match
- Step 0.4, locator of Must be vegetarian: `#default-checkbox`, 1 match
- Step 0.4, locator of Custom Pizza Name: `input#pizza-name`, 1 match. `#pizza-name` alone finds 2 elements after Pizza, Please!, because the heading of the answer has the same id
- Step 0.5, pizza name, tool and calories of the run by hand: Lab Pizza 20261122-163810, tool Scissors, 475 calories per slice 

| Step | Actual result | Pass or fail |
|------|---------------|--------------|
| 1    | The heading reads Looking to break out of your pizza routine? The page shows Login, so the browser is not logged in | Pass |
| 2    | Max Calories per Slice (showing 1000), Excluded tools (Knife, Pizza cutter, Scissors), Must be vegetarian and Custom Pizza Name appear | Pass |
| 3    | The fields show 600, Knife, vegetarian ticked and Lab Pizza 20261122-163810 | Pass |
| 4    | The answer shows Name: Lab Pizza 20261122-163810, Dough: Stuffed, seven vegetarian ingredients, Tool: Scissors, Calories per slice: 475 | Pass |
| 5    | Love it! shows Please log in first. | Pass |
| 6    | After Sign in with admin and admin, the page shows Latest pizza recommendations | Pass |
| 7    | The list holds 15 lines, all named Stress Pizza (another user was creating pizzas quickly), and none of them is Lab Pizza 20261122-163810. The admin list shows only the 15 newest pizzas, so ours had already dropped out | Fail |

Step 7 failed because of the shared site, not because the pizza was lost: the admin page loads the 15 newest recommendations once after sign-in. The same thing made the automated Robot run 1 fail at step 7 at 16:22. It shows that step 7 of QP-01 depends on how busy QuickPizza is.

## Part 2: Selenium WebDriver in Java
- Step 2.4, the failure line for the wrong title: `[ERROR]   FirstTest.webFormOpens:20 expected: <Web Form> but was: <Web form>` (BUILD FAILURE). After I changed the title back, the test passed again
- Step 2.15, QP01Test run 1, result and time: PASS, 7.448 s (`Tests run: 1, Failures: 0, Errors: 0` in uilab.QP01Test, 22 Nov 2026 16:29)
- Step 2.15, QP01Test run 2, result and time: PASS, 7.975 s (22 Nov 2026 16:33)
- Step 2.20, full run 1, time and number of tests: 46.6 s, Tests run: 5, Failures: 0, Errors: 0, BUILD SUCCESS
- Step 2.20, full run 2, time and number of tests: 26.0 s (Maven total time 24.121 s), Tests run: 5, Failures: 0, Errors: 0, BUILD SUCCESS. `reports/uilab.QP01PageObjectTest.txt` is the report of this run
- Note: an earlier second run at 16:29 failed after 32.7 s with `Tests run: 5, Failures: 0, Errors: 1`. QP01PageObjectTest stopped in `HomePage.askForPizza` with `TimeoutException ... Unable to locate element: #recommendations`, because QuickPizza showed no answer after Pizza, Please! within 10 seconds. The same code passed before and after, so the shared site did not answer that request. The folder of that run in `screenshots/` holds only `step-3.png`. I ran the full run again, and the run above passed

## Part 3: Robot Framework
- robot --version: Robot Framework 7.5.1 (Python 3.10.10 on win32)
- Step 3.2, failure message for the wrong title: `Title should have been 'Web Form' but was 'Web form'.` After I changed the title back, the test passed again
- Step 3.8, run 1, result, elapsed time and pizza name: PASS, 9.72 s, Lab Pizza 20261122-163425
- Note: two earlier attempts at run 1 failed, and I kept their details here. At 16:22, Lab Pizza 20261122-162244 failed at step 7 after 19.7 s with `Text 'Lab Pizza 20261122-162244' did not appear in 10 seconds.` At 16:30, Lab Pizza 20261122-163017 failed at step 4 after 16.9 s with `Element with locator 'id:recommendations' not found.` The same suite passed right before and after (for example Lab Pizza 20261122-162306, PASS, 10.5 s). `results/run1/selenium-screenshot-1.png` and `selenium-screenshot-2.png` are the pictures that SeleniumLibrary took when those two attempts failed. The second one shows the filled-in form of Lab Pizza 20261122-163017 with no answer below Pizza, Please!. The log, report and four qp01 pictures in `results/run1` come from the run that passed
- Step 3.8, run 2, result, elapsed time and pizza name: PASS, 9.67 s, Lab Pizza 20261122-163036

## Part B
1. The calories box has the id `floating_filled`, but `$$("#floating_filled").length` returns 3 in the Console, because Max Calories per Slice, Min Number of Toppings and Max Number of Toppings all use that id. `By.id("floating_filled")` would always return the first of them, so a test could not tell the boxes apart and could type into the wrong one without failing. The tests therefore start from the unique label text Max Calories per Slice and step to the input next to it. I propose that each box gets its own id, such as `id="max-calories-per-slice"` together with `<label for="max-calories-per-slice">`. The locator would then be short, unique and independent of the label wording and the layout, so a change of the text or of the order of the boxes would no longer break the test, and the label would also be correctly linked to its box for screen readers.

2. Step 7 is a consistency oracle. It does not know the correct tool in advance, because QuickPizza picks the pizza at random, so it compares two outputs of the same system with each other, the tool in the recommendation on the home page and the tool in the admin list. It would catch a fault where the server saves a different record than it returns, for example if the admin list read the tool of another pizza, saved the tool before the restrictions were applied, or mixed up the rows of two users who asked for a pizza at the same moment. Each of these faults makes the line of our pizza show `(tool=...)` with a tool other than the one in step 4, and the assertion fails.

3. The answer lists the ingredients of the pizza under Ingredients:, so a check could read every item of that list and assert that none of them is in a list of non-vegetarian ingredients, such as Pepperoni, Bacon or Anchovies. The test then needs that reference list from a source other than the page, for example the ingredient data of the QuickPizza API, where every ingredient has a `vegetarian` field, or a fixed list written into the test case. An easier but weaker check uses the JSON answer of `POST /api/pizza`, which has a field `vegetarian` with the value `true` or `false`. The UI does not show this flag, so the test would read it from the network or from the API rather than from the page.

4. Both tools waited for the elements, never with a fixed pause. Selenium Java used `WebDriverWait` with `ExpectedConditions` for up to 10 seconds, such as `visibilityOfElementLocated(By.tagName("h1"))` for the heading, `presenceOfElementLocated` for the option Knife and `textToBePresentInElementLocated` for the answer and for Latest pizza recommendations. Robot Framework used the `Wait Until ...` keywords, such as `Wait Until Element Is Visible css:h1` and `Wait Until Element Contains id:recommendations Name:`, with the library timeout of 10 seconds, and `Input Text` cleared the boxes by itself where Java needed `clear()`. The waits did their job, but they cannot fix a site that does not answer: once Java stopped with `TimeoutException ... #recommendations` and once Robot stopped with `Element with locator 'id:recommendations' not found.`, because QuickPizza gave no recommendation, and once Robot failed at step 7 because the admin list, which loads once and shows only 15 pizzas, did not contain our pizza. QP-01 ran in about 7.3 to 8.0 s in Java and 9.7 to 10.5 s in Robot Framework. It was quicker to write in Robot Framework, because the keywords read like the steps of the test case, while Java needed more lines for imports, `Select` and the helper `result`. The Robot log.html was the most readable report, because it showed every step, the returned values such as `${tool} = ...` and the screenshots in place, while the Surefire report only gives `Tests run: 1, Failures: 0` and a time, plus a long stack trace when a test fails.

5. I would use Robot Framework for the automated UI tests of Project 2. First, the keywords in the resource file let each automated test read like its written system test case, step by step, which is what Project 2 asks for when it requires the same steps and expected results as the written test case. Second, every run writes a log with the steps, the values and the screenshots, as in `results/run1/log.html`, so the evidence of a full run is produced without extra code, while in Java I had to add the `shot` method and copy the Surefire report by hand.

6. (Part 2) In QP01Test the XPath of the calories box is written inline in step 2, inside the wait `visibilityOfElementLocated(By.xpath("//label[normalize-space()='Max Calories per Slice']/preceding-sibling::input"))`, so that line has to be changed in the test itself, and every other test that copied it would need the same repair. In QP01PageObjectTest nothing changes, because the test only calls `home.showAdvanced()`, `home.setMaxCalories(600)` and `home.maxCalories()`. The locator is the single constant `MAX_CALORIES` at the top of `HomePage.java`, and changing that one line repairs every test that uses the page object. The page object makes the repair smaller because the details of the page live in one place and the tests describe only the steps.

7. (Part 3) I would change only the variable `${MAX CALORIES}` in the Variables section of `resources/quickpizza.resource`. The keywords Turn On Advanced and Fill In The Pizza Request use this variable, and `pizza_scenario.robot` never names a locator. It only calls the keywords, for example `Fill In The Pizza Request    600    Knife    ${name}`. So the test file stays the same, and every test that imports the resource file works again after that one change.
