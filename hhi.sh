#!/bin/bash

# ============================================================================
# Host Header Injector (HHI) - Phase 1 Enhanced
# Detects Host Header Injection vulnerabilities with CLI flags and JSON output
# ============================================================================

# Banner with attribution
show_banner() {
    echo -e "\033[0;36m"
    cat << "EOF"
    __  __           __  ____        _           __            
   / / / /___  _____/ /_/  _____    (_)__  _____/ /_____  _____
  / /_/ / __ \/ ___/ __// // __ \  / / _ \/ ___/ __/ __ \/ ___/
 / __  / /_/ (__  ) /__/ // / / / / /  __/ /__/ /_/ /_/ / /    
/_/ /_/\____/____/\__/___/_/ /_/_/ /\___/\___/\__/\____/_/     
                              /___/                            
EOF
    printf "@MuhammadTahaRana                              $(echo -e '\033[0;31m')v1\033[0;36m\n"
    echo -e "\033[0m"
}

# Default configuration
EVIL_HOST="evil-collaborator.com"
TIMEOUT=5
OUTPUT_FILE="host_injection_hits.log"
OUTPUT_FORMAT="text"
VERBOSE=false
SUBDOMAINS=""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Help message
show_help() {
    cat << 'EOF'
Usage: hhi [OPTIONS] <subdomains_file>

OPTIONS:
  -h, --host HOST           Custom evil host to inject (default: evil-collaborator.com)
  -t, --timeout SECONDS     Timeout for curl requests in seconds (default: 5)
  -o, --output FILE         Output log file (default: host_injection_hits.log)
  -f, --format FORMAT       Output format: text or json (default: text)
  -v, --verbose             Enable verbose output for debugging
  --help                    Display this help message

EXAMPLES:
  hhi subdomains.txt
  hhi --host attacker.com subdomains.txt
  hhi --timeout 10 --output results.log subdomains.txt
  hhi --format json -o results.json subdomains.txt
  hhi -h collaborator.oastify.com -f json -v subdomains.txt

EOF
}

# Error handling function
error_exit() {
    echo -e "${RED}[ERROR] $1${NC}" >&2
    exit 1
}

# Parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--host)
                EVIL_HOST="$2"
                shift 2
                ;;
            -t|--timeout)
                TIMEOUT="$2"
                shift 2
                ;;
            -o|--output)
                OUTPUT_FILE="$2"
                shift 2
                ;;
            -f|--format)
                OUTPUT_FORMAT="$2"
                shift 2
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            --help)
                show_help
                exit 0
                ;;
            -*)
                error_exit "Unknown option: $1"
                ;;
            *)
                SUBDOMAINS="$1"
                shift
                ;;
        esac
    done
}

# Validate all inputs and configuration
validate_inputs() {
    # Check if input file is provided
    if [[ -z "$SUBDOMAINS" ]]; then
        echo -e "${RED}[ERROR] No input file specified${NC}"
        show_help
        exit 1
    fi

    # Check if input file exists
    if [[ ! -f "$SUBDOMAINS" ]]; then
        error_exit "Input file not found: $SUBDOMAINS"
    fi

    # Check if file is readable
    if [[ ! -r "$SUBDOMAINS" ]]; then
        error_exit "Input file is not readable: $SUBDOMAINS"
    fi

    # Validate timeout is a positive number
    if ! [[ "$TIMEOUT" =~ ^[0-9]+$ ]] || [[ "$TIMEOUT" -le 0 ]]; then
        error_exit "Invalid timeout value: $TIMEOUT (must be a positive number)"
    fi

    # Validate output format
    if [[ "$OUTPUT_FORMAT" != "text" && "$OUTPUT_FORMAT" != "json" ]]; then
        error_exit "Invalid output format: $OUTPUT_FORMAT (must be 'text' or 'json')"
    fi

    # Validate evil host is not empty
    if [[ -z "$EVIL_HOST" ]]; then
        error_exit "Evil host cannot be empty"
    fi

    # Check if curl is available
    if ! command -v curl &> /dev/null; then
        error_exit "curl is not installed or not in PATH"
    fi

    # Warn if output file is not writable
    if [[ -f "$OUTPUT_FILE" && ! -w "$OUTPUT_FILE" ]]; then
        error_exit "Output file is not writable: $OUTPUT_FILE"
    fi
}

# Test single domain for vulnerability
test_domain() {
    local target="$1"

    if [[ "$VERBOSE" == "true" ]]; then
        echo -e "${CYAN}[VERBOSE] Testing target: $target${NC}" >&2
    fi

    # Test 1: Direct Host Header Replacement
    if [[ "$VERBOSE" == "true" ]]; then
        echo -e "${CYAN}[VERBOSE]   → Test 1: Direct Host Header${NC}" >&2
    fi
    resp1=$(curl -s -L -I -H "Host: $EVIL_HOST" "https://$target" --max-time "$TIMEOUT" 2>/dev/null)
    test1=false
    if echo "$resp1" | grep -qi "$EVIL_HOST"; then
        test1=true
    fi

    # Test 2: X-Forwarded-Host Header Injection
    if [[ "$VERBOSE" == "true" ]]; then
        echo -e "${CYAN}[VERBOSE]   → Test 2: X-Forwarded-Host Header${NC}" >&2
    fi
    resp2=$(curl -s -L -I -H "X-Forwarded-Host: $EVIL_HOST" "https://$target" --max-time "$TIMEOUT" 2>/dev/null)
    test2=false
    if echo "$resp2" | grep -qi "$EVIL_HOST"; then
        test2=true
    fi

    # Test 3: Dual Host Headers
    if [[ "$VERBOSE" == "true" ]]; then
        echo -e "${CYAN}[VERBOSE]   → Test 3: Dual Host Headers${NC}" >&2
    fi
    resp3=$(curl -s -L -I -H "Host: $target" -H "Host: $EVIL_HOST" "https://$target" --max-time "$TIMEOUT" 2>/dev/null)
    test3=false
    if echo "$resp3" | grep -qi "$EVIL_HOST"; then
        test3=true
    fi

    # Determine if vulnerable
    if [[ "$test1" == "true" ]] || [[ "$test2" == "true" ]] || [[ "$test3" == "true" ]]; then
        echo "true|$target|$test1|$test2|$test3"
    else
        echo "false|$target|$test1|$test2|$test3"
    fi
}

# Output result in text format
output_text() {
    local vulnerable=$1
    local target=$2
    local test1=$3
    local test2=$4
    local test3=$5

    if [[ "$vulnerable" == "true" ]]; then
        echo -e "${RED}[VULNERABLE]${NC} $target"
        [[ "$test1" == "true" ]] && echo -e "  ${YELLOW}→ Direct Host Header Replacement${NC}"
        [[ "$test2" == "true" ]] && echo -e "  ${YELLOW}→ X-Forwarded-Host Header${NC}"
        [[ "$test3" == "true" ]] && echo -e "  ${YELLOW}→ Dual Host Headers${NC}"
        echo "$target" >> "$OUTPUT_FILE"
    else
        echo -e "${GREEN}[SECURE]${NC} $target"
    fi
}

# Add JSON result to array
json_results=()
add_json_result() {
    local vulnerable=$1
    local target=$2
    local test1=$3
    local test2=$4
    local test3=$5

    local json_entry="{\"target\":\"$target\",\"vulnerable\":$vulnerable,\"vectors\":{\"direct_host\":$test1,\"x_forwarded_host\":$test2,\"dual_headers\":$test3}}"
    json_results+=("$json_entry")
}

# Write JSON results to file
write_json_output() {
    {
        echo "{"
        echo "  \"scan_info\": {"
        echo "    \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\","
        echo "    \"evil_host\": \"$EVIL_HOST\","
        echo "    \"timeout_seconds\": $TIMEOUT,"
        echo "    \"targets_scanned\": $TARGETS_SCANNED,"
        echo "    \"vulnerable_targets\": $VULNERABLE_COUNT"
        echo "  },"
        echo "  \"results\": ["
        for i in "${!json_results[@]}"; do
            echo -n "    ${json_results[$i]}"
            if [[ $i -lt $((${#json_results[@]} - 1)) ]]; then
                echo ","
            else
                echo ""
            fi
        done
        echo "  ]"
        echo "}"
    } > "$OUTPUT_FILE"
}

# Main scan function
main() {
    parse_arguments "$@"
    validate_inputs

    show_banner

    echo -e "${CYAN}--- Starting Host Header Injection Scan ---${NC}"
    echo -e "Evil Host:   ${YELLOW}$EVIL_HOST${NC}"
    echo -e "Timeout:     ${YELLOW}${TIMEOUT}s${NC}"
    echo -e "Format:      ${YELLOW}$OUTPUT_FORMAT${NC}"
    echo -e "Output File: ${YELLOW}$OUTPUT_FILE${NC}"
    echo -e "Verbose:     ${YELLOW}$VERBOSE${NC}\n"

    # Clear output file for text format
    if [[ "$OUTPUT_FORMAT" == "text" ]]; then
        > "$OUTPUT_FILE"
    fi

    TARGETS_SCANNED=0
    VULNERABLE_COUNT=0

    # Process each line in input file
    while IFS= read -r domain || [[ -n "$domain" ]]; do
        # Skip empty lines
        [[ -z "$domain" ]] && continue
        
        # Skip comment lines
        [[ "$domain" =~ ^# ]] && continue

        # Parse domain (remove protocol and path)
        target=$(echo "$domain" | sed -e 's|^[^/]*//||' -e 's|/.*$||' | xargs)

        # Skip if empty after parsing
        if [[ -z "$target" ]]; then
            continue
        fi

        ((TARGETS_SCANNED++))

        # Test the domain
        result=$(test_domain "$target")
        IFS='|' read -r vuln tgt t1 t2 t3 <<< "$result"

        # Process results
        if [[ "$OUTPUT_FORMAT" == "text" ]]; then
            output_text "$vuln" "$tgt" "$t1" "$t2" "$t3"
        else
            add_json_result "$vuln" "$tgt" "$t1" "$t2" "$t3"
        fi

        if [[ "$vuln" == "true" ]]; then
            ((VULNERABLE_COUNT++))
        fi

    done < "$SUBDOMAINS"

    # Write JSON output if format is JSON
    if [[ "$OUTPUT_FORMAT" == "json" ]]; then
        write_json_output
    fi

    # Print summary
    echo ""
    echo -e "${GREEN}════════════════════════════════════════${NC}"
    echo -e "${GREEN}Scan Complete!${NC}"
    echo -e "${CYAN}Targets Scanned:${NC}     $TARGETS_SCANNED"
    echo -e "${RED}Vulnerable Found:${NC}    $VULNERABLE_COUNT"
    echo -e "${YELLOW}Results saved to:${NC}    $OUTPUT_FILE"
    echo -e "${GREEN}════════════════════════════════════════${NC}"
}

# Execute main function with all arguments
main "$@"
