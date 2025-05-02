.PHONY: setup baseline tamper audit sbom scan semgrep simulate clean

NODE := demo-app/node_modules/.bin
PYTHON := python3

setup:
	bash setup.sh

baseline:
	cd demo-app && rm -rf node_modules package-lock.json && npm install

tamper:
	bash setup.sh && cd demo-app && rm -rf node_modules package-lock.json && npm install

audit:
	cd demo-app && npm audit || true
	cd demo-app && npx osv-scanner --lockfile=package-lock.json || true

sbom:
	syft demo-app/. > demo-app-sbom.json || true

scan:
	syft dir:demo-app -o cyclonedx-json > demo-app-syft.sbom.json
	[ -f demo-app-syft.sbom.json ] && echo "✅ SBOM generated" || (echo "❌ SBOM missing" && exit 1)
	sbomasm assemble -c sbomasm-config.yaml ./demo-app-syft.sbom.json ./dummy-empty.sbom.json
	syft dir:demo-app -o cyclonedx-json > demo-app-sbom.json
	grype demo-app-sbom.json || true

sempgrep:
	@echo "[semgrep] Running static analysis on demo-app..."
	semgrep scan --config auto demo-app/ || true

simulate:
	cd demo-app && rm -rf node_modules package-lock.json && npm install

clean:
	rm -rf demo-app/node_modules demo-app/package-lock.json
	rm -rf harmless-lib/node_modules harmless-lib/package-lock.json
	rm -rf evil-lib/node_modules evil-lib/package-lock.json
	rm -f demo-app-sbom.json
