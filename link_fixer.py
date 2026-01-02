import sys
import os

def clean_and_build_urls(input_file, base_url, output_file):
    if not os.path.exists(input_file):
        print(f"[-] Error: File '{input_file}' not found!")
        return

    if not base_url.startswith(('http://', 'https://')):
        base_url = 'https://' + base_url
        print(f"[*] Prepending 'https://' to base URL: {base_url}")

    try:
        with open(input_file, 'r', encoding='utf-8') as f:
            lines = f.readlines()
    except Exception as e:
        print(f"[-] Error reading file: {e}")
        return

    full_urls = set()
    for line in lines:
        path = line.strip()
        if not path: continue
        
        if path.startswith('./'):
            path = path[2:]
        elif path.startswith('/'):
            path = path[1:]
        
        full_url = f"{base_url.rstrip('/')}/{path}"
        full_urls.add(full_url)

    with open(output_file, 'w', encoding='utf-8') as f:
        for url in sorted(full_urls):
            f.write(url + '\n')

    print("-" * 40)
    print(f"[+] Processed {len(lines)} paths.")
    print(f"[+] Generated {len(full_urls)} unique URLs.")
    print(f"[+] Output saved to: {output_file}")
    print("-" * 40)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("\n[!] Missing Arguments!")
        print("Usage: python3 link_fixer.py <base_url> <input_file>")
        print("Example: python3 link_fixer.py www.example.com ~/paths\n")
        sys.exit(1)

    target_base = sys.argv[1]
    target_file = sys.argv[2]
    target_out = "full_urls.txt"

    clean_and_build_urls(target_file, target_base, target_out)