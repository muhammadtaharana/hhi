#!/bin/bash

# Usage: ./host_scanner.sh subdomains.txt
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <subdomains_file.txt or urls_file.txt>"
    exit 1
fi

SUBDOMAINS=$1
EVIL_HOST="evil-collaborator.com"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}--- Starting Host Header Injection Scan ---${NC}"
echo -e "Testing for reflection of: ${YELLOW}$EVIL_HOST${NC}\n"

while IFS= read -r domain || [ -n "$domain" ]; do
    # Remove whitespace and protocol if present
    target=$(echo "$domain" | sed -e 's|^[^/]*//||' -e 's|/.*$||')
    
    # Ensure target is not empty
    if [[ -z "$target" ]]; then continue; fi
    
    echo -e "Scanning: ${CYAN}$target${NC}"

    # --- TEST 1: Direct Host Header Replacement ---
    echo -e "  [TESTING] https://$target (Host: $EVIL_HOST)"
    resp1=$(curl -s -L -I -H "Host: $EVIL_HOST" "https://$target" --max-time 5)
    
    # --- TEST 2: X-Forwarded-Host Injection ---
    echo -e "  [TESTING] https://$target (X-Forwarded-Host: $EVIL_HOST)"
    resp2=$(curl -s -L -I -H "X-Forwarded-Host: $EVIL_HOST" "https://$target" --max-time 5)

    # --- TEST 3: Duplicate Host Headers ---
    echo -e "  [TESTING] https://$target (Dual Host: $target & $EVIL_HOST)"
    resp3=$(curl -s -L -I -H "Host: $target" -H "Host: $EVIL_HOST" "https://$target" --max-time 5)

    # Verification Logic
    if echo "$resp1 $resp2 $resp3" | grep -qi "$EVIL_HOST"; then
        echo -e "  [${RED}VULNERABLE${NC}] Host reflected in response on $target!"
        
        # Determine which header caused the reflection
        if echo "$resp1" | grep -qi "$EVIL_HOST"; then echo "    -> Via Direct Host Header Replacement"; fi
        if echo "$resp2" | grep -qi "$EVIL_HOST"; then echo "    -> Via X-Forwarded-Host"; fi
        if echo "$resp3" | grep -qi "$EVIL_HOST"; then echo "    -> Via Duplicate Host Headers"; fi
        
        echo "$target" >> host_injection_hits.log
    else
        echo -e "  [${GREEN}SECURE${NC}] No reflection detected."
    fi

done < "$SUBDOMAINS"

echo -e "\n${GREEN}Scan Complete. Findings saved to host_injection_hits.log${NC}"
