#!/bin/bash

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Banner
show_banner() {
cat << "EOF"

 _    _             _                _   ______   _       _                
| |  | |           | |              | |  |  ___| | |     | |               
| |  | | __ _ _   _| |__   __ _  ___| | _| |_ ___| |_ ___| |__   ___ _ __  
| |/\| |/ _` | | | | '_ \ / _` |/ __| |/ /  _/ _ \ __/ __| '_ \ / _ \ '__| 
\  /\  / (_| | |_| | |_) | (_| | (__|   <| ||  __/ || (__| | | |  __/ |    
 \/  \/ \__,_|\__, |_.__/ \__,_|\___|_|\_\_| \___|\__\___|_| |_|\___|_|    
               __/ |                                                      
              |___/                                                       
     🔎 Wayback URL Fetcher by AIwolfie ⚡
       github.com/AIwolfie | Bash Edition

EOF
}

# Help
show_help() {
  echo -e "\n${CYAN}Usage:${NC} $0 [-d domain.com | -l domains.txt] -o output.txt [-v]"
  echo -e "  ${YELLOW}-d DOMAIN${NC}   Single domain to fetch URLs for"
  echo -e "  ${YELLOW}-l FILE${NC}     File containing list of domains"
  echo -e "  ${YELLOW}-o FILE${NC}     Output file to save results"
  echo -e "  ${YELLOW}-v${NC}          Verbose mode"
  echo -e "  ${YELLOW}-h${NC}          Show help"
}

# Parse args
VERBOSE=0
SINGLE_DOMAIN=""
DOMAIN_LIST=""
OUTPUT_FILE=""

while getopts ":d:l:o:vh" opt; do
  case $opt in
    d) SINGLE_DOMAIN="$OPTARG" ;;
    l) DOMAIN_LIST="$OPTARG" ;;
    o) OUTPUT_FILE="$OPTARG" ;;
    v) VERBOSE=1 ;;
    h) show_help; exit 0 ;;
    \?) echo -e "${RED}[!] Invalid option: -$OPTARG${NC}"; show_help; exit 1 ;;
    :) echo -e "${RED}[!] Option -$OPTARG requires an argument.${NC}"; exit 1 ;;
  esac
done

# Validate args
if [[ -z "$SINGLE_DOMAIN" && -z "$DOMAIN_LIST" ]]; then
  echo -e "${RED}[!] You must specify -d or -l${NC}"
  show_help
  exit 1
fi

if [[ -n "$DOMAIN_LIST" && ! -f "$DOMAIN_LIST" ]]; then
  echo -e "${RED}[!] Domain list file not found: $DOMAIN_LIST${NC}"
  exit 1
fi

if [[ -z "$OUTPUT_FILE" ]]; then
  echo -e "${RED}[!] Output file is required (-o)${NC}"
  exit 1
fi

# Prepare
show_banner
echo -e "\n${BLUE}[i] Starting Wayback URL scan...${NC}"
echo -e "${CYAN}=> Output File:${NC} $OUTPUT_FILE"
[[ $VERBOSE -eq 1 ]] && echo -e "${CYAN}=> Verbose Mode:${NC} ON"
echo ""
start_time=$(date +%s)
> "$OUTPUT_FILE"

# Load domains
if [[ -n "$SINGLE_DOMAIN" ]]; then
  domains=("$SINGLE_DOMAIN")
else
  mapfile -t domains < <(grep . "$DOMAIN_LIST")
fi

total=${#domains[@]}
done_count=0
empty=0

progress_bar() {
  local progress=$1
  local total=$2
  local percent=$(( progress * 100 / total ))
  local filled=$(( percent / 2 ))
  local empty=$(( 50 - filled ))
  local bar=$(printf "%${filled}s" | tr ' ' '█')
  bar+=$(printf "%${empty}s" | tr ' ' '-')
  local elapsed=$(( $(date +%s) - start_time ))
  printf "\r🔄 Progress: [${GREEN}%s${NC}] %s/%s (%s%%) | Time: ${elapsed}s" "$bar" "$progress" "$total" "$percent"
}

# Main loop
for domain in "${domains[@]}"; do
  if ! urls=$(curl -sG --data-urlencode "url=*.$domain/*" \
                       --data-urlencode "collapse=urlkey" \
                       --data-urlencode "output=text" \
                       --data-urlencode "fl=original" \
                       "https://web.archive.org/cdx/search/cdx"); then
    echo -e "${RED}[!] Error fetching for $domain${NC}"
    ((empty++))
    ((done_count++))
    progress_bar "$done_count" "$total"
    continue
  fi

  count=$(echo "$urls" | grep -c . || true)

  if [[ $count -gt 0 ]]; then
    echo "$urls" >> "$OUTPUT_FILE"
    [[ $VERBOSE -eq 1 ]] && echo -e "\n${GREEN}[✔] $domain => $count URL(s) found${NC}"
  else
    [[ $VERBOSE -eq 1 ]] && echo -e "\n${YELLOW}[!] $domain => No URLs found${NC}"
    ((empty++))
  fi

  ((done_count++))
  progress_bar "$done_count" "$total"
done

echo ""

# Deduplicate
sort -u "$OUTPUT_FILE" -o "$OUTPUT_FILE"
unique_count=$(wc -l < "$OUTPUT_FILE")
end_time=$(date +%s)
duration=$((end_time - start_time))
minutes=$((duration / 60))
seconds=$((duration % 60))

# Summary
echo -e "\n\n${CYAN}=========== 🧾 SCAN SUMMARY ===========${NC}"
echo -e "${CYAN}Domains Processed :${NC} $total"
echo -e "${CYAN}Empty Domains     :${NC} $empty"
echo -e "${CYAN}Total Unique URLs :${NC} $unique_count"
echo -e "${CYAN}Time Taken        :${NC} ${minutes}m ${seconds}s"

# Missing domains summary
if [[ $empty -gt 0 && -n "$DOMAIN_LIST" ]]; then
  echo -e "\n${YELLOW}⚠️ No URLs found for:${NC}"
  found_domains=$(cut -d/ -f3 "$OUTPUT_FILE" | sed 's/^www\.//' | sort -u)
  while read -r dom; do
    clean_dom=$(echo "$dom" | tr -d '\r' | sed 's/^www\.//')
    if ! grep -qF "$clean_dom" <<< "$found_domains"; then
      echo -e "  - ${RED}$clean_dom${NC}"
    fi
  done < "$DOMAIN_LIST"
fi

echo -e "\n${GREEN}✅ Done! URLs saved in: $OUTPUT_FILE${NC}"
echo -e "${CYAN}===============================================${NC}"
