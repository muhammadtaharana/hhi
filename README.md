## Host Header Injector (HHI) - v1

<p align="center">
<img width="1024" height="484" alt="image" src="https://github.com/user-attachments/assets/7cdf7f14-273e-4489-81e8-6230a2735560" />
</p>

> [!NOTE]
> **HHI v1** is a specialized security scanner designed to detect Host Header Injection vulnerabilities by testing various injection vectors including header replacement, dual-hosting, and forwarded headers. **Phase 1 Enhanced with CLI flexibility, JSON reporting, and robust error handling.**

</br>
</br>

### Features

* **Multi-Vector Testing:** Automatically tests for direct `Host` replacement, `X-Forwarded-Host` injection, and duplicate header attacks.
* **Smart Parsing:** Cleans input lists by removing protocols and whitespace automatically.
* **Real-time Verification:** Analyzes server response headers for reflection of the malicious host.
* **Lightweight & Fast:** Built in Bash with standard `curl` for maximum compatibility and speed.
* **CLI Flexibility:** Custom evil host, timeout, and output file via command-line arguments.
* **Multiple Output Formats:** Text (human-readable) and JSON (structured data) output options.
* **Robust Error Handling:** Comprehensive input validation and error messages.
* **Verbose Mode:** Detailed logging for debugging and verification.

</br>
</br>

### Installation

Clone the repository and ensure the scripts have execution permissions:

```bash
git clone https://github.com/muhammadtaharana/hhi
cd hhi
chmod +x hhi.sh host_header_Injector.sh
```

</br>
</br>

### Usage

```bash
hhi [OPTIONS] <subdomains_file>
```

#### Options

| Option | Short | Long | Description | Default |
|--------|-------|------|-------------|---------|
| Host | `-h` | `--host` | Custom evil host to inject | `evil-collaborator.com` |
| Timeout | `-t` | `--timeout` | Timeout for curl requests (seconds) | `5` |
| Output | `-o` | `--output` | Output log file | `host_injection_hits.log` |
| Format | `-f` | `--format` | Output format: `text` or `json` | `text` |
| Verbose | `-v` | `--verbose` | Enable verbose output | disabled |
| Help | - | `--help` | Display help message | - |

</br>
</br>

### Usage Examples

#### Basic scan with default settings
```bash
./hhi.sh subdomains.txt
```

#### Custom evil host
```bash
./hhi.sh --host attacker.com subdomains.txt
./hhi.sh -h burp-collaborator.oastify.com subdomains.txt
```

#### Adjust timeout for slow/distant targets
```bash
./hhi.sh --timeout 15 subdomains.txt
./hhi.sh -t 10 urls_file.txt
```

#### Save results to custom file
```bash
./hhi.sh --output results.log subdomains.txt
./hhi.sh -o my_scan_2026.log subdomains.txt
```

#### JSON output for automation/reporting
```bash
./hhi.sh --format json -o results.json subdomains.txt
./hhi.sh -f json subdomains.txt
```

#### Verbose debugging
```bash
./hhi.sh --verbose subdomains.txt
./hhi.sh -v -h attacker.com -f json subdomains.txt
```

#### Combine multiple options
```bash
./hhi.sh -h collaborator.oastify.com -t 10 -o scan_results.log -f json -v subdomains.txt
```

</br>
</br>

### Output Formats

#### Text Format (Default)
```
    __  __           __  ____        _           __            
   / / / /___  _____/ /_/  _/___    (_)__  _____/ /_____  _____
  / /_/ / __ \/ ___/ __// // __ \  / / _ \/ ___/ __/ __ \/ ___/
 / __  / /_/ (__  ) /__/ // / / / / /  __/ /__/ /_/ /_/ / /    
/_/ /_/\____/____/\__/___/_/ /_/_/ /\___/\___/\__/\____/_/     
                              /___/                            

@MuhammadTahaRana                                               v1

--- Starting Host Header Injection Scan ---
Evil Host:   evil-collaborator.com
Timeout:     5s
Format:      text
Output File: host_injection_hits.log

[VULNERABLE] target.com
  → Direct Host Header Replacement
  → X-Forwarded-Host Header

[SECURE] another-target.com

════════════════════════════════════════
Scan Complete!
Targets Scanned:     2
Vulnerable Found:    1
Results saved to:    host_injection_hits.log
════════════════════════════════════════
```

#### JSON Format
```json
{
  "scan_info": {
    "timestamp": "2026-05-03T10:30:45Z",
    "evil_host": "evil-collaborator.com",
    "timeout_seconds": 5,
    "targets_scanned": 2,
    "vulnerable_targets": 1
  },
  "results": [
    {
      "target": "target.com",
      "vulnerable": true,
      "vectors": {
        "direct_host": true,
        "x_forwarded_host": true,
        "dual_headers": false
      }
    },
    {
      "target": "another-target.com",
      "vulnerable": false,
      "vectors": {
        "direct_host": false,
        "x_forwarded_host": false,
        "dual_headers": false
      }
    }
  ]
}
```

</br>
</br>

### Technical Logic

The engine executes three distinct test phases for every target:

| Test Case | Description |
| :--- | :--- |
| **Direct Replacement** | Replaces the standard `Host` header with an evil collaborator domain. |
| **X-Forwarded-Host** | Injects the malicious domain via the `X-Forwarded-Host` header to test proxy/cache behavior. |
| **Dual Host Header** | Sends two conflicting `Host` headers to identify server-side parsing inconsistencies. |

</br>

### Error Handling

The tool validates:
- ✅ Input file existence and readability
- ✅ Timeout is a positive integer
- ✅ Output format is valid (`text` or `json`)
- ✅ Evil host is not empty
- ✅ `curl` is installed and available
- ✅ Output file is writable

Errors are printed to stderr with clear messages.

</br>
</br>

### Pro Tips

> [!TIP]
> 
> - **Use Burp Collaborator or Interactsh** as your `EVIL_HOST` for the most accurate out-of-band detection:
>   ```bash
>   ./hhi.sh -h your-burp-instance.oastify.com subdomains.txt
>   ```
>
> - **Combine with subdomain enumeration tools** for large-scale scanning:
>   ```bash
>   subfinder -d example.com -o subdomains.txt
>   ./hhi.sh subdomains.txt
>   ```
>
> - **Use JSON output for CI/CD pipelines and automation:**
>   ```bash
>   ./hhi.sh -f json -o results.json subdomains.txt
>   # Parse with jq, Python, or other tools
>   jq '.results[] | select(.vulnerable==true) | .target' results.json
>   ```
>
> - **Adjust timeout for different network conditions:**
>   - Fast networks: `--timeout 3`
>   - Normal networks: `--timeout 5` (default)
>   - Slow/distant targets: `--timeout 15`
>
> - **Check text results in the log file** after scanning:
>   ```bash
>   cat host_injection_hits.log
>   ```

</br>
</br>

### Requirements

- `bash` (v4.0+)
- `curl` (any recent version)
- Standard Unix tools: `sed`, `grep`, `xargs`

### Compatibility

- ✅ Linux (any distribution)
- ✅ macOS
- ✅ Windows (WSL, Git Bash, or Cygwin)
- ✅ BSD variants

</br>
</br>

### Version History

#### v1 (Phase 1 - Enhanced)
- ✨ CLI arguments for flexibility (`--host`, `--timeout`, `--output`, `--format`)
- ✨ JSON output format for automation and reporting
- ✨ Verbose mode for debugging
- ✨ Comprehensive error handling and validation
- ✨ Improved help system
- 🎨 Nuclei-style banner with author attribution

#### v0 (Initial Release)
- Multi-vector Host Header Injection testing
- Colored terminal output
- Simple log file output

</br>
</br>

### TO-DO (Planned for Phase 2 & 3)

* [ ] Implement support for custom collaborator URLs via environment variables
* [ ] Add multi-threading support for faster scanning of large lists
* [ ] Integrate more obscure headers like `X-Host` and `X-Forwarded-Server`
* [ ] Proxy support (`--proxy` flag)
* [ ] Custom headers support (`--header` flag)
* [ ] Response body checking for reflections
* [ ] HTML report generation
* [ ] Slack/Email notifications

</br>
</br>

> [!CAUTION]
> **Use HHI only on assets you own or have explicit permission to test. Unauthorized scanning can be illegal. The authors are not responsible for any misuse or damage caused by this tool.**

</br>

---

**Author:** @MuhammadTahaRana  
**License:** MIT (or your choice)  
**Version:** v1
