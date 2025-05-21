import os
import datetime
import json
import requests

STACK_ROOT = "C:/DFT_GCC_TRIAD_MAINSTACK"
SITE_LIST = [
    "digital-fabrica.com",
    "blog.digital-fabrica.com",
    "whitepaper.digital-fabrica.com",
    "civic.digital-fabrica.com",
    "qic.digital-fabrica.com",
    "media.digital-fabrica.com",
    "ip.digital-fabrica.com",
    "monad.digital-fabrica.com",
    "tc.digital-fabrica.com",
    "ikl.digital-fabrica.com",
    "gilc.digital-fabrica.com"
]

LOG_PATH = os.path.join(STACK_ROOT, "logs", "zkTrail.log")


def log_event(event):
    timestamp = datetime.datetime.now(datetime.UTC).isoformat()
    with open(LOG_PATH, 'a', encoding='utf-8') as f:
        f.write(f"[{timestamp}] {event}\n")


def validate_site(domain):
    base_url = f"https://{domain}"
    pages = ["", "cid-banner.html"]
    results = {}
    for page in pages:
        url = f"{base_url}/{page}"
        try:
            r = requests.get(url, timeout=10)
            results[page or "index"] = r.status_code
        except Exception as e:
            results[page or "index"] = str(e)
    return results


def run_validation():
    all_results = {}
    for domain in SITE_LIST:
        print(f"🔍 Validating {domain}...")
        res = validate_site(domain)
        all_results[domain] = res
        log_event(f"Validated {domain} → {res}")
    # Write validation report
    report_path = os.path.join(STACK_ROOT, "Bridge", "Registry", "epoch", "ΣΩΩ.5.4", "endpoint_validation_report.json")
    os.makedirs(os.path.dirname(report_path), exist_ok=True)
    with open(report_path, 'w', encoding='utf-8') as f:
        json.dump(all_results, f, indent=2)
    print("\n✅ All mesh endpoints validated and logged.")
    log_event("ΣΩΩ.5.4 Mesh Endpoint Validation Complete")


if __name__ == "__main__":
    print("\n✨ Executing Final Mesh Validation Cascade — Epoch ΣΩΩ.5.4")
    run_validation() 