import requests

MESH_DOMAINS = [
    "blog.digital-fabrica.com",
    "civic.digital-fabrica.com",
    "fabrics.digital-fabrica.com",
    "whitepaper.digital-fabrica.com",
    "ip.digital-fabrica.com",
    "qic.digital-fabrica.com"
]

ENDPOINTS = [
    "/api/latest_cid.php",
    "/api/update_memcache.php",
    "/cid-banner.html"
]

for domain in MESH_DOMAINS:
    print(f"\n=== Validating {domain} ===")
    for endpoint in ENDPOINTS:
        url = f"https://{domain}{endpoint}"
        try:
            if endpoint.endswith('.php'):
                resp = requests.get(url, timeout=5)
                print(f"[GET] {url} -> {resp.status_code} {resp.text[:100]}")
            else:
                resp = requests.get(url, timeout=5)
                print(f"[GET] {url} -> {resp.status_code} (HTML length: {len(resp.text)})")
        except Exception as e:
            print(f"[ERROR] {url}: {e}")
print("\n[INFO] Endpoint validation complete.") 