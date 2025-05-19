import dns.resolver
import datetime

sites = {
    "digital-fabrica.com": "QmMainCID20250519",
    "blog.digital-fabrica.com": "QmBlogCID20250519",
    "civic.digital-fabrica.com": "QmCivicCID20250519",
    "fabrics.digital-fabrica.com": "QmFabricsCID20250519",
    "whitepaper.digital-fabrica.com": "QmWhitepaperCID20250519",
    "media.digital-fabrica.com": "QmMediaCID20250519",
    "qic.digital-fabrica.com": "QmQicCID20250519",
    "monad.digital-fabrica.com": "QmMonadCID20250519",
    "tc.digital-fabrica.com": "QmTangraChainCID20250519",
    "ikl.digital-fabrica.com": "QmIKLCID20250519"
}

timestamp = datetime.datetime.utcnow().isoformat() + "Z"
results = []

for domain, expected_cid in sites.items():
    try:
        answers = dns.resolver.resolve(f"_dnslink.{domain}", 'TXT')
        found = False
        for rdata in answers:
            record = str(rdata).strip('"')
            if expected_cid in record:
                print(f"✅ {domain} → OK: {record}")
                results.append(f"{domain}:OK:{record}")
                found = True
            else:
                print(f"⚠️  {domain} → CID MISMATCH: {record} ≠ {expected_cid}")
                results.append(f"{domain}:MISMATCH:{record}")
        if not found:
            print(f"⚠️  {domain} → CID NOT FOUND in any TXT record")
            results.append(f"{domain}:NOT_FOUND")
    except Exception as e:
        print(f"❌ {domain} → DNS Lookup Failed: {e}")
        results.append(f"{domain}:FAIL:{e}")

# Log the results to zkTrail.log
with open("logs/zkTrail.log", "a", encoding="utf-8") as log:
    log.write(f"ΣΩΩ.5.0::DNS_VERIFY::{timestamp}::" + "|".join(results) + "\n") 