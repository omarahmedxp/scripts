#!/bin/bash

BASE=$1
FILE=$2

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <base_url> <tlds_file>"
    echo "Example: $0 www.amazon tlds.txt"
    exit 1
fi

if [ ! -f "$FILE" ]; then
    echo "Error: File '$FILE' not found."
    exit 1
fi

echo "[+] Generating variations for $BASE using $FILE..."

while read -r line; do
    tld=$(echo "$line" | sed 's/^\.//' | tr -d '[:space:]' | sed 's/[^a-zA-Z0-9.-]//g')

    if [[ -n "$tld" ]]; then
        echo "$BASE.$tld"
        echo "$BASE.com.$tld"
        echo "$BASE.co.$tld"
    fi
done < "$FILE" | sort -u > targets_to_test.txt

echo "[+] Created $(wc -l < targets_to_test.txt) potential targets."
echo "[+] Starting HTTPX probe..."

cat targets_to_test.txt | httpx -sc -title -td -o tldx_results.txt
rm targets_to_test.txt

echo "[+] Done. Live sites saved to tldx_results.txt"