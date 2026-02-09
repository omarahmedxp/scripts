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
rm -f naabu_out.txt live_urls.txt
touch naabu_out.txt live_urls.txt

echo -e "${BLUE}[+] Starting Recon on: $DOMAIN${NC}"

echo -e "${GREEN}[*] Running Subfinder...${NC}"
subfinder -d $DOMAIN -all -recursive -silent -o subfinder_subs.txt

echo -e "${GREEN}[*] Running Assetfinder...${NC}"
assetfinder --subs-only $DOMAIN | grep "$DOMAIN" >> assetfinder_subs.txt

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


httpx -l naabu_out.txt -mc 200,301,302,403,404 -silent -sc -cl -td -title -random-agent -o httpx_all.txt

grep "\[200\]" httpx_all.txt > 200.txt
grep "\[403\]" httpx_all.txt > 403.txt
awk '{print $1}' 200.txt > nuclei_targets.txt

if [ -s nuclei_targets.txt ]; then
    echo -e "${GREEN}[*] Running Nuclei on 200 OK targets...${NC}"
    nuclei -l nuclei_targets.txt -t ~/Pixelated-Nuclei-Templates/ -silent -o nuclei_results.txt
else
    echo -e "${RED}[!] No 200 OK targets found for Nuclei.${NC}"
fi

echo -e "${BLUE}[+] Recon Finished!${NC}"
echo -e "${GREEN}[*] Total 200 OK found: $(wc -l < 200.txt)${NC}"
echo -e "${RED}[*] Total 403 Forbidden found: $(wc -l < 403.txt)${NC}"
echo -e "${BLUE}[+] Results saved in: ~/bugbounty/$DOMAIN${NC}"
