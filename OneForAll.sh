#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

DOMAIN=$1

if [ -z "$DOMAIN" ]; then
    echo -e "${RED}Usage: ./OneForAll.sh example.com${NC}"
    exit 1
fi

mkdir -p ~/bugbounty/$DOMAIN
cd ~/bugbounty/$DOMAIN
rm -f naabu_out.txt live_urls.txt nuclei_results.txt
touch naabu_out.txt live_urls.txt nuclei_results.txt

echo -e "${BLUE}[+] Starting Recon on: $DOMAIN${NC}"

echo -e "${GREEN}[*] Running Subfinder...${NC}"
subfinder -d $DOMAIN -all -recursive -silent -o subfinder_subs.txt

echo -e "${GREEN}[*] Running Assetfinder...${NC}"
assetfinder --subs-only $DOMAIN >> assetfinder_subs.txt

echo -e "${GREEN}[*] Merging and cleaning subdomains...${NC}"
cat subfinder_subs.txt assetfinder_subs.txt | sort -u > all_subs.txt
rm subfinder_subs.txt assetfinder_subs.txt
echo -e "${BLUE}[+] Total subdomains found: $(wc -l < all_subs.txt)${NC}"

echo -e "${GREEN}[*] Filtering live DNS with dnsx...${NC}"
cat all_subs.txt | dnsx -silent -a -resp -o dnsx_full_info.txt
cat dnsx_full_info.txt | awk '{print $1}' | sort -u > live_subs.txt
cat dnsx_full_info.txt | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | sort -u > unique_ips.txt
echo -e "${BLUE}[+] Live subdomains: $(wc -l < live_subs.txt)${NC}"

echo -e "${GREEN}[*] Running Naabu Port Scan...${NC}"
naabu -list live_subs.txt -c 50 -top-ports 1000 -silent -o naabu_out.txt

echo -e "${GREEN}[*] Probing with httpx...${NC}"

cat naabu_out.txt | httpx -mc 200,301,302,403,404 -silent -status-code -random-agent -title -td -o live_urls.txt

echo -e "${BLUE}[+] Recon Finished! Check the folder: ~/bugbounty/$DOMAIN${NC}"
