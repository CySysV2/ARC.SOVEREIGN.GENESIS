import dns.resolver
import datetime

sites = {
    "digital-fabrica.com": "QmNS8d6pNBB9q1BSTRoFkYuFshgwxRGL5yuC4wcPGH6JFN",
    "blog.digital-fabrica.com": "QmXerw5WcbrD7ckg29zEhYSyiuu58nf1BdyWZ326E5YDvC",
    "civic.digital-fabrica.com": "Qme57DKJ88v9Ufpemb6Cb5Cds7C5CwnPFioKijbjmUsPDF",
    "fabrics.digital-fabrica.com": "QmUwVmNSNB5SJ5bHh1rZX3cgQreBUAs3ZD5b8pqDNQyYFq",
    "whitepaper.digital-fabrica.com": "QmPkY3iHbRLQqJrVFz5k18Br4on3NAeYbKhDbdmEV27j2Q",
    "ip.digital-fabrica.com": "QmfRS373ENWr6yB7nCXPmc6rXrpdu5qc3qDQW4wMW2nsfG",
    "qic.digital-fabrica.com": "QmYvKBRRazxF7X25EsCURU7EkqExT6DrXYt4ErrojG4NcP"
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