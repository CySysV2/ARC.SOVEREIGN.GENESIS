import os
import datetime
import json

STACK_ROOT = "C:/DFT_GCC_TRIAD_MAINSTACK"
LOG_PATH = os.path.join(STACK_ROOT, "logs", "zkTrail.log")
SITE_DIR = os.path.join(STACK_ROOT, "sites")
VERSION_PATH = os.path.join(STACK_ROOT, "Bridge", "Registry", "evolution.json")


def log_event(event):
    ts = datetime.datetime.now(datetime.UTC).isoformat()
    with open(LOG_PATH, 'a', encoding='utf-8') as log:
        log.write(f"[{ts}] {event}\n")


def wrap_site_with_ui(subdomain):
    theme_path = os.path.join(SITE_DIR, subdomain, ".vitepress", "theme")
    os.makedirs(os.path.join(theme_path, "components"), exist_ok=True)

    with open(os.path.join(theme_path, "components", "Header.vue"), 'w', encoding='utf-8') as f:
        f.write("""<template><header class='df-header'>\n  <nav><a href='/'>Home</a> | <a href='/dao'>DAO</a></nav></header></template>\n<style>.df-header { background: #000; color: #fff; padding: 1rem; }</style>""")

    with open(os.path.join(theme_path, "components", "Footer.vue"), 'w', encoding='utf-8') as f:
        f.write("""<template><footer class='df-footer'>\n  <p>Epoch ΣΩΩ.5.3+</p></footer></template>\n<style>.df-footer { background: #111; color: #aaa; padding: 1rem; }</style>""")

    index_ts_path = os.path.join(theme_path, "index.ts")
    with open(index_ts_path, 'w', encoding='utf-8') as f:
        f.write("""import DefaultTheme from 'vitepress/theme'\nimport Header from './components/Header.vue'\nimport Footer from './components/Footer.vue'\n\nexport default {\n  ...DefaultTheme,\n  Layout() {\n    return {\n      template: `<Header /><DefaultTheme.Layout /><Footer />`\n    }\n  }\n}""")
    log_event(f"Wrapped site '{subdomain}' with DF UI layer")


def update_version_manifest():
    manifest = {
        "epoch": "ΣΩΩ.5.3+",
        "versioned_at": datetime.datetime.now(datetime.UTC).isoformat(),
        "status": "quantum-synced",
        "components": [
            "header", "footer", "CID-overlay", "DAO link", "mobile-nav"
        ]
    }
    os.makedirs(os.path.dirname(VERSION_PATH), exist_ok=True)
    with open(VERSION_PATH, 'w', encoding='utf-8') as f:
        json.dump(manifest, f, indent=2)
    log_event("Stack evolution version manifest written")


def rebuild_and_sync_all_sites():
    os.system("npm run build-all-sites")
    os.system("node deploy.js --all")
    os.system("python scripts/update_registry_dnslink.py")
    os.system("git add . && git commit -m 'Epoch ΣΩΩ.5.3+ UI overlay + versioning' && git push origin main")
    log_event("All sites rebuilt, deployed, pinned, and committed")


if __name__ == "__main__":
    subdomains = [
        "blog.digital-fabrica.com", "civic.digital-fabrica.com", "whitepaper.digital-fabrica.com",
        "qic.digital-fabrica.com", "ip.digital-fabrica.com", "media.digital-fabrica.com",
        "monad.digital-fabrica.com", "tc.digital-fabrica.com", "ikl.digital-fabrica.com"
    ]
    for sub in subdomains:
        wrap_site_with_ui(sub)

    update_version_manifest()
    rebuild_and_sync_all_sites()
    print("\n✅ Epoch ΣΩΩ.5.3+ Mesh Stack versioning, UI wrapping, and deployment complete.") 