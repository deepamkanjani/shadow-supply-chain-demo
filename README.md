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

### 🔹 Install Tools (via Homebrew)

```bash
brew install syft
brew install osv-scanner
brew install semgrep
```

These tools are required for the SBOM generation, vulnerability scanning, and static analysis:

- `syft`: generates software bill of materials (SBOMs)
- `osv-scanner`: scans SBOMs or lockfiles against open source vulnerabilities (OSV database)
- `semgrep`: performs static analysis of JS and other languages

Ensure you have `npm` and `node` installed for running the demo-app.
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

---

## 🧪 Part 1: Attack Simulation – What Breaks

This section shows how the attack works and why traditional tools fail to detect it.

### 🔹 Steps:

1. Navigate to `demo-app/` and run:

   ```bash
   npm install
   ```

   ✅ This triggers the transitive install of `evil-lib`, which silently exfiltrates environment variables.

2. Observe logs in terminal: you won't see any direct call to `evil-lib`, but it runs due to its install script.

3. Try scanning with osv-scanner:

   ```bash
   osv-scanner --lockfile=package-lock.json
   ```

   ✅ Output: No vulnerabilities found (because the attack is not in a CVE DB).

4. Generate a baseline SBOM with syft:

   ```bash
   syft .
   ```

   ✅ You’ll mostly see top-level dependencies only.

5. Now augment the SBOM using sbomasm:

   ```bash
   sbomasm --input package-lock.json --output sbom-augmented.json
   ```

6. Re-run osv-scanner with the augmented SBOM:

   ```bash
   osv-scanner --sbom=sbom-augmented.json
   ```

   🔴 Now, `evil-lib` shows up — because the augmented SBOM flattens the full transitive tree.

---

## 🛡 Part 2: Remediation – What Fixes It

This section shows how to prevent or detect the attack using hygiene, verification, and behavior checks.

### 🔹 Steps:

1. Run the provided hygiene workflow:

   ```bash
   ./remediation.sh
   ```

   This script:
   - Regenerates a full SBOM via sbomasm
   - Scans it with osv-scanner
   - Runs semgrep for static analysis
   - Ensures clean install via `npm ci --ignore-scripts`

2. Review `sbom-augmented.json` — verify the absence of untrusted packages.

3. Run static analysis independently:

   ```bash
   semgrep --config auto demo-app/
   ```

4. Implement `.npmrc` policy to block install scripts in CI:

   ```
   ignore-scripts=true
   ```

5. Treat lockfiles and SBOMs as audit artifacts. Commit them, diff them, review them.

---

✅ This two-part workflow highlights:
- How blind spots form
- Where tools fail out of the box
- How to extend, validate, and monitor dependencies with context



---

## ♻️ Resetting the Environment: Go Back to Pre-Remediation State

Use the following script to reset your environment back to the pre-remediation attack-ready state.

### 🔁 Steps:

```bash
./reset-remediation.sh
```

What it does:
- Deletes `node_modules` and the `package-lock.json`
- Clears any generated SBOMs
- Reinstalls dependencies using the original attack path
- Brings your project back to the same state before running `remediation.sh`

This lets you toggle between detection failures and remediated success easily during the demo.

---



---

## ⚠️ Known Issues / Troubleshooting

### 🛠 Shell Scripts Won’t Run? (Permission Denied)

If you try to run `setup.sh`, `reset.sh`, `remediation.sh`, or `reset-remediation.sh` and see a permission error:

```bash
bash: ./reset.sh: Permission denied
```

You need to make the script executable. Run:

```bash
chmod +x *.sh
```

Or, individually:

```bash
chmod +x reset.sh remediation.sh reset-remediation.sh bootstrap.sh
```

Then you can run them as expected:

```bash
./reset.sh
```

This issue commonly occurs on fresh clones or downloads, especially on macOS/Linux.

---



---

### 🔐 Demo Secret Setup

The `setup.sh` script now includes a line that sets an environment variable for demonstration purposes:

```bash
export DEMO_SECRET="somethingsupersecret$(scutil --get ComputerName)"
```

This simulates a sensitive secret that would be exfiltrated by `evil-lib` in the demo. You’ll see it in the logs as part of the safe, simulated payload.

Make sure to run:

```bash
source setup.sh
```

To ensure the `DEMO_SECRET` is available in the current shell session.

---


---

## 🧯 sbomasm Not Found?

If you encounter the error:

```bash
make: sbomasm: No such file or directory
```

It means `sbomasm` is not installed or not available in your system's PATH.

### ✅ To fix this, either:

**Option 1: Install via Homebrew (recommended)**

```bash
brew install interlynk-io/sbomasm/sbomasm
```

**Option 2: Install manually (for Linux or Mac)**

1. Go to: https://github.com/interlynk-io/sbomasm/releases
2. Download the appropriate binary for your system (e.g., `sbomasm-darwin-arm64`)
3. Move it to a location in your path and give it execute permissions:

```bash
chmod +x sbomasm-darwin-arm64
mv sbomasm-darwin-arm64 /usr/local/bin/sbomasm
```

Verify it works:

```bash
sbomasm --help
```

