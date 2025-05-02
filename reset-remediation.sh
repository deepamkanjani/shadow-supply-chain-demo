#!/bin/bash
set -e

echo "[reset-remediation] Cleaning node_modules and lockfile..."
rm -rf demo-app/node_modules demo-app/package-lock.json

echo "[reset-remediation] Restoring demo-app to pre-remediation state..."
cp demo-app/package.json.bak demo-app/package.json 2>/dev/null || true

echo "[reset-remediation] Resetting SBOM files..."
rm -f sbom-augmented.json sbom-before.json

echo "[reset-remediation] Reinstalling dependencies..."
cd demo-app && npm install && cd ..

echo "[reset-remediation] Environment is reset. You are now back in pre-remediation state."
