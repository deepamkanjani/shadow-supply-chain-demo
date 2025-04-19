#!/bin/bash

set -e

echo "[*] Cleaning previous builds..."
rm -rf demo-app/node_modules demo-app/package-lock.json
rm -rf harmless-lib/node_modules harmless-lib/package-lock.json
rm -rf evil-lib/node_modules evil-lib/package-lock.json

echo "[*] Packing evil-lib..."
cd evil-lib
npm pack
cd ..

echo "[*] Updating harmless-lib to point to evil-lib..."
sed -i.bak 's|"evil-lib":.*|"evil-lib": "file:../evil-lib/evil-lib-1.0.0.tgz"|' harmless-lib/package.json

echo "[*] Installing and packing harmless-lib..."
cd harmless-lib
npm install
npm pack
cd ..

echo "[*] Updating demo-app to point to harmless-lib..."
sed -i.bak 's|"harmless-lib":.*|"harmless-lib": "file:../harmless-lib/harmless-lib-1.0.0.tgz"|' demo-app/package.json

echo "[*] Installing demo-app..."
cd demo-app
npm install

echo "[✓] Setup complete. Now run the exfil server and then 'npm install' again in demo-app if needed."
