#!/bin/bash

#===========================================================
# 🕸️ Wayback URL Fetcher 
# Author : Mayank Malaviya (aka AIwolfie)
# GitHub : github.com/AIwolfie
# Version: 1.2
#===========================================================

set -e

RED='\033[0;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[0;36m'
NC='\033[0m'

show_banner() {
cat << "EOF"
 __        __   _ _        _               _     
 \ \      / /__| | | _____| |__   __ _ ___| |__  
  \ \ /\ / / _ \ | |/ / _ \ '_ \ / _` / __| '_ \ 
   \ V  V /  __/ |   <  __/ |_) | (_| \__ \ | | |
    \_/\_/ \___|_|_|\_\___|_.__/ \__,_|___/_| |_| v1.2

       🔎 Wayback URL Fetcher by AIwolfie ⚡
         github.com/AIwolfie | Bash Edition
EOF
}

show_help() {
  echo -e "\n${CYAN}Usage:${NC} $0 -l domains.txt -o output.txt [-v]"
  echo -e "  ${YELLOW}-l FILE${NC}    File containing domain list (required)"
  echo -e "  ${YELLOW}-o FILE${NC}    Output file to save all URLs (required)"
  echo -e "  ${YELLOW}-v${NC}         Verbose mode (optional)"
  echo -e "  ${YELLOW}-h${NC}         Show help menu"
}

# Parse args
VERBOSE=0
while getopts ":l:o:vh" opt; do
  case $opt in
    l) DOMAIN_LIST="$OPTARG" ;;
    o) OUTPUT_FILE="$OPTARG" ;;
    v) VERBOSE=1 ;;
    h) show_help; exit 0 ;;
    \?) echo -e "${RED}[!] Invalid option: -$OPTARG${NC}"; show_help; exit 1 ;;
    :) echo -e "${RED}[!] Option -$OPTARG requires an argument.${NC}"; exit 1 ;;
  esac
done

[[ -z "$DOMAIN_LIST" || -z "$OUTPUT_FILE" ]] && show_help && exit 1
[[ ! -f "$DOMAIN_LIST" ]] && echo -e "${RED}[!] File not found: $DOMAIN_LIST${NC}" && exit 1

# Banner
show_banner
echo -e "\n${BLUE}[i] Starting Wayback scan...${NC}"
echo -e "${CYAN}=> Input File :${NC} $DOMAIN_LIST"
echo -e "${CYAN}=> Output File:${NC} $OUTPUT_FILE"
[[ $VERBOSE -eq 1 ]] && echo -e "${CYAN}=> Verbose Mode:${NC} ON"
echo ""

start_time=$(date +%s)
> "$OUTPUT_FILE"

# Read domains
mapfile -t domains < <(grep . "$DOMAIN_LIST")
total=${#domains[@]}
empty=0
done_count=0

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
  urls=$(curl -sG --data-urlencode "url=*.$domain/*" \
                  --data-urlencode "collapse=urlkey" \
                  --data-urlencode "output=text" \
                  --data-urlencode "fl=original" \
                  "https://web.archive.org/cdx/search/cdx")

  count=$(echo "$urls" | grep -c . || true)

  if [[ $count -gt 0 ]]; then
    echo "$urls" >> "$OUTPUT_FILE"
    [[ $VERBOSE -eq 1 ]] && echo -e "\n${GREEN}[✔] $domain => $count URL(s) found${NC}"
  else
    ((empty++))
    [[ $VERBOSE -eq 1 ]] && echo -e "\n${YELLOW}[!] $domain => No URLs found${NC}"
  fi

  ((done_count++))
  progress_bar "$done_count" "$total"
done

# Finish bar
echo ""

# Deduplicate + sort
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

if [[ $empty -gt 0 ]]; then
  echo -e "\n${YELLOW}⚠️ No URLs found for:${NC}"
  grep -vFx -f <(cut -d/ -f3 "$OUTPUT_FILE" | sed 's/^www\.//') "$DOMAIN_LIST" | while read -r d; do
    echo -e "  - ${RED}$d${NC}"
  done
fi

echo -e "\n${GREEN}✅ Done! URLs saved in: $OUTPUT_FILE${NC}"
echo -e "${CYAN}===============================================${NC}"
