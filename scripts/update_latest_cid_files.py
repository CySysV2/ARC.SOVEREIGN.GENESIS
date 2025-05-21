from pathlib import Path

# Map mesh domains to placeholder CIDs (replace with real CIDs as needed)
DOMAIN_CIDS = {
    "blog.digital-fabrica.com": "QmBLOGCID123",
    "civic.digital-fabrica.com": "QmCIVICCID456",
    "fabrics.digital-fabrica.com": "QmFABRICSCID789",
    "whitepaper.digital-fabrica.com": "QmWHITEPAPERCID321",
    "ip.digital-fabrica.com": "QmIPCID654",
    "qic.digital-fabrica.com": "QmQICCID987"
}

WORKSPACE = Path.cwd()

for domain, cid in DOMAIN_CIDS.items():
    latest_cid_path = WORKSPACE / domain / "latest.cid"
    latest_cid_path.write_text(cid + "\n", encoding="utf-8")
    print(f"[OK] Updated {latest_cid_path} with CID {cid}")
print("[INFO] All latest.cid files updated.") 