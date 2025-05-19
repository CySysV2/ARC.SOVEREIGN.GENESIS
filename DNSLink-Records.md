# DNSLink TXT Records — Epoch ΣΩΩ.5.0++

```
_dnslink.digital-fabrica.com            TXT "dnslink=/ipfs/QmMainCID20250519"
_dnslink.blog.digital-fabrica.com       TXT "dnslink=/ipfs/QmBlogCID20250519"
_dnslink.civic.digital-fabrica.com      TXT "dnslink=/ipfs/QmCivicCID20250519"
_dnslink.fabrics.digital-fabrica.com    TXT "dnslink=/ipfs/QmFabricsCID20250519"
_dnslink.whitepaper.digital-fabrica.com TXT "dnslink=/ipfs/QmWhitepaperCID20250519"
_dnslink.media.digital-fabrica.com      TXT "dnslink=/ipfs/QmMediaCID20250519"
_dnslink.qic.digital-fabrica.com        TXT "dnslink=/ipfs/QmQicCID20250519"
_dnslink.monad.digital-fabrica.com      TXT "dnslink=/ipfs/QmMonadCID20250519"
_dnslink.tc.digital-fabrica.com         TXT "dnslink=/ipfs/QmTangraChainCID20250519"
_dnslink.ikl.digital-fabrica.com        TXT "dnslink=/ipfs/QmIKLCID20250519"
```

> Apply these records via cPanel or your DNS provider for global mesh propagation.

---

**Instructions:**
1. In cPanel, set each subdomain's document root to its dedicated folder (e.g., /blog.digital-fabrica.com).
2. Add a TXT record for each subdomain as shown above.
3. Wait for DNS propagation (may take up to 24-48 hours).
4. Verify with `nslookup` or the provided Python script.

**Example Verification Command:**
```sh
nslookup -type=TXT _dnslink.ip.digital-fabrica.com
```

---

*This file is auto-generated as part of the Digital Fabrica quantum orchestration documentation.* 