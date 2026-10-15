#!/bin/bash
# Publishes both packages to local Verdaccio.
# Make sure Verdaccio is running (verdaccio &) and you ran:
#   npm set registry http://localhost:4873
#   npm adduser --registry http://localhost:4873

set -e

REGISTRY="http://localhost:4873"

echo "=== Publishing plain-crypto-js@4.2.1 ==="
cd plain-crypto-js
npm publish --registry $REGISTRY
cd ..

echo ""
echo "=== Publishing modified axios@1.14.1 ==="
cd evil-axios/axios-source
npm publish --registry $REGISTRY
cd ../..

echo ""
echo "=== Both packages published to local Verdaccio ==="
echo "Verify at: http://localhost:4873"
