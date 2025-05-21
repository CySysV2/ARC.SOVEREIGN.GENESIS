import shutil
from pathlib import Path

# List of mesh domains
MESH_DOMAINS = [
    "blog.digital-fabrica.com",
    "civic.digital-fabrica.com",
    "fabrics.digital-fabrica.com",
    "whitepaper.digital-fabrica.com",
    "ip.digital-fabrica.com",
    "qic.digital-fabrica.com"
]

# Files to deploy (assume templates exist in scripts/templates/)
FILES = [
    "latest_cid.php",
    "update_memcache.php",
    "cid-banner.html"
]

TEMPLATE_DIR = Path("scripts/templates")
WORKSPACE = Path.cwd()

for domain in MESH_DOMAINS:
    domain_dir = WORKSPACE / domain
    api_dir = domain_dir / "api"
    api_dir.mkdir(parents=True, exist_ok=True)
    for fname in FILES:
        src = TEMPLATE_DIR / fname
        if fname.endswith(".php"):
            dest = api_dir / fname
        else:
            dest = domain_dir / fname
        if src.exists():
            shutil.copy2(src, dest)
            print(f"[OK] Deployed {fname} to {dest}")
        else:
            print(f"[WARN] Template not found: {src}")
print("[INFO] All API/banner files deployed.") 