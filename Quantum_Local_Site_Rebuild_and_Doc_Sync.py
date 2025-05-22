import os
import subprocess

SITE_LIST = [
    "blog", "civic", "fabrics", "gilc", "ikl",
    "ip", "media", "monad", "qic", "tc", "whitepaper", "digital-fabrica.com"
]

BASE_PATH = "sites"

def build_site(site):
    if site == "digital-fabrica.com":
        path = os.path.join(BASE_PATH, site)
    else:
        path = os.path.join(BASE_PATH, site)
    print(f"🔄 Building: {site}")
    subprocess.run(["npm", "run", "build"], cwd=path)

def sync_doc(site):
    if site == "digital-fabrica.com":
        doc_path = os.path.join(BASE_PATH, site, "docs", "production-stage.md")
    else:
        doc_path = os.path.join(BASE_PATH, site, "docs", "production-stage.md")
    if os.path.exists(doc_path):
        print(f"✅ Doc found: {doc_path}")
    else:
        print(f"⚠️ Missing doc: {doc_path} — Skipping...")

def main():
    print("🚀 Quantum Mesh Site Rebuilder for Epoch ΣΩΩ.5.5")
    for site in SITE_LIST:
        sync_doc(site)
        build_site(site)

    print("📦 Git Commit:")
    os.system("git add .")
    os.system("git commit -m 'ΣΩΩ.5.5: Docs synced + site rebuilds complete'")
    os.system("git push origin main")

if __name__ == '__main__':
    main() 