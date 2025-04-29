#!/bin/bash

echo "🚀 Starting full bootstrap for shadow-supply-chain-demo..."

# Clean old node_modules and lock files
echo "🧹 Cleaning old state..."
bash clean-nodes.sh || true

# Run setup to rebuild all modules
echo "🔧 Running setup chain..."
bash setup.sh

# Install demo-app dependencies
echo "📦 Installing demo-app..."
cd demo-app
npm install
cd ..

echo "✅ Bootstrap complete."
echo "📝 Next steps: Run 'python3 -m http.server 8000' in another terminal, then run 'make simulate'"