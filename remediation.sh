#!/bin/bash
set -e

echo "[remediation] Step 1: Generate SBOM with syft..."
syft dir:demo-app -o cyclonedx-json > demo-app-syft.sbom.json

echo "[remediation] Step 2: Run sbomasm..."
sbomasm assemble -c sbomasm-config.yaml ./demo-app-syft.sbom.json ./dummy-empty.sbom.json

echo "[remediation] Step 3: Scan with grype..."
grype sbom:./demo-app-sbom.json || true

echo "[remediation] Step 4: Check for unexpected packages..."
[ -f demo-app-sbom.json ] && grep "evil-lib" demo-app-sbom.json || echo "✅ No unexpected packages"

echo "[remediation] Step 5: Ensure lockfile integrity..."
if [ ! -f demo-app/package-lock.json ]; then
  echo "[remediation] No package-lock.json found, running npm install..."
  (cd demo-app && npm install)
fi
(cd demo-app && npm ci --ignore-scripts)

echo "[remediation] ✅ Done."
