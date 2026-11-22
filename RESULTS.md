# UI lab results

Tool parts that I chose: Part 2, Selenium WebDriver in Java, and Part 3, Robot Framework

> Lines marked **TODO** need a value from your own computer or your own run.
> Fill them in, then delete this note.

## Part 0
- Step 0.1, Chrome version: **TODO** (first line of chrome://version)
- Step 0.3, ChromeDriver version: **TODO** (output of `$CHROMEDRIVER --version`)
- Step 0.4, locator of Pizza, Please!: `name=pizza-please`, as CSS `button[name="pizza-please"]`, 1 match
- Step 0.4, locator of Excluded tools: `select`, the only select element on the page, as XPath `//select[option[normalize-space()='Knife']]`, 1 match
- Step 0.4, locator of Must be vegetarian: `#default-checkbox`, 1 match
- Step 0.4, locator of Custom Pizza Name: `input#pizza-name`, 1 match. `#pizza-name` alone finds 2 elements after Pizza, Please!, because the heading of the answer has the same id
- Step 0.5, pizza name, tool and calories of the run by hand: **TODO** (for example Lab Pizza 20261122-160000, tool ..., ... calories per slice)

| Step | Actual result | Pass or fail |
|------|---------------|--------------|
| 1    | **TODO** The heading reads Looking to break out of your pizza routine? | **TODO** |
| 2    | **TODO** Max Calories per Slice (showing 1000), Excluded tools, Must be vegetarian and Custom Pizza Name appear | **TODO** |
| 3    | **TODO** The fields show 600, Knife, vegetarian ticked and the pizza name | **TODO** |
| 4    | **TODO** The answer shows Name: (pizza name), Tool: (tool), Calories per slice: (number) | **TODO** |
| 5    | **TODO** The page says Please log in first. | **TODO** |
| 6    | **TODO** After Sign in with admin and admin, the page shows Latest pizza recommendations | **TODO** |
| 7    | **TODO** The line with the pizza name shows (tool=...) with the same tool as in step 4 | **TODO** |

## Part 2: Selenium WebDriver in Java
- Step 2.4, the failure line for the wrong title: **TODO** (expected: `[ERROR]   FirstTest.webFormOpens:20 expected: <Web Form> but was: <Web form>`)
- Step 2.15, QP01Test run 1, result and time: **TODO**
- Step 2.15, QP01Test run 2, result and time: **TODO**
- Step 2.20, full run 1, time and number of tests: **TODO** time, expected Tests run: 5 (FirstTest, WebFormTest, WaitTest, QP01Test and QP01PageObjectTest, one test each)
- Step 2.20, full run 2, time and number of tests: **TODO**

## Part 3: Robot Framework
- robot --version: **TODO** (for example Robot Framework 7.5.1 (Python 3.13.x on darwin))
- Step 3.2, failure message for the wrong title: Title should have been 'Web Form' but was 'Web form'. **TODO** confirm in your run
- Step 3.8, run 1, result, elapsed time and pizza name: **TODO**
- Step 3.8, run 2, result, elapsed time and pizza name: **TODO**

## Part B
1. The calories box has the id `floating_filled`, but `$$("#floating_filled").length` returns 3 in the Console, because Max Calories per Slice, Min Number of Toppings and Max Number of Toppings all use that id. `By.id("floating_filled")` would always return the first of them, so a test could not tell the boxes apart and could type into the wrong one without failing. The tests therefore start from the unique label text Max Calories per Slice and step to the input next to it. I propose that each box gets its own id, such as `id="max-calories-per-slice"` together with `<label for="max-calories-per-slice">`. The locator would then be short, unique and independent of the label wording and the layout, so a change of the text or of the order of the boxes would no longer break the test, and the label would also be correctly linked to its box for screen readers.

2. Step 7 is a consistency oracle. It does not know the correct tool in advance, because QuickPizza picks the pizza at random, so it compares two outputs of the same system with each other, the tool in the recommendation on the home page and the tool in the admin list. It would catch a fault where the server saves a different record than it returns, for example if the admin list read the tool of another pizza, saved the tool before the restrictions were applied, or mixed up the rows of two users who asked for a pizza at the same moment. Each of these faults makes the line of our pizza show `(tool=...)` with a tool other than the one in step 4, and the assertion fails.

3. The answer lists the ingredients of the pizza under Ingredients:, so a check could read every item of that list and assert that none of them is in a list of non-vegetarian ingredients, such as Pepperoni, Bacon or Anchovies. The test then needs that reference list from a source other than the page, for example the ingredient data of the QuickPizza API, where every ingredient has a `vegetarian` field, or a fixed list written into the test case. An easier but weaker check uses the JSON answer of `POST /api/pizza`, which has a field `vegetarian` with the value `true` or `false`. The UI does not show this flag, so the test would read it from the network or from the API rather than from the page.

4. **TODO, adjust with your own times.** Both tools waited for the elements, never with a fixed pause. Selenium Java used `WebDriverWait` with `ExpectedConditions` for up to 10 seconds, such as `visibilityOfElementLocated(By.tagName("h1"))` for the heading, `presenceOfElementLocated` for the option Knife and `textToBePresentInElementLocated` for the answer and for Latest pizza recommendations. Robot Framework used the `Wait Until ...` keywords, such as `Wait Until Element Is Visible css:h1` and `Wait Until Element Contains id:recommendations Name:`, with the library timeout of 10 seconds, and `Input Text` cleared the boxes by itself, where Java needed `clear()`. QP-01 was quicker to write in Robot Framework, because the keywords read like the steps of the test case, while Java needed more lines for imports, `Select` and the helper `result`. The Robot log.html was the most readable report, because it showed every step with its arguments, the returned values such as `${tool} = ...` and the screenshots in place, while the Surefire report only lists `Tests run: 1, Failures: 0` and the time. One full QP-01 run took about **TODO** s in Java and **TODO** s in Robot Framework.

5. **TODO, check that this matches your group's choice.** I would use Robot Framework for the automated UI tests of Project 2. First, the keywords in the resource file let each automated test read like its written system test case, step by step, which is what Project 2 asks for when it requires the same steps and expected results as the written test case. Second, every run writes a log with the steps, the values and the screenshots, as in `results/run1/log.html`, so the evidence of a full run is produced without extra code, while in Java I had to add the `shot` method and copy the Surefire report by hand.

6. (Part 2) In QP01Test the XPath of the calories box is written inline in step 2, inside the wait `visibilityOfElementLocated(By.xpath("//label[normalize-space()='Max Calories per Slice']/preceding-sibling::input"))`, so that line has to be changed in the test itself, and every other test that copied it would need the same repair. In QP01PageObjectTest nothing changes, because the test only calls `home.showAdvanced()`, `home.setMaxCalories(600)` and `home.maxCalories()`. The locator is the single constant `MAX_CALORIES` at the top of `HomePage.java`, and changing that one line repairs every test that uses the page object. The page object makes the repair smaller because the details of the page live in one place and the tests describe only the steps.

7. (Part 3) I would change only the variable `${MAX CALORIES}` in the Variables section of `resources/quickpizza.resource`. The keywords Turn On Advanced and Fill In The Pizza Request use this variable, and `pizza_scenario.robot` never names a locator. It only calls the keywords, for example `Fill In The Pizza Request    600    Knife    ${name}`. So the test file stays the same, and every test that imports the resource file works again after that one change.
