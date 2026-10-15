#!/bin/bash
# Runs the experiment and shows three scenarios:
#   A. Normal install -> postinstall hook fires (compromise!)
#   B. Install with --ignore-scripts -> hook blocked
#   C. Generate SBOM with Syft -> shows transitive dependency

set -e

cd my-app

echo "============================================================"
echo "SCENARIO A: normal npm install (this is what most CI does)"
echo "============================================================"

# Make sure /tmp/pwned.txt does not exist from a previous run
rm -f /tmp/pwned.txt
rm -rf node_modules package-lock.json

echo ""
echo "Running: npm install"
echo ""
npm install

echo ""
echo "--- Did the postinstall hook execute? ---"
if [ -f /tmp/pwned.txt ]; then
  echo "YES. Evidence file at /tmp/pwned.txt:"
  echo ""
  cat /tmp/pwned.txt
  echo ""
  echo "Proof of compromise: the marker file exists."
  echo "Note: my-app never imported plain-crypto-js."
  echo "      It only declared a dependency on axios."
else
  echo "NO. Something went wrong with the experiment."
fi

echo ""
echo "============================================================"
echo "SCENARIO B: install with --ignore-scripts (the mitigation)"
echo "============================================================"

rm -f /tmp/pwned.txt
rm -rf node_modules package-lock.json

echo ""
echo "Running: npm install --ignore-scripts"
echo ""
npm install --ignore-scripts

echo ""
echo "--- Did the postinstall hook execute this time? ---"
if [ -f /tmp/pwned.txt ]; then
  echo "YES. Mitigation failed."
else
  echo "NO. /tmp/pwned.txt does not exist."
  echo "    The malicious package is still in node_modules,"
  echo "    but its postinstall hook was blocked."
fi

echo ""
echo "--- Is plain-crypto-js still on disk? ---"
ls -la node_modules/plain-crypto-js/ 2>/dev/null && \
  echo "    Yes, it is in node_modules - just did not execute." || \
  echo "    Not present."

echo ""
echo "============================================================"
echo "SCENARIO C: SBOM with Syft - visibility of the transitive dep"
echo "============================================================"

echo ""
echo "Generating SBOM in CycloneDX JSON format..."
syft . -o cyclonedx-json > sbom.json 2>/dev/null

echo ""
echo "--- Components in the SBOM ---"
node -e "
  const sbom = require('./sbom.json');
  const comps = sbom.components || [];
  comps.forEach(c => console.log('  -', c.name + '@' + c.version));
"

echo ""
echo "Notice: plain-crypto-js@4.2.1 appears in the SBOM."
echo "        It is a transitive dependency of axios."
echo "        my-app's package.json never mentions it."
echo ""
echo "This is why SBOM tooling (Syft) matters: it reveals what"
echo "package.json hides."
