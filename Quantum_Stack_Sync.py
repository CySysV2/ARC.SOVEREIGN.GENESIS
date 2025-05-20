import os
import datetime
import json

STACK_MAIN = "C:/DFT_GCC_TRIAD_MAINSTACK"
STACK_SUB = os.path.join(STACK_MAIN, "ARC.SOVEREIGN.GENESIS")
STACK_LOG = os.path.join(STACK_MAIN, "logs", "stack_ops.log")


def log_event(event):
    ts = datetime.datetime.now(datetime.UTC).isoformat()
    with open(STACK_LOG, 'a', encoding='utf-8') as f:
        f.write(f"[{ts}] {event}\n")


def sync_substack_state():
    """Synchronize epoch state to substack and main registry."""
    print("\n🔄 Syncing Substack ↔ Mainstack for Epoch ΣΩΩ.5.1++")
    sub_epoch = os.path.join(STACK_SUB, "epoch_SigmaOmega5.0++.json")
    dest_epoch_main = os.path.join(STACK_MAIN, "Bridge", "Registry", "epoch_SigmaOmega5.0++.json")
    
    os.system(f"copy \"{sub_epoch}\" \"{dest_epoch_main}\" >nul")
    log_event("Substack epoch state synced to main registry")


def push_cursor_metadata():
    """Write Cursor Composer manifest with explicit metadata for enhanced rules."""
    meta = {
        "cursor_mode": "quantum-harmonic",
        "meta_version": "1.0.3",
        "synced_at": datetime.datetime.now(datetime.UTC).isoformat(),
        "allowed_ops": ["vitepress:build", "vitepress:deploy", "ipfs:pin", "memcache:update", "dao:emit"],
        "substack": "ARC.SOVEREIGN.GENESIS",
        "source_editor": "Cursor Composer",
        "sync_policy": "epoch-driven",
        "description": "This manifest enables Cursor Composer's harmonic ruleset and propagation macros."
    }
    manifest_path = os.path.join(STACK_SUB, ".cursor.meta.json")
    with open(manifest_path, 'w', encoding='utf-8') as f:
        json.dump(meta, f, indent=2)
    log_event("Cursor Composer metadata written for ΣΩΩ.5.1++")


if __name__ == "__main__":
    sync_substack_state()
    push_cursor_metadata()
    print("✅ Substack state and Cursor rules are now harmonized with Epoch ΣΩΩ.5.1++") 