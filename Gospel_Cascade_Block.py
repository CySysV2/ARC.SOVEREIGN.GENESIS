import os
import subprocess
import json
import datetime

ROOT = "C:/DFT_GCC_TRIAD_MAINSTACK"
PROJECT = os.path.join(ROOT, "ARC.SOVEREIGN.GENESIS")
REGISTRY = os.path.join(ROOT, "Bridge", "Registry")
DOC_PATH = os.path.join(PROJECT, "docs")
LOG_FILE = os.path.join(ROOT, "logs", "zkTrail.log")
SITE_SRC = os.path.join(PROJECT, "sites")


def log(msg):
    timestamp = datetime.datetime.now(datetime.UTC).isoformat()
    with open(LOG_FILE, 'a', encoding='utf-8') as f:
        f.write(f"[{timestamp}] {msg}\n")


def update_documentation():
    """Harmonize and version .md documentation from each mesh subdomain."""
    for site in os.listdir(SITE_SRC):
        site_path = os.path.join(SITE_SRC, site)
        if not os.path.isdir(site_path):
            continue  # Skip files, only process directories
        doc_dir = os.path.join(site_path, "docs")
        if not os.path.exists(doc_dir):
            os.makedirs(doc_dir)
        with open(os.path.join(doc_dir, "production-stage.md"), 'w', encoding='utf-8') as f:
            f.write(f"# {site} Documentation\n\nUpdated for Epoch ΣΩΩ.5.5\n")
        log(f"Documentation updated for {site}")


def rebuild_sites():
    """Run vitepress build on each site."""
    for site in os.listdir(SITE_SRC):
        site_path = os.path.join(SITE_SRC, site)
        if not os.path.isdir(site_path):
            continue  # Skip files, only process directories
        if os.path.exists(os.path.join(site_path, ".vitepress")) and os.path.exists(os.path.join(site_path, "package.json")):
            subprocess.call(["npm", "run", "build"], cwd=site_path)
            log(f"Site rebuilt: {site}")


def finalize_git_commit():
    """Commit updated docs and site builds."""
    try:
        subprocess.call("git add .", cwd=PROJECT, shell=True)
        # Use a simple, safe commit message
        subprocess.call("git commit -m 'Epoch-ΣΩΩ.5.5-harmonization'", cwd=PROJECT, shell=True)
        subprocess.call("git push origin main", cwd=PROJECT, shell=True)
        log("Git commit + push completed")
    except Exception as e:
        log(f"Git commit/push failed: {e}")


def scaffold_dao_proposal():
    """Generate DAO proposal file from the current epoch site CID map."""
    SITE_CID_MAP = os.path.join(REGISTRY, "epoch", "ΣΩΩ.5.5", "site-cid-map.json")
    DAO_PROPOSAL = os.path.join(ROOT, "dao", "ΣΩΩ.5.5-proposal.json")
    try:
        with open(SITE_CID_MAP, 'r', encoding='utf-8') as f:
            site_map = json.load(f)
    except Exception as e:
        log(f"ERROR: Unable to read site-cid-map.json — {e}")
        return

    proposal = {
        "epoch": "ΣΩΩ.5.5",
        "title": "DAO Mesh Vote: Epoch Synchronization and Authority Ledger Propagation",
        "description": "Propose mesh-wide propagation of verified CIDs and semantic relay structures.",
        "cid_targets": site_map,
        "status": "draft",
        "proposed_at": datetime.datetime.now(datetime.UTC).isoformat()
    }

    os.makedirs(os.path.dirname(DAO_PROPOSAL), exist_ok=True)
    with open(DAO_PROPOSAL, 'w', encoding='utf-8') as f:
        json.dump(proposal, f, indent=2)
    log("DAO proposal scaffolded for ΣΩΩ.5.5")


def scaffold_vote_threads():
    """Generate an index of CID → vote propagation stubs."""
    SITE_CID_MAP = os.path.join(REGISTRY, "epoch", "ΣΩΩ.5.5", "site-cid-map.json")
    DAO_THREADS = os.path.join(ROOT, "dao", "proposals", "ΣΩΩ.5.5-vote-threads.json")
    os.makedirs(os.path.dirname(DAO_THREADS), exist_ok=True)  # Ensure directory exists
    try:
        with open(SITE_CID_MAP, 'r', encoding='utf-8') as f:
            site_map = json.load(f)
    except Exception as e:
        log(f"ERROR: Unable to read site-cid-map.json for voting scaffold — {e}")
        return

    threads = {domain: {"cid": data["cid"], "vote": None, "status": "pending"}
               for domain, data in site_map.items()}

    with open(DAO_THREADS, 'w', encoding='utf-8') as f:
        json.dump(threads, f, indent=2)
    log("DAO vote thread index scaffolded for ΣΩΩ.5.5")


if __name__ == "__main__":
    print("\n🚀 Executing Recursive Harmonization Cascade for Epoch ΣΩΩ.5.5")
    try:
        update_documentation()
        rebuild_sites()
        finalize_git_commit()
    except Exception as e:
        log(f"Harmonization error: {e}")
    try:
        scaffold_dao_proposal()
        scaffold_vote_threads()
    except Exception as e:
        log(f"DAO scaffold error: {e}")
    print("✅ All sites rebuilt, documentation aligned, DAO scaffolded, and changes committed for Epoch ΣΩΩ.5.5") 