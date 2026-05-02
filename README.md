# Host Header Injection Scanner 🛡️

This Bash script is a lightweight automated tool designed to scan lists of subdomains or URLs for **Host Header Injection** vulnerabilities[cite: 1]. It tests how a web server handles modified or malicious `Host` and `X-Forwarded-Host` headers[cite: 1].

---

## 🚀 Setup & Installation

### 1. Save the Script
Copy the code provided in your prompt and save it to a file named `host_scanner.sh`[cite: 1, 2].

### 2. Configure Your Collaborator
Open the script and edit the `EVIL_HOST` variable to point to your listener (e.g., a Burp Collaborator or interaction server)[cite: 1]:
```bash
EVIL_HOST="your-id.oastify.com"
```

### 3. Set Execution Permissions
Use `chmod` to make the script executable[cite: 2]:
```bash
chmod +x host_scanner.sh
```[cite: 2]

---

## 🛠️ How to Use

### 1. Prepare Your Target List
Create a text file (e.g., `targets.txt`) containing the subdomains or URLs you wish to scan, with one entry per line[cite: 1, 2]:
```text
example.com
api.example.com
staging.example.com
```[cite: 1, 2]

### 2. Execute the Scan
Run the script by passing your target file as an argument[cite: 1, 2]:
```bash
./host_scanner.sh targets.txt
```[cite: 1, 2]

---

## 🧠 Intelligence Layer: Test Methods
The script performs three distinct types of injection attacks to identify misconfigurations[cite: 1]:

| Test Method | Description |
| :--- | :--- |
| **Direct Replacement** | Replaces the standard `Host` header entirely with the `EVIL_HOST`[cite: 1]. |
| **X-Forwarded-Host** | Injects the `X-Forwarded-Host` header to see if the backend relies on it for URL generation[cite: 1]. |
| **Duplicate Headers** | Sends two `Host` headers to check if the server processes the second one (obfuscation)[cite: 1]. |

---

## 📁 Output & Results
*   **Console Output**: Provides real-time feedback using color-coded status messages: `${RED}VULNERABLE${NC}` or `${GREEN}SECURE${NC}`[cite: 1].
*   **Logging**: All confirmed vulnerabilities (where the `EVIL_HOST` is reflected in the response) are automatically saved to `host_injection_hits.log` for later review[cite: 1].

---

> **⚠️ Ethical Warning:** This tool is for authorized security testing and educational purposes only[cite: 2]. Scanning targets without explicit permission is illegal and unethical[cite: 2].