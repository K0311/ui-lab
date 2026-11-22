# Runs the evidence of Step 2.20 and Step 3.8 on Windows PowerShell:
# two full Maven runs and two full Robot Framework runs, then prints what
# RESULTS.md asks for. Run it once from the root of the repository:
#   powershell -ExecutionPolicy Bypass -File .\run-evidence.ps1
# Never run it in a loop (Section 2.2).
$ErrorActionPreference = "Continue"
$Root = $PSScriptRoot

if (-not $env:CHROMEDRIVER) {
    Write-Error "CHROMEDRIVER is not set, see Step 0.3"
    exit 1
}

Write-Host "== Versions"
& $env:CHROMEDRIVER --version
java -version 2>&1 | Select-Object -First 1
mvn -v | Select-Object -First 1

Write-Host "== Part 2, Step 2.20: two full runs"
Set-Location "$Root\selenium-java"
foreach ($run in 1, 2) {
    $time = Measure-Command { mvn -q test "-Dheadless=true" | Out-Host }
    Write-Host ("Full run {0} took {1:N1} s" -f $run, $time.TotalSeconds)
    Get-ChildItem target\surefire-reports\*.txt |
        Select-String "Tests run:" | ForEach-Object { $_.Line }
}
New-Item -ItemType Directory -Force reports | Out-Null
Copy-Item target\surefire-reports\uilab.QP01PageObjectTest.txt reports\
Write-Host "Copied the report of run 2 to selenium-java\reports"

Write-Host "== Part 3, Step 3.8: two full runs"
Set-Location "$Root\robot"
if (-not (Test-Path .venv)) { python -m venv .venv }
& .\.venv\Scripts\Activate.ps1
pip install -q -r requirements.txt
robot --version
foreach ($run in 1, 2) {
    robot -d "results/run$run" -v BROWSER:headlesschrome pizza_scenario.robot
    [xml]$out = Get-Content "results\run$run\output.xml"
    $status = $out.SelectSingleNode("//test/status")
    $name = $out.SelectNodes("//msg") |
        Where-Object { $_.InnerText -like '${name} = *' } |
        Select-Object -First 1
    Write-Host ("run{0}: {1}, elapsed {2} s, {3}" -f $run,
        $status.status, $status.elapsed, $name.InnerText)
}
Set-Location $Root
Write-Host "Done. Copy the lines above into RESULTS.md, then commit and push."
