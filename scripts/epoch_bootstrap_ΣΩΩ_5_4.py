import os
import datetime
import json

STACK_ROOT = "C:/DFT_GCC_TRIAD_MAINSTACK"
EPOCH_ID = "ΣΩΩ.5.4"
EPOCH_DIR = os.path.join(STACK_ROOT, "Bridge", "Registry", "epoch", EPOCH_ID)
SITE_MAP_FILE = os.path.join(EPOCH_DIR, "ecosystem-map.json")
CID_MAP_FILE = os.path.join(EPOCH_DIR, "site-cid-map.json")
EPOCH_SIG_FILE = os.path.join(EPOCH_DIR, "epoch.sig")
DAO_PROPOSAL_FILE = os.path.join(STACK_ROOT, "dao", "proposals", f"{EPOCH_ID}-proposal.json")
LOG_FILE = os.path.join(STACK_ROOT, "logs", "zkTrail.log")

# Placeholder mesh domains, canisters and baseline CID mapping from live state
MESH_DOMAINS = [
    "digital-fabrica.com", "civic.digital-fabrica.com", "qic.digital-fabrica.com",
    "whitepaper.digital-fabrica.com", "media.digital-fabrica.com", "monad.digital-fabrica.com",
    "tc.digital-fabrica.com", "blog.digital-fabrica.com", "ip.digital-fabrica.com",
    "ikl.digital-fabrica.com", "gilc.digital-fabrica.com"
]

def log(msg):
    with open(LOG_FILE, 'a', encoding='utf-8') as log:
        log.write(f"[{datetime.datetime.now(datetime.UTC).isoformat()}] {msg}\n")


def initialize_epoch_dir():
    os.makedirs(EPOCH_DIR, exist_ok=True)
    log(f"EPOCH {EPOCH_ID} directory structure initialized")


def create_ecosystem_map():
    data = {
        "epoch": EPOCH_ID,
        "domains": MESH_DOMAINS,
        "synced_at": datetime.datetime.now(datetime.UTC).isoformat(),
        "status": "initialized"
    }
    with open(SITE_MAP_FILE, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2)
    log(f"EPOCH {EPOCH_ID} site map created")


def create_epoch_signature():
    with open(EPOCH_SIG_FILE, 'w', encoding='utf-8') as f:
        f.write(f"epoch::{EPOCH_ID}\ntimestamp::{datetime.datetime.now(datetime.UTC).isoformat()}\nstatus::initiated\n")
    log(f"EPOCH {EPOCH_ID} signature file created")


def scaffold_dao_proposal():
    os.makedirs(os.path.dirname(DAO_PROPOSAL_FILE), exist_ok=True)
    dao = {
        "epoch": EPOCH_ID,
        "proposed_by": "Ivan Pasev",
        "cid_map_ref": CID_MAP_FILE,
        "registry_ref": SITE_MAP_FILE,
        "status": "draft",
        "created_at": datetime.datetime.now(datetime.UTC).isoformat(),
        "description": "CID propagation, mesh alignment and registry update for epoch ΣΩΩ.5.4"
    }
    with open(DAO_PROPOSAL_FILE, 'w', encoding='utf-8') as f:
        json.dump(dao, f, indent=2)
    log(f"DAO proposal scaffolded for {EPOCH_ID}")


if __name__ == '__main__':
    initialize_epoch_dir()
    create_ecosystem_map()
    create_epoch_signature()
    scaffold_dao_proposal()
    print(f"\n✅ Epoch {EPOCH_ID} Bootstrap Complete.")
    print("All base files created. Ready for CID input, DNSLink update, and DAO vote propagation.") 