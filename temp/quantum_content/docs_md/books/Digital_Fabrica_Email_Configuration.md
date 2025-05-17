---
title: "Digital Fabrica Email Configuration"
author: "Operator 11411 (Ivan Pasev)"
created: 2025-05-03
last_modified: 2025-05-03
tags: [Digital Fabrica, Email, Configuration, Thunderbird, Cloudflare, Operator]
status: draft
operator_access: 11411
quantum_sync: true
---
# Digital Fabrica Email Configuration

## Summary
Comprehensive configuration and setup guide for Digital Fabrica email accounts, including Thunderbird, Cloudflare routing, and signature templates.

## Table of Contents
- Thunderbird Email Setup
- Cloudflare Email Routing
- Signature Templates
- TODOs & Open Questions

## Thunderbird Email Setup
- Account: i.pasev@digital-fabrica.com
- Incoming (IMAP): mail.digital-fabrica.com, Port 993, SSL/TLS
- Outgoing (SMTP): mail.digital-fabrica.com, Port 465, SSL/TLS
- Signature: Use HTML editor, paste from digital-fabrica-signature.html
- Mobile: Use same server settings

## Cloudflare Email Routing
- Primary, business, security, and catch-all addresses routed to personal email
- Setup steps: Email → Email Routing, create addresses, set destination, add catch-all
- Testing: Send/receive, SPF/DMARC verification

## Signature Template
Ivan Pasev
Founder, Grand Cybernetician, Principal Architect
Digital Fabrica
Email: i.pasev@digital-fabrica.com
Web: https://digital-fabrica.com

## TODOs & Open Questions
- [ ] Automate email setup and verification
- [ ] Update with new addresses and routing rules 