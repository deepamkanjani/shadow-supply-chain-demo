#!/bin/bash

echo "🧽 Cleaning ALL node_modules and lock files recursively..."

find . -type d -name "node_modules" -exec rm -rf {} +
find . -type f -name "package-lock.json" -exec rm -f {} +

echo "✅ node_modules and package-lock.json cleaned from entire repo."