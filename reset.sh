#!/bin/bash

echo "🧹 Resetting environment..."

# Clean all installations
rm -rf demo-app/node_modules demo-app/package-lock.json
rm -rf harmless-lib/node_modules harmless-lib/package-lock.json
rm -rf evil-lib/node_modules evil-lib/package-lock.json
rm -f demo-app-sbom.json

echo "✅ Node modules and lock files removed."
echo "✅ Now run 'make setup' or 'make baseline' to reinitialize."