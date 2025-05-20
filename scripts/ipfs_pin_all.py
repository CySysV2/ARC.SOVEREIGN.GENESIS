import os
import json
import datetime

STACK_ROOT = os.path.abspath(os.path.dirname(__file__) + '/../')
SITES_ROOT = os.path.join(STACK_ROOT, 'sites')
PINNED_DIR = os.path.join(STACK_ROOT, 'pinned')
REGISTRY_PATH = os.path.join(STACK_ROOT, 'Bridge', 'Registry', 'epoch', 'ΣΩΩ.5.3++')
SITE_CID_MAP = os.path.join(REGISTRY_PATH, 'site-cid-map.json')
LOG_PATH = os.path.join(STACK_ROOT, 'logs', 'zkTrail.log')

os.makedirs(PINNED_DIR, exist_ok=True)
os.makedirs(REGISTRY_PATH, exist_ok=True)

def log_event(event):
    ts = datetime.datetime.now(datetime.UTC).isoformat()
    with open(LOG_PATH, 'a', encoding='utf-8') as f:
        f.write(f"[{{ts}}] {{event}}\n")

def pin_site(site, dist_path):
    cid_file = os.path.join(PINNED_DIR, f"{site}.cid")
    result = os.popen(f"ipfs add -r {dist_path}").readlines()
    if not result:
        return None
    final_cid = result[-1].split()[1]
    with open(cid_file, 'w') as f:
        f.write(final_cid)
    log_event(f"IPFS::Pinned {site} with CID {final_cid}")
    return final_cid

def main():
    site_cids = {}
    for site in os.listdir(SITES_ROOT):
        dist_path = os.path.join(SITES_ROOT, site, '.vitepress', 'dist')
        if os.path.isdir(dist_path):
            cid = pin_site(site, dist_path)
            if cid:
                site_cids[site] = cid
    with open(SITE_CID_MAP, 'w', encoding='utf-8') as f:
        json.dump(site_cids, f, indent=2)
    log_event("IPFS::site-cid-map.json updated for ΣΩΩ.5.3++")

if __name__ == '__main__':
    main() 