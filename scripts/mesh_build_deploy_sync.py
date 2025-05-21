import os
import subprocess
import shutil
from pathlib import Path

# Map mesh domains to their actual VitePress build output paths
MESH_DOMAIN_PATHS = {
    "digital-fabrica.com": "web-projects/digital-fabrica.com/src/pages/.vitepress/dist",
    "ip.digital-fabrica.com": "sites/ip.digital-fabrica.com/.vitepress/dist",
    "qic.digital-fabrica.com": "sites/qic.digital-fabrica.com/.vitepress/dist",
    "civic.digital-fabrica.com": "sites/civic/.vitepress/dist",
    "fabrics.digital-fabrica.com": "sites/fabrics/.vitepress/dist",
    "blog.digital-fabrica.com": "sites/blog/.vitepress/dist",
    "whitepaper.digital-fabrica.com": "sites/whitepaper/.vitepress/dist",
    "monad.digital-fabrica.com": "sites/monad.digital-fabrica.com/.vitepress/dist"
    # Add more as needed
}

WORKSPACE = Path.cwd()
DEPLOY_ROOT = WORKSPACE  # For simulation, deploy to a subfolder in workspace

for domain, dist_rel_path in MESH_DOMAIN_PATHS.items():
    dist_path = WORKSPACE / dist_rel_path
    deploy_path = DEPLOY_ROOT / domain
    print(f"\n=== Processing {domain} ===")
    if not dist_path.exists():
        print(f"[ERROR] dist/ not found for {domain} at {dist_path}, skipping deploy.")
        continue
    # Deploy/sync step (simulate with local copy)
    print(f"[INFO] Syncing dist/ to {deploy_path}...")
    if deploy_path.exists():
        shutil.rmtree(deploy_path)
    shutil.copytree(dist_path, deploy_path)
    print(f"[OK] {domain} deployed.")

print("\n[INFO] All domains processed.")
print("[NEXT] Run: python scripts/ipfs_pin_all.py and python scripts/update_registry_dnslink.py to pin and update DNSLink for all sites.") 