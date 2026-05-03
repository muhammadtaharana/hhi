# Changelog

All notable changes to the Host Header Injector (HHI) project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] - 2026-05-03

### Added

#### CLI Arguments & Configuration
- Added `-h, --host` flag to specify custom evil domain (default: `evil-collaborator.com`)
- Added `-t, --timeout` flag to configure curl request timeout in seconds (default: `5`)
- Added `-o, --output` flag to specify custom output log file (default: `host_injection_hits.log`)
- Added `-f, --format` flag to select output format: `text` or `json` (default: `text`)
- Added `-v, --verbose` flag to enable detailed verbose output for debugging
- Added `--help` flag to display comprehensive usage documentation

#### Output Formats
- **JSON Output Format**: Structured JSON with scan metadata and per-target results
  - Includes timestamp, evil_host, timeout, targets_scanned, vulnerable_targets
  - Per-target results with individual test vector outcomes
  - Proper JSON formatting for automation and CI/CD integration
- **Enhanced Text Output**: Improved readability with color-coded results and summary statistics

#### Error Handling & Validation
- Input file existence validation
- Input file readability validation
- Timeout value validation (must be positive integer)
- Output format validation (text or json only)
- Evil host validation (cannot be empty)
- curl installation check with helpful error message
- Output file writeability check
- Clear error messages sent to stderr with [ERROR] prefix
- Graceful exit with proper status codes

#### Code Improvements
- Refactored into modular functions:
  - `show_banner()` - Display Nuclei-style banner
  - `show_help()` - Display help documentation
  - `parse_arguments()` - Handle CLI argument parsing
  - `validate_inputs()` - Comprehensive input validation
  - `test_domain()` - Isolated vulnerability testing logic
  - `output_text()` - Text format output
  - `add_json_result()` - JSON result collection
  - `write_json_output()` - JSON file output
  - `main()` - Main orchestration function
- Added comprehensive code comments and documentation
- Improved error handling with descriptive error messages
- Added support for empty line and comment skipping in input files

#### Visual & Branding
- Added Nuclei-style ASCII art banner in CYAN color
- Added author attribution: `@MuhammadTahaRana` (bottom left of banner)
- Added version badge: `v1` in RED color (bottom right of banner)
- Improved terminal output with color coding and formatting
- Added summary statistics display (targets scanned, vulnerable found)

#### Documentation
- Updated README.md with comprehensive documentation
  - New Features section
  - CLI Options table
  - Multiple usage examples for each flag
  - Output format examples (text and JSON)
  - Error handling documentation
  - Pro tips section
  - Requirements and compatibility information
  - Version history
  - TO-DO for Phase 2 & 3
- Created CHANGELOG.md

### Changed

- Restructured codebase from procedural to modular function-based architecture
- Enhanced argument validation with detailed error messages
- Improved test result logging with per-vector indication
- Modified default behavior to require input file argument (more explicit)
- Updated output format to include detailed scan metadata
- Enhanced color coding for better terminal readability

### Improved

- Code readability and maintainability
- Error messages clarity and actionability
- Input validation comprehensiveness
- Documentation completeness
- User experience with helpful feedback

### Fixed

- Line ending handling for files with various line terminators
- Whitespace trimming in domain parsing
- Empty line handling in input files
- Protocol stripping more robust

### Backward Compatibility

- ✅ Basic usage still works: `./hhi.sh subdomains.txt`
- ✅ All new flags are optional with sensible defaults
- ✅ Text output format is default (matches original behavior)

---

## [0.1.0] - Initial Release

### Added

#### Core Features
- Multi-vector Host Header Injection vulnerability testing
  - Direct Host header replacement test
  - X-Forwarded-Host header injection test
  - Dual/conflicting Host headers test
- Smart domain parsing
  - Automatic protocol removal (http://, https://)
  - Path component removal
  - Whitespace trimming
- Response reflection verification
  - Case-insensitive matching with grep
  - Support for various response formats
- Color-coded terminal output
  - RED for vulnerable findings
  - GREEN for secure results
  - YELLOW for test information
  - CYAN for status messages
- Log file output
  - Saves vulnerable targets to `host_injection_hits.log`
  - One target per line for easy parsing

#### Documentation
- README.md with feature overview
- Technical logic explanation
- Usage examples
- Output structure documentation
- Pro tips for Burp Suite integration
- Security/legal disclaimer

#### Requirements
- bash (v4.0+)
- curl
- Standard Unix tools (sed, grep)

---

## [Unreleased]

### Planned for Phase 2

- [ ] Multi-threading support for faster large-scale scanning
- [ ] Custom collaborator URLs via environment variables
- [ ] Additional injection vectors:
  - [ ] X-Host header
  - [ ] X-Forwarded-Server header
  - [ ] X-Forwarded-Proto header
  - [ ] X-Original-Host header
  - [ ] Referer header injection
  - [ ] Origin header injection
- [ ] Response body analysis (not just headers)
- [ ] Partial/encoded reflection detection
- [ ] Case variation testing
- [ ] Redirect location checking
- [ ] Cookie domain verification
- [ ] CSV export format
- [ ] HTML report generation

### Planned for Phase 3

- [ ] Proxy support (`--proxy` flag)
- [ ] Custom headers support (`--header` flag)
- [ ] Authentication support (Basic, Bearer)
- [ ] SSL verification toggle (`--insecure` flag)
- [ ] HTTP/2 specific testing
- [ ] Custom User-Agent option
- [ ] Cookie handling
- [ ] HTTP method variations (GET, POST, HEAD, OPTIONS)
- [ ] Port specification in Host header
- [ ] IPv6 format testing
- [ ] Environment variable support for configuration
- [ ] Configuration file support (`.hhirc`)
- [ ] Slack webhook notifications
- [ ] Email report generation
- [ ] Jira ticket integration
- [ ] Database result storage

---

## Version Guide

### How to Use This Changelog

- **Added**: for new features
- **Changed**: for changes in existing functionality
- **Fixed**: for any bug fixes
- **Removed**: for now removed features
- **Deprecated**: for soon-to-be removed features
- **Security**: in case of security vulnerabilities
- **Improved**: for improvements to existing features

### Semantic Versioning

- **MAJOR** version for incompatible API changes
- **MINOR** version for backwards-compatible functionality additions
- **PATCH** version for backwards-compatible bug fixes

---

## Compatibility Matrix

| Version | Bash | curl | Status |
|---------|------|------|--------|
| 1.0.0 | 4.0+ | any | ✅ Stable |
| 0.1.0 | 4.0+ | any | ⚠️ Deprecated |

---

## Author & Attribution

**Author**: @MuhammadTahaRana  
**License**: MIT (or your choice)

---

*Last Updated: 2026-05-03*
