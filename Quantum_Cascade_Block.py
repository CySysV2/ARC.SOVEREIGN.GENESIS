import os
import datetime
import subprocess

ROOT = "C:/DFT_GCC_TRIAD_MAINSTACK/ARC.SOVEREIGN.GENESIS"
SITE_DIR = os.path.join(ROOT, "sites")
LOG = os.path.join(ROOT, "logs", "zkTrail.log")
PREVIEW_PORT_BASE = 5180

def log(event):
    ts = datetime.datetime.now(datetime.UTC).isoformat()
    with open(LOG, 'a', encoding='utf-8') as f:
        f.write(f"[{ts}] {event}\n")

def get_mesh_sites():
    return [d for d in os.listdir(SITE_DIR) if os.path.isdir(os.path.join(SITE_DIR, d))]

def preview_site(domain, port_offset=0):
    port = PREVIEW_PORT_BASE + port_offset
    path = os.path.join(SITE_DIR, domain)
    pkg = os.path.join(path, "package.json")
    if not os.path.exists(pkg):
        print(f"⚠️  Skipping {domain}: No package.json found.")
        return
    cmd = f'cd "{path}" && npm run docs:dev -- --port {port}'
    log(f"PREVIEW_TRIGGERED::{domain}::PORT:{port}")
    subprocess.Popen(cmd, shell=True)
    print(f"🌐 {domain} is now running at http://localhost:{port}")

def structured_evolution(domain):
    path = os.path.join(SITE_DIR, domain, "docs")
    print(f"🧠 Prompt Zone: Structured Evolution for {domain}")
    print("Edit markdown, add diagrams, or rewrite content...")
    os.system(f'code "{path}"')
    log(f"STRUCTURED_EDIT_SESSION::{domain}")

if __name__ == "__main__":
    print("\n🚀 Windsurf Mesh Stack Preview & Evolution Initiator")
    mesh = get_mesh_sites()

    for i, domain in enumerate(mesh):
        preview_site(domain, port_offset=i)
        structured_evolution(domain)

    print("\n✅ All mesh domains running in preview mode. Local editing enabled.")
    log("WINDSURF_STACK_PREVIEW_ALL_MESH_DOMAINS") 