import os
import json
import hashlib
import datetime
import sys

STACK_ROOT = "C:/DFT_GCC_TRIAD_MAINSTACK"
DAO_PROPOSAL_ABS = os.path.join(STACK_ROOT, "dao", "ΣΩΩ.5.5-proposal.json")
DAO_PROPOSAL_REL = os.path.join("dao", "ΣΩΩ.5.5-proposal.json")
BALLOTS_DIR = os.path.join(STACK_ROOT, "dao", "ballots")
CIVICDASH_STATE = os.path.join(STACK_ROOT, "civic.digital-fabrica.com", "state", "latest.json")
LOG_PATH = os.path.join(STACK_ROOT, "logs", "zkTrail.log")


def log_event(event):
    ts = datetime.datetime.now(datetime.UTC).isoformat()
    with open(LOG_PATH, 'a', encoding='utf-8') as log:
        log.write(f"[{ts}] {event}\n")


def hash_ballot(ballot):
    return hashlib.sha256(json.dumps(ballot, sort_keys=True).encode('utf-8')).hexdigest()


def load_proposal():
    print(f"[DEBUG] CWD: {os.getcwd()}")
    print(f"[DEBUG] ABS PATH: {DAO_PROPOSAL_ABS}")
    print(f"[DEBUG] REL PATH: {DAO_PROPOSAL_REL}")
    try:
        with open(DAO_PROPOSAL_ABS, 'r', encoding='utf-8') as f:
            print("[DEBUG] Loaded proposal from ABS path.")
            return json.load(f)
    except Exception as e_abs:
        print(f"[DEBUG] ABS path failed: {e_abs}")
        try:
            with open(DAO_PROPOSAL_REL, 'r', encoding='utf-8') as f:
                print("[DEBUG] Loaded proposal from REL path.")
                return json.load(f)
        except Exception as e_rel:
            print(f"[ERROR] Both ABS and REL path failed: {e_rel}")
            sys.exit(1)


def generate_ballots(proposal):
    os.makedirs(BALLOTS_DIR, exist_ok=True)
    ballots = {}
    for domain, info in proposal['cid_targets'].items():
        cid = info['cid'] if isinstance(info, dict) and 'cid' in info else info
        ballot = {
            "epoch": proposal["epoch"],
            "domain": domain,
            "cid": cid,
            "vote": None,
            "status": "pending",
            "created_at": datetime.datetime.now(datetime.UTC).isoformat()
        }
        ballot_hash = hash_ballot(ballot)
        ballot["hash_lock"] = ballot_hash
        # Sanitize domain for filename and use ASCII-safe epoch prefix
        safe_domain = domain.replace('.', '_')
        ballot_path = os.path.join(BALLOTS_DIR, f"epoch_5_5-{safe_domain}.vote.json")
        print(f"[DEBUG] Attempting to write ballot: {os.path.abspath(ballot_path)}")
        try:
            with open(ballot_path, 'w', encoding='utf-8') as f:
                json.dump(ballot, f, indent=2)
            print(f"[DEBUG] Ballot written: {os.path.abspath(ballot_path)}")
            print(f"[DEBUG] Exists after write: {os.path.exists(ballot_path)}")
        except Exception as e:
            print(f"[ERROR] Failed to write ballot for {domain}: {e}")
        ballots[domain] = ballot
        log_event(f"Ballot generated for {domain} with hash {ballot_hash}")
    # Write a debug test file in the ballots directory
    debug_test_path = os.path.join(BALLOTS_DIR, 'ballot_debug_test.json')
    try:
        with open(debug_test_path, 'w', encoding='utf-8') as f:
            json.dump({'debug': True}, f)
        print(f"[DEBUG] Debug test file written: {os.path.abspath(debug_test_path)}")
        print(f"[DEBUG] Exists after write: {os.path.exists(debug_test_path)}")
    except Exception as e:
        print(f"[ERROR] Failed to write debug test file: {e}")
    return ballots


def emit_civicdash_state(ballots):
    state = {
        "epoch": "ΣΩΩ.5.5",
        "timestamp": datetime.datetime.now(datetime.UTC).isoformat(),
        "ballots": {d: {"cid": b["cid"], "status": b["status"], "hash_lock": b["hash_lock"]} for d, b in ballots.items()}
    }
    os.makedirs(os.path.dirname(CIVICDASH_STATE), exist_ok=True)
    with open(CIVICDASH_STATE, 'w', encoding='utf-8') as f:
        json.dump(state, f, indent=2)
    log_event("CivicDash state emitted for ΣΩΩ.5.5")


def append_ledger(ballots):
    for domain, ballot in ballots.items():
        log_event(f"DAO_LEDGER::ΣΩΩ.5.5::{domain}::{ballot['hash_lock']}::{ballot['status']}")


def main():
    print("\n🚀 Quantum DAO Vote Propagation: Epoch ΣΩΩ.5.5")
    proposal = load_proposal()
    ballots = generate_ballots(proposal)
    emit_civicdash_state(ballots)
    append_ledger(ballots)
    print("✅ DAO ballots generated, CivicDash state updated, ledger appended. Quantum sync complete.")

if __name__ == "__main__":
    main() 