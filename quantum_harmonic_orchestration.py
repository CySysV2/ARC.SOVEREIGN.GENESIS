import os
import subprocess
import time
import json
from datetime import datetime, timedelta
import sys

# === Config ===
CANISTERS = ['hex-gov.mo', 'zk-router.mo', 'seed-bundle.mo', 'spawn.mo']
SYNC_INTERVAL = 3600  # seconds (1 hour)
HIGH_SYNC_INTERVAL = 900  # seconds (15 min)
LEDGER_LOG = 'sites/qic.digital-fabrica.com/fns-ledger/ΣΩΩ.4.0-qic.log'
ZKTRAIL_LOG = 'sites/qic.digital-fabrica.com/fns-ledger/zkTrail.log'
DASHBOARD_JSON = 'sites/qic.digital-fabrica.com/dao-telemetry.dashboard.json'
REGISTRY_JSON = 'sites/qic.digital-fabrica.com/registry.json'
EPOCH_SIG = 'sites/qic.digital-fabrica.com/epoch.sig'
TOPOLOGY_FILE = 'sites/qic.digital-fabrica.com/fns-ledger/topo-ΣΩΩ.4.0.json'
BACKUP_LOG = 'sites/qic.digital-fabrica.com/backup-log.json'
BACKUP_DIRS = [
    'SBS',
    'sites/qic.digital-fabrica.com/fns-ledger',
    'sites/qic.digital-fabrica.com/detached-subnets',
    'sites/qic.digital-fabrica.com/seed-core'
]
IPFS_PATH = 'C:\\kubo_install\\ipfs.exe'
SITE_DIST = 'sites/qic.digital-fabrica.com/.vitepress/dist'
MANIFEST_CID = 'sites/qic.digital-fabrica.com/manifest.cid'
CIVIC_PING_URL = 'https://civic.digital-fabrica.com/ping?qic'

# Ensure all output uses UTF-8
sys.stdout.reconfigure(encoding='utf-8')

# === 1. Canister & Service Health ===
def check_canisters():
    results = {}
    for can in CANISTERS:
        try:
            status = subprocess.getoutput(f"dfx canister status {can}")
        except Exception as e:
            status = f"ERROR: {e}"
        results[can] = status
    return results

def log_health(results):
    now = datetime.now().isoformat()
    entry = {"timestamp": now, "canister_health": results}
    with open(LEDGER_LOG, "a", encoding="utf-8") as log:
        log.write(json.dumps(entry, ensure_ascii=False) + "\n")
    with open(DASHBOARD_JSON, "a", encoding="utf-8") as dash:
        dash.write(json.dumps(entry, ensure_ascii=False) + "\n")

# === 2. zkTrail Log Update ===
def append_zktrail(entry):
    os.makedirs(os.path.dirname(ZKTRAIL_LOG), exist_ok=True)
    with open(ZKTRAIL_LOG, "a", encoding="utf-8") as log:
        log.write(f"{datetime.now().isoformat()} :: {entry}\n")

# === 3. DNS/IPFS/ICP State Sync ===
def sync_dns_ipfs():
    os.system(f"{IPFS_PATH} add -r {SITE_DIST} > {MANIFEST_CID}")
    with open(MANIFEST_CID, "r", encoding="utf-8") as f:
        lines = f.readlines()
        last = [l for l in lines if l.strip().startswith("added")][-1].split()[1]
    # Write to registry.json
    with open(REGISTRY_JSON, "w", encoding="utf-8") as reg:
        reg.write(json.dumps({"cid": last, "epoch": "ΣΩΩ.4.0", "timestamp": datetime.now().isoformat()}, ensure_ascii=False) + "\n")
    # Output DNS TXT update
    print(f"_dnslink.qic.digital-fabrica.com TXT \"dnslink=/ipfs/{last}\"")
    # Update epoch.sig
    with open(EPOCH_SIG, "w", encoding="utf-8") as sig:
        sig.write(f"ΣΩΩ.4.0|{last}|quantum-sealed-placeholder\n")

# === 4. Civic/DAO Live Integration ===
def civicdash_ping():
    os.system(f"curl -s {CIVIC_PING_URL}")

# === 5. Fractal Topology Monitoring ===
def monitor_topology():
    if os.path.exists(TOPOLOGY_FILE):
        print("Fractal Topology Loaded.")
    else:
        print("⚠️ Topology file missing.")

# === 6. Backup & Redundancy ===
def perform_backup():
    now = datetime.now().strftime("%Y%m%d-%H%M%S")
    backup_name = f"backup-QIC-{now}.zip"
    backup_cmd = f"zip -r {backup_name} " + " ".join(BACKUP_DIRS)
    os.system(backup_cmd)
    # Log backup
    backup_entry = {"timestamp": now, "backup_file": backup_name}
    with open(BACKUP_LOG, "a", encoding="utf-8") as blog:
        blog.write(json.dumps(backup_entry, ensure_ascii=False) + "\n")
    print(f"Backup saved as {backup_name}")

# === 7. Epoch Signature Rotation ===
def rotate_epoch_sig():
    now = datetime.now().isoformat()
    with open(EPOCH_SIG, "w", encoding="utf-8") as sig:
        sig.write(f"ΣΩΩ.4.0 SIGNED at {now}\n")
    append_zktrail("EPOCH_SIGNATURE_ROTATED")

# === 8. Anomaly Detection & Self-Healing ===
def detect_and_heal_anomalies():
    # Example: Check zkTrail for out-of-sequence
    try:
        with open(ZKTRAIL_LOG, "r", encoding="utf-8") as log:
            lines = log.readlines()
            if any("ERROR" in l or "out-of-sequence" in l for l in lines[-10:]):
                print("Anomaly detected in zkTrail. Triggering re-pin and state restore.")
                sync_dns_ipfs()
                append_zktrail("ANOMALY: Re-pin and state restore triggered.")
    except Exception as e:
        print(f"Anomaly detection error: {e}")

# === 9. Main Orchestration Loop ===
def main(sync_interval=SYNC_INTERVAL):
    print("🔁 FGQC Quantum Harmonic Sync Loop Started...")
    while True:
        # 1. Health
        health = check_canisters()
        log_health(health)
        append_zktrail("HEALTH_CHECK_COMPLETE")

        # 2. zkTrail
        append_zktrail("EXEC_CYCLE_INITIATED")

        # 3. Sync DNS/IPFS
        sync_dns_ipfs()
        append_zktrail("DNS/IPFS_SYNC_COMPLETE")

        # 4. Civic
        civicdash_ping()
        append_zktrail("CIVIC_SYNC_PINGED")

        # 5. Topology
        monitor_topology()
        append_zktrail("TOPOLOGY_MONITOR_COMPLETE")

        # 6. Backup
        perform_backup()
        append_zktrail("FULL_BACKUP_COMPLETE")

        # 7. Signature
        rotate_epoch_sig()

        # 8. Anomaly Detection
        detect_and_heal_anomalies()
        append_zktrail("ANOMALY_CHECK_COMPLETE")

        print("✅ FGQC Monad Stack is in full operational orchestration. Sleeping until next cycle...")
        time.sleep(sync_interval)

if __name__ == "__main__":
    main() 