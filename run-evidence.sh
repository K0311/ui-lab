#!/usr/bin/env bash
# Runs the evidence of Step 2.20 and Step 3.8: two full Maven runs and two
# full Robot Framework runs, then prints what RESULTS.md asks for.
# Run it from the root of the repository, once. Never in a loop (Section 2.2).
set -euo pipefail

if [ -z "${CHROMEDRIVER:-}" ]; then
  echo "CHROMEDRIVER is not set, see Step 0.3" >&2
  exit 1
fi
ROOT="$(cd "$(dirname "$0")" && pwd)"

echo "== Versions"
"$CHROMEDRIVER" --version
java -version 2>&1 | head -1
mvn -v | head -1

echo "== Part 2, Step 2.20: two full runs"
cd "$ROOT/selenium-java"
for run in 1 2; do
  start=$(date +%s)
  mvn -q test -Dheadless=true | tee "/tmp/mvn-run$run.log" || true
  end=$(date +%s)
  echo "Full run $run took $((end - start)) s"
  grep -h "Tests run:" target/surefire-reports/*.txt || true
done
mkdir -p reports
cp target/surefire-reports/uilab.QP01PageObjectTest.txt reports/
echo "Copied the report of run 2 to selenium-java/reports"

echo "== Part 3, Step 3.8: two full runs"
cd "$ROOT/robot"
if [ ! -d .venv ]; then
  python3 -m venv .venv
fi
# shellcheck disable=SC1091
source .venv/bin/activate
pip install -q -r requirements.txt
robot --version || true
for run in 1 2; do
  robot -d "results/run$run" -v BROWSER:headlesschrome pizza_scenario.robot || true
  python3 - "results/run$run/output.xml" <<'PY'
import sys, xml.etree.ElementTree as ET
root = ET.parse(sys.argv[1]).getroot()
test = root.find(".//test")
status = test.find("status")
name = next((m.text for m in root.iter("msg")
             if m.text and m.text.startswith("${name} = ")), "?")
print(f"{sys.argv[1]}: {status.get('status')}, "
      f"elapsed {status.get('elapsed')} s, {name}")
PY
done
echo "Done. Copy the lines above into RESULTS.md, then commit and push."
