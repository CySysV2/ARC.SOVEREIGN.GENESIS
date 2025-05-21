import os
import json
import datetime
from pathlib import Path

EPOCH = "ΣΩΩ.5.4"
BASE_DIR = Path(__file__).parent.parent
CID_MAP_PATH = BASE_DIR / f"Bridge/Registry/epoch/{EPOCH}/site-cid-map.json"
PROPOSAL_PATH = BASE_DIR / f"dao/{EPOCH}-proposal.json"
VOTE_RECORDS_DIR = BASE_DIR / f"vote_records/{EPOCH}"
VOTE_BATCH_PATH = VOTE_RECORDS_DIR / "init_vote_batch.json"
ZKTRAIL_LOG = BASE_DIR / "logs/zkTrail.log"

# Optionally, set to True to broadcast to mesh endpoints
BROADCAST = False
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

def log_event(event):
    timestamp = datetime.datetime.utcnow().isoformat() + "Z"
    entry = {"timestamp": timestamp, "event": event}
    with open(ZKTRAIL_LOG, "a", encoding="utf-8") as f:
        f.write(json.dumps(entry, ensure_ascii=False) + "\n")

def load_json(path):
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)

def save_json(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

def main():
    if not CID_MAP_PATH.exists():
        print(f"[ERROR] CID map not found: {CID_MAP_PATH}")
        return
    if not PROPOSAL_PATH.exists():
        print(f"[ERROR] Proposal file not found: {PROPOSAL_PATH}")
        return
    cid_map = load_json(CID_MAP_PATH)
    proposal = load_json(PROPOSAL_PATH)
    vote_envelopes = []
    thread_id = 0
    for domain, entry in cid_map.items():
        envelope = {
            "domain": domain,
            "cid": entry.get("cid"),
            "ic_canister": entry.get("ic_canister", ""),
            "proposal_file": f"{EPOCH}-proposal.json",
            "thread_id": thread_id,
            "status": "open",
            "votes": []
        }
        vote_envelopes.append(envelope)
        thread_id += 1
    batch = {
        "epoch": EPOCH,
        "vote_envelopes": vote_envelopes,
        "timestamp": datetime.datetime.utcnow().isoformat() + "Z"
    }
    save_json(VOTE_BATCH_PATH, batch)
    log_event({
        "action": "init_dao_vote_batch",
        "epoch": EPOCH,
        "vote_batch": str(VOTE_BATCH_PATH),
        "envelopes": len(vote_envelopes)
    })
    print(f"[OK] DAO vote batch initialized: {VOTE_BATCH_PATH}")
    if BROADCAST:
        import requests
        for endpoint in MESH_ENDPOINTS:
            try:
                url = f"https://{endpoint}"
                resp = requests.post(url, json=batch, timeout=5)
                print(f"Broadcasted to {endpoint}: {resp.status_code}")
            except Exception as e:
                print(f"Broadcast failed for {endpoint}: {e}")

if __name__ == "__main__":
    main() 