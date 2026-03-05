#!/bin/bash


if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <username> <password_file>"
    exit 1
fi

username="$1"

input_file="$2"

output_file="$1.txt"

if [[ ! -f "$input_file" ]]; then
    echo "Error: File '$input_file' not found!"
    exit 1
fi

> "$output_file"

echo "[*] Encoding passwords for user: $username ..."

while IFS= read -r pass; do
    [[ -z "$pass" ]] && continue
    encoded=$(printf "%s:%s" "$username" "$pass" | base64 | tr -d '\n')
    echo "$encoded" >> "$output_file"
done < "$input_file"

echo "[+] Done! Encoded list saved in: $output_file"
echo "[+] Total encoded credentials: $(wc -l < "$output_file")"