# 🔐 Shadow Supply Chain Demo

This demo simulates a real-world software supply chain attack via **transitive dependency hijacking**.

A seemingly harmless library (`harmless-lib`) depends on a malicious package (`evil-lib`). When used in an application (`demo-app`), the attack gets executed at install time.

---

## 🎯 Demo Goal

To show how attackers can:
- Exploit the transitive dependency chain
- Hide malicious code inside `postinstall` scripts
- Avoid detection through deeply nested packages

And how defenders can:
- Detect tampering with SBOMs and scanners
- Use static analysis tools to catch risks earlier

---

## 🛠 Setup Instructions

### 1️⃣ Install Python tools

```bash
pip install -r requirements.txt
```

Tools installed:
- `syft`: generate SBOM
- `osv-scanner`: scan lockfiles against known CVEs
- `semgrep`: static analysis of JS code

### 2️⃣ Install Grype (separately)

```bash
# Recommended: via Homebrew
brew install grype

# Or: direct binary install
curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin
```

### 3️⃣ Bootstrap the demo

```bash
bash bootstrap.sh
```

This will:
- Clean all node_modules and lockfiles
- Rebuild the evil-lib → harmless-lib → demo-app chain
- Install all dependencies

---

## 🧪 Run the Live Exploit

### Start a fake exfil server:

```bash
python3 -m http.server 8000
```

### Then simulate compromise:

```bash
make simulate
```

You should see a `GET /steal?...` request on the server. That's the exfil payload triggered from a **postinstall script**.

---

## 🔍 Detection & Hardening

| Command | Purpose |
|---------|---------|
| `make audit` | Run `npm audit` and `osv-scanner` |
| `make sbom` | Generate SBOM with Syft |
| `make scan` | Scan SBOM with Grype (if installed) |
| `make semgrep` | Static analysis for suspicious install scripts |

---

## 🧹 Maintenance Scripts

| Script | Purpose |
|--------|---------|
| `reset.sh` | Clean node_modules and lockfiles from core folders |
| `clean-nodes.sh` | Recursively delete all node_modules and lockfiles |
| `bootstrap.sh` | Run full clean + setup + install |

---

## 📂 Folder Structure

```
shadow-supply-chain-demo/
├── demo-app/
├── harmless-lib/
├── evil-lib/
├── scripts/
├── Makefile
├── setup.sh
├── reset.sh
├── clean-nodes.sh
├── bootstrap.sh
├── requirements.txt
└── README.md
```

---

## 🗂 Make Targets

```bash
make setup       # Run setup.sh to rebuild the full chain
make baseline    # Clean install with no tampering
make tamper      # Rebuild and install with evil-lib injected
make simulate    # Trigger the attack payload via npm install
make audit       # Run osv-scanner and npm audit
make sbom        # Generate SBOM using syft
make scan        # Scan SBOM using grype
make semgrep     # Static detection using Semgrep
make clean       # Reset all generated files
```

---

## 🧠 Talk Track for Demo

1. **Start with setup** (`make baseline`)
2. **Show a clean install** → No exfil
3. **Switch to tampered chain** (`make tamper`)
4. **Run simulate** → Exfil triggers!
5. **Show detection** with `audit`, `sbom`, `scan`, `semgrep`

---

2025 — Demo by Deepam Kanjani
