import os, json, datetime

EPOCH = "ΣΩΩ.5.4"
ROOT = "C:/DFT_GCC_TRIAD_MAINSTACK/ARC.SOVEREIGN.GENESIS"
PROPOSAL_PATH = f"{ROOT}/dao/{EPOCH}-proposal.json"
CID_MAP_PATH = f"{ROOT}/Bridge/Registry/epoch/{EPOCH}/site-cid-map.json"
VOTE_DIR = f"{ROOT}/vote_records/{EPOCH}"
ZKTRAIL = f"{ROOT}/logs/zkTrail.log"

BROADCAST = True
MESH_ENDPOINTS = [
    "blog.digital-fabrica.com/api/vote_signal.php",
    "civic.digital-fabrica.com/api/vote_signal.php",
    "whitepaper.digital-fabrica.com/api/vote_signal.php",
    "qic.digital-fabrica.com/api/vote_signal.php",
    "ip.digital-fabrica.com/api/vote_signal.php",
    "media.digital-fabrica.com/api/vote_signal.php",
    "monad.digital-fabrica.com/api/vote_signal.php",
    "tc.digital-fabrica.com/api/vote_signal.php",
    "ikl.digital-fabrica.com/api/vote_signal.php",
    "gilc.digital-fabrica.com/api/vote_signal.php"
]

os.makedirs(VOTE_DIR, exist_ok=True)

try:
    with open(CID_MAP_PATH, encoding="utf-8") as f:
        cid_map = json.load(f)
    print("[DEBUG] Loaded cid_map:", cid_map)
except Exception as e:
    print(f"[ERROR] Failed to load cid_map: {e}")
    cid_map = {}

try:
    with open(PROPOSAL_PATH, encoding="utf-8") as f:
        proposals = json.load(f)
    print("[DEBUG] Loaded proposals:", proposals)
except Exception as e:
    print(f"[ERROR] Failed to load proposals: {e}")
    proposals = {}

vote_batch = []
timestamp = datetime.datetime.now(datetime.UTC).isoformat()

# Expecting cid_map to be a dict of domain: {cid, ic_canister, ...}
for domain, entry in cid_map.items():
    print(f"[DEBUG] Processing domain: {domain}, entry: {entry}")
    cid = entry.get("cid", "")
    canister = entry.get("ic_canister", "unknown")
    proposal = proposals.get("proposal", {})
    vote_entry = {
        "domain": domain,
        "cid": cid,
        "canister": canister,
        "proposal": proposal,
        "timestamp": timestamp,
        "vote_status": "pending"
    }
    vote_batch.append(vote_entry)

# Save vote envelope
vote_file = os.path.join(VOTE_DIR, "init_vote_batch.json")
with open(vote_file, "w", encoding="utf-8") as f:
    json.dump(vote_batch, f, indent=2)

# Log event
with open(ZKTRAIL, "a", encoding="utf-8") as f:
    f.write(f"[{timestamp}] DAO_VOTE_ENVELOPES_INITIALIZED::{EPOCH}\n")

print("\u2705 DAO Vote Envelopes Initialized")

# --- DAO Voting UI Sync ---
civic_ui_dir = f"{ROOT}/sites/civic.digital-fabrica.com/src/pages/vote"
os.makedirs(civic_ui_dir, exist_ok=True)

# Copy vote batch to civic frontend
frontend_vote_path = os.path.join(civic_ui_dir, "init_vote_batch.json")
with open(frontend_vote_path, "w", encoding="utf-8") as f:
    json.dump(vote_batch, f, indent=2)

print("\u2728 DAO Voting UI Synced at /vote for Epoch", EPOCH)

if BROADCAST:
    try:
        import requests
        for endpoint in MESH_ENDPOINTS:
            try:
                url = f"https://{endpoint}"
                resp = requests.post(url, json=vote_batch, timeout=5)
                print(f"Broadcasted to {endpoint}: {resp.status_code}")
            except Exception as e:
                print(f"Broadcast failed for {endpoint}: {e}")
    except ImportError:
        print("[ERROR] requests module not installed. Broadcasting skipped.") 