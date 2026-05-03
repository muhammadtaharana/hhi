## Host Header Injector (HHI)

<p align="center">
  <img src="[https://github.com/user-attachments/assets/39d6e99e-8281-4f48-811b-14478f25be99](https://github.com/user-attachments/assets/39d6e99e-8281-4f48-811b-14478f25be99)" alt="banner" width="600">
</p>

> [!NOTE]
> **HHI** is a specialized security scanner designed to detect Host Header Injection vulnerabilities by testing various injection vectors including header replacement, dual-hosting, and forwarded headers.

</br>
</br>

### Features

* **Multi-Vector Testing:** Automatically tests for direct `Host` replacement, `X-Forwarded-Host` injection, and duplicate header attacks.
* **Smart Parsing:** Cleans input lists by removing protocols and whitespace automatically.
* **Real-time Verification:** Analyzes server response headers for reflection of the malicious host.
* **Lightweight & Fast:** Built in Bash with standard `curl` for maximum compatibility and speed.

</br>
</br>

### Installation

Clone the repository and ensure the script `host_scanner.sh` has execution permissions:

```bash
git clone https://github.com/muhammadtaharana/hhi
cd hhi
chmod +x host_scanner.sh
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
</br>

### Usage Examples

- ###### Scan a list of subdomains
```bash
./host_scanner.sh subdomains.txt
```

- ###### Scan a list of URLs
```bash
./host_scanner.sh urls_file.txt
```

</br>
</br>

### Output Structure

The tool provides color-coded terminal output and saves confirmed vulnerabilities to a log file:

```text
[VULNERABLE] Host reflected in response on target.com!
    -> Via Direct Host Header Replacement
    -> Via X-Forwarded-Host
```

Logs are stored in:
`host_injection_hits.log`

</br>
</br>

> [!TIP]
> **Pro Tip:**
>
> - Use a Burp Collaborator or Interactsh domain as your `EVIL_HOST` in the script for the most accurate out-of-band detection.
> - For large-scale scanning, combine this tool with `subfinder` or `assetfinder`.
> - Check `host_injection_hits.log` after the scan for a consolidated list of targets to manually verify in Burp Suite.

</br>
</br>

### TO-DO

* [ ] Implement support for custom collaborator URLs via flags.
* [ ] Add multi-threading support for faster scanning of large lists.
* [ ] Integrate more obscure headers like `X-Host` and `X-Forwarded-Server`.

</br>
</br>

> [!CAUTION]
> **Use HHI only on assets you own or have explicit permission to test. Unauthorized scanning can be illegal. The authors are not responsible for any misuse or damage caused by this tool.**
