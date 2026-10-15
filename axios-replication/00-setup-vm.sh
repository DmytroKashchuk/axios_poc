#!/bin/bash
# Setup script - run inside fresh Ubuntu VM
# This installs Node.js, Verdaccio (local npm registry), and Syft

set -e

echo "=== Installing Node.js 20 LTS ==="
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

echo "=== Verifying Node.js ==="
node --version
npm --version

echo "=== Installing Verdaccio (local npm registry) ==="
sudo npm install -g verdaccio

echo "=== Installing Syft (for SBOM generation) ==="
curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sudo sh -s -- -b /usr/local/bin

echo "=== Done ==="
echo "Next steps:"
echo "  1. Start Verdaccio in one terminal:    verdaccio"
echo "  2. Set npm to use local registry:      npm set registry http://localhost:4873"
echo "  3. Create a Verdaccio account:         npm adduser --registry http://localhost:4873"
echo "  4. Run the experiment scripts in order"
