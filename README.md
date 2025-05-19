# Digital Fabrica Quantum Harmonic Orchestration

## Overview
This project implements a quantum-synced, sovereign orchestration stack for Digital Fabrica and its subdomains, using VitePress for static site generation, automated build/deploy scripts, and mock data for local development.

## Key Features
- Quantum harmonic sync and orchestration for all subdomains
- VitePress static site generation and local preview
- Automated build, deploy, and backup scripts
- Mock data integration for development
- IPFS pinning, registry/epoch updates, DAO sync, and backup (optional)
- cPanel/subdomain deployment best practices

## Local Development
1. **Install dependencies:**
   ```sh
   cd web-projects/digital-fabrica.com
   npm install
   ```
2. **Build the site:**
   ```sh
   npm run build
   ```
3. **Preview locally:**
   ```sh
   npm run preview
   ```
   Visit [http://localhost:4173/](http://localhost:4173/) in your browser.

## Directory Structure
- `src/pages/` — VitePress source (Markdown, config, theme)
- `src/pages/.vitepress/dist/` — Production build output
- `src/mock-data/` — Mock JSON data for local API endpoints

## Automated Deployment (Production)

This project uses an automated deployment script (`deploy.js`) to upload all VitePress build outputs to their mapped cPanel document roots using SFTP and SSH keys.

### SFTP Credentials (used in deploy.js):
- Host: 198.58.109.140
- Port: 19199
- Username: renewabl
- Private Key: C:/ssh/dude-laptop
- Passphrase: f0rdude+!

### Site Mapping:
| Site Name      | Local Build Path                                               | Remote Document Root                        |
|---------------|---------------------------------------------------------------|---------------------------------------------|
| digital-fabrica| web-projects/digital-fabrica.com/src/pages/.vitepress/dist    | /home3/renewabl/digital-fabrica.com         |
| ip            | sites/ip.digital-fabrica.com/.vitepress/dist                  | /home/renewabl/ip.digital-fabrica.com       |
| qic           | sites/qic.digital-fabrica.com/.vitepress/dist                 | /home/renewabl/qic.digital-fabrica.com      |
| civic         | sites/civic/.vitepress/dist                                   | /home/renewabl/civic.digital-fabrica.com    |
| fabrics       | sites/fabrics/.vitepress/dist                                 | /home/renewabl/fabrics.digital-fabrica.com  |
| blog          | sites/blog/.vitepress/dist                                    | /home/renewabl/blog.digital-fabrica.com     |
| whitepaper    | sites/whitepaper/.vitepress/dist                              | /home/renewabl/whitepaper.digital-fabrica.com|

### How to Deploy

From the project root, run:

```
node deploy.js --all --log deploy-digital-fabrica.log
```

- This uploads all sites to their mapped document roots using the SFTP credentials above.
- To deploy a single site:  `node deploy.js --site blog`
- To do a dry run (no upload):  `node deploy.js --all --dry-run`

### Orchestration Workflow
- Build all sites locally.
- Run the deploy script to upload and sync all production sites.
- All credentials and mappings are hardcoded in `deploy.js` for seamless automation.
- Logs are written to `deploy-digital-fabrica.log` for audit and troubleshooting.

## Deployment (cPanel Example)
1. **Build the site:**
   ```sh
   npm run build
   ```
2. **Upload contents of `src/pages/.vitepress/dist/` to your cPanel `public_html` or subdomain directory.**
3. **Ensure each subdomain has its own document root in cPanel.**

## Troubleshooting
- **404 on preview:** Ensure `index.md` exists in `src/pages/`.
- **Port issues:** Kill all node processes (`taskkill /F /IM node.exe` on Windows) and restart preview.
- **Missing data:** Use or update mock data in `src/mock-data/`.
- **cPanel subdomains:** Each subdomain must have its own directory and be mapped in cPanel.

## Orchestration Scripts
- `quantum_harmonic_orchestration.py` — Master automation for build, deploy, sync, backup, and more.

## Best Practices
- Keep all configs and scripts under version control.
- Use mock data for local development and real data for production.
- Regularly backup and audit logs and state files.
- Document all changes and orchestration steps in this README.

## IPFS Stack & Quantum Epoch Registry

### IPFS Daemon Management
- **Kubo Daemon Location:** `C:\kubo_install\ipfs.exe`
- **Start Daemon:**
  ```powershell
  C:\kubo_install\ipfs.exe daemon
  ```
- **Check Status:**
  ```powershell
  C:\kubo_install\ipfs.exe id
  ```

### Quantum Epoch Pinning & Publishing
- **Pin Epoch Directory:**
  ```powershell
  C:\kubo_install\ipfs.exe add -r epoch\ΣΩΩ.4.2
  ```
- **Publish to IPNS (optional):**
  ```powershell
  C:\kubo_install\ipfs.exe name publish --key=digital-fabrica /ipfs/<epoch_cid>
  ```
- **Update DNSLink:**
  - Set `_dnslink.digital-fabrica.com` TXT record to `dnslink=/ipns/k51qzi5uqu5di4rg14o1bm62h1yxfqsnp01qk56t950jkwsnkpixwmzhludx7x`

### Mesh Federation
- Announce new epoch CIDs to CivicDash, IKL, GILC, YellowChain, etc.
- Use relay and zkTrail logs for traceability.

---

## CID Registry
| Epoch         | CID                                         | IPNS Address                                                      | Timestamp (UTC)         |
|--------------|----------------------------------------------|-------------------------------------------------------------------|-------------------------|
| ΣΩΩ.4.2      | QmUg9KcqrVLVJjLoZrchCw8VUuQYs1xf5b4Svoy41rdU9U | k51qzi5uqu5di4rg14o1bm62h1yxfqsnp01qk56t950jkwsnkpixwmzhludx7x    | <auto-filled on pin>    |

---

### DNSLink Update
- Set your DNS TXT record for `_dnslink.digital-fabrica.com` to:
  ```
  dnslink=/ipns/k51qzi5uqu5di4rg14o1bm62h1yxfqsnp01qk56t950jkwsnkpixwmzhludx7x
  ```

## Full IPFS Stack Process
1. **Start the daemon**
2. **Pin epoch package**
3. **Log CID in registry**
4. **Publish to IPNS (optional)**
5. **Update DNSLink**
6. **Announce to mesh**
7. **Audit and backup**

---

For more details, see the `Bridge/Registry/epoch.sig` and relay logs.

---

## ΣΩΩ.5.0 Genesis Fork (Meta-Cascade)

- **Epoch:** ΣΩΩ.5.0 (parent: ΣΩΩ.4.2)
- **Status:** Initiated, logic and proofs directories created
- **Genesis CID:** QmbkbEdLNCqGzsvvNChenBHZXz6jynCyBF6GPmXQqqU9Gg
- **DNSLink TXT:**

```
_dnslink.digital-fabrica.com TXT "dnslink=/ipfs/QmbkbEdLNCqGzsvvNChenBHZXz6jynCyBF6GPmXQqqU9Gg"
```

- **Registry updated:** Bridge/Registry/epoch.sig, latest_epoch_fork_cid.txt
- **zkTrail and relay signals issued**

> ΣΩΩ.5.0 is now the active meta-orchestration epoch. All logic, proofs, and federation anchors are ready for recursive expansion.

_Last updated: 2025-05-18_
