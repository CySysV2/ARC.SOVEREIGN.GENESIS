import os, datetime, json

STACK_ROOT = "C:/DFT_GCC_TRIAD_MAINSTACK"
CANISTER_ARCHITECTURE = [
    {"name": "DFT-Core", "desc": "Main site UI + Nav", "frontend": "vitepress", "domain": "digital-fabrica.com"},
    {"name": "DFT-Knowledge", "desc": "Recursive AI synthesis DB", "domain": "ikl.digital-fabrica.com"},
    {"name": "DFT-Governance", "desc": "YellowChain DAO logic", "domain": "civic.digital-fabrica.com"},
    {"name": "DFT-BSA", "desc": "Blockchain syndication & metadata", "domain": "qic.digital-fabrica.com"},
    {"name": "DFT-CySys", "desc": "Cybernetic economic models", "domain": "monad.digital-fabrica.com"},
    {"name": "DFT-Neutrinite", "desc": "Quantum-secure infrastructure", "domain": "tc.digital-fabrica.com"},
    {"name": "DFT-Institutional", "desc": "University onboarding & access", "domain": "ip.digital-fabrica.com"},
    {"name": "DFT-Artistfolio", "desc": "AI NFT art ecosystem", "domain": "media.digital-fabrica.com"},
    {"name": "DFT-GILC", "desc": "Formal logic/AI/math base", "domain": "gilc.digital-fabrica.com"},
    {"name": "DFT-Treasury", "desc": "Smart funding & grants", "domain": "dao.digital-fabrica.com"}
]

REGISTRY_PATH = os.path.join(STACK_ROOT, "Bridge", "Registry", "df_ic_stack.json")


def build_ic_stack_registry():
    timestamp = datetime.datetime.now(datetime.UTC).isoformat()
    entries = [
        {"canister": c["name"], "domain": c["domain"], "desc": c["desc"], "timestamp": timestamp, "status": "planned"}
        for c in CANISTER_ARCHITECTURE
    ]
    os.makedirs(os.path.dirname(REGISTRY_PATH), exist_ok=True)
    with open(REGISTRY_PATH, 'w', encoding='utf-8') as f:
        json.dump({"epoch": "ΣΩΩ.5.2", "canisters": entries}, f, indent=2)
    print("✅ IC Stack Registry Generated at:", REGISTRY_PATH)


def sync_frontend_structure():
    print("🔁 Syncing VitePress mesh site structure...")
    for c in CANISTER_ARCHITECTURE:
        domain = c['domain']
        path = os.path.join(STACK_ROOT, f"sites/{domain}/docs")
        os.makedirs(path, exist_ok=True)
        index_md = os.path.join(path, "_ic_canister.md")
        if not os.path.exists(index_md):
            with open(index_md, 'w', encoding='utf-8') as f:
                f.write(f"# {c['name']} — {c['desc']}\n\nMesh-linked to: `{domain}`\n")
    print("✅ Synced IC site structure to all frontend domains")


if __name__ == "__main__":
    build_ic_stack_registry()
    sync_frontend_structure()
    print("\n🌐 Quantum Mesh Stack Blueprint Initialized — ΣΩΩ.5.2") 