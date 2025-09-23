# OpsGuardian™ Command Center X (CCX)

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Salesforce API](https://img.shields.io/badge/API-62.0+-blue.svg)](#status--compatibility)
[![CI/CD](https://img.shields.io/badge/CI/CD-GitHub%20Actions-yellow.svg)](.github/workflows)

**A Salesforce-Native Compliance, Security, and AI Monitoring Framework**  
Built for regulated industries, government, and enterprises that demand governance, observability, and proactive remediation on Salesforce.

---

## Status & Compatibility

- **Status:** Production-ready (AppExchange submission in progress)  
- **Version:** 1.0.0  
- **API Version:** Salesforce 62.0+  
- **Supported Orgs:** Scratch, Sandbox, Developer Edition, Production  
- **Limitations:** Slack/Jira plugins shipped as stubs; multi-cloud ingestion planned for v2.0  

---

## Features

- Governor Limits Dashboard – Real-time CPU, SOQL, DML, and heap tracking  
- Flow & Transaction Monitor – Surfacing faulting Flows and heavy transactions  
- AI Diagnostics Tile – GPT + Einstein hybrid anomaly detection and scoring  
- Predictive Alerts – Proactive risk scores via Platform Events  
- Policy-as-Code – Custom Metadata (`OG_Policy__mdt`) for configurable thresholds  
- Remediation Automation – Flow Invocables to auto-rollback or create Jira/Slack tickets  
- Multi-Org Hub-and-Spoke – Secure Apex REST endpoint for cross-org telemetry  
- CI/CD Ready – Jest tests, GitHub Actions pipelines, PMD + sf-scanner integrated  

---

## Architecture & Security

- Managed Package (2GP) structure for AppExchange readiness  
- Permissions: `OpsGuardian_Admin` with least-privilege model  
- Security Enforcement:  
  - `WITH SECURITY_ENFORCED` in all SOQL queries  
  - `Security.stripInaccessible()` on all DML operations  
- Authentication: OAuth 2.0 (JWT / Client Credentials) in Named Credentials; TLS 1.3 required  
- Resilience: Queueable + Batch Apex, circuit breaker patterns, retry/backoff for callouts  
- Accessibility & i18n: LWCs with ARIA labels, text externalized to Custom Labels  

---

## Installation

### Scratch Org (Developer Testing)
```bash
# Authenticate to Dev Hub
sfdx force:auth:web:login -d -a DevHub

# Create a scratch org
sfdx force:org:create -f config/project-scratch-def.json -a OGCCX -d 7

# Push source and assign permissions
sfdx force:source:push
sfdx force:user:permset:assign -n OpsGuardian_Admin

# Launch the Lightning App
sfdx force:org:open -p /lightning/app/OpsGuardian

Sandbox (UAT)
	1.	Use package install link:
Install in Sandbox
	2.	Assign OpsGuardian_Admin permission set.
	3.	Upload Chart.js static resource if dashboards don’t render.

Production (AppExchange)
	•	Once listed: AppExchange Install Link
	•	Supports upgrades via 2GP managed package.

⸻

Upgrade Notes
	•	CMDT Records: Preserved across upgrades.
	•	Custom Objects: OpsGuardian_History__c data retained.
	•	Permission Sets: Updated automatically; review after upgrade.
	•	Flows & Apex: Replaced by new versions; check customizations before upgrade.

⸻

Post-Install Checklist

Step	Description
Upload Chart.js static resource	Required for dashboard charts
Confirm OpsGuardian_History__c object	Schema must match managed package
Verify Platform Event Performance_Alert__e	Ensure deployed and subscribed
Assign OpsGuardian_Admin perm set	Grants access
Adjust thresholds via CMDT	Configure OG_Policy__mdt records
Test AI Diagnostics Tile	Validate OpenAI + Einstein integration


⸻

Screenshots & Architecture

Command Center Dashboard

Real-time governor limit tracking and alerts.

AI Diagnostics Tile

Hybrid AI scoring with remediation options.

Policy Management

Thresholds configurable via Custom Metadata.

High-Level Architecture Diagram

flowchart TD
  subgraph Salesforce Org
    A[OpsGuardian LWC Tiles] --> B[Lightning App Page]
    B --> C[OpsGuardian Apex Services]
    C --> D[OpsGuardian_History__c]
    C --> E[Platform Events]
    C --> F[CMDT: OG_Policy__mdt]
  end
  C -->|Named Credential (JWT)| G[(External AI)]
  C -->|REST API Hub| H[Other Salesforce Orgs]
  C -->|Plugins| I[(Slack/Jira)]


⸻

Roadmap
	•	v1.0: AppExchange package, pilot deployments
	•	v1.1: Slack/Jira plugins, enhanced dashboards, i18n improvements
	•	v2.0: Multi-cloud ingestion + standalone SaaS dashboard

⸻

Running Tests

Apex Unit Tests

sfdx force:apex:test:run --codecoverage --resultformat human --outputdir test-results --wait 10

LWC Jest Tests

npm install
npm test

	•	Target: 95%+ coverage across Apex + LWC
	•	Codecov/coverage badge integration recommended

⸻

Demo Data

Import demo records to see dashboards in action:

# Import sample governor limit history
sfdx force:data:tree:import -p data/OG_History-plan.json

# Import sample flow executions
sfdx force:data:tree:import -p data/OG_Flow-plan.json

Files included:
	•	data/OG_History-plan.json + OG_History.json
	•	data/OG_Flow-plan.json + OG_Flow.json

⸻

CI/CD Example

Minimal GitHub Actions workflow (.github/workflows/deploy.yml):

name: Validate & Deploy

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Install Salesforce CLI
        run: npm install sfdx-cli --global
      - name: Authenticate Dev Hub
        run: sfdx force:auth:sfdxurl:store -f ./auth/devhub.json -a DevHub
      - name: Push Metadata
        run: sfdx force:source:push -u DevHub
      - name: Run Apex Tests
        run: sfdx force:apex:test:run --codecoverage --resultformat human --wait 10
      - name: Static Code Scan
        run: sfdx scanner:run --target force-app --format table


⸻

Compliance Readiness
	•	95%+ Apex coverage target
	•	Jest tests for LWCs
	•	PMD + sf-scanner static analysis
	•	GDPR + SOC 2 data flow docs in /docs/compliance/
	•	Security Review packet prepared: incident response + deletion policies

⸻

Contributing

We welcome contributions:
	•	Fork repo & branch from main
	•	Run all tests (npm test + Apex tests) before PRs
	•	Follow CONTRIBUTING.md and CODE_OF_CONDUCT.md

⸻

License & Support
	•	Licensed under MIT
	•	Maintainer: OpsGuardian Dev Team
	•	Email: security@opsguardian.dev
	•	SLA: Critical <48h | High <5d | Normal = next release cycle

⸻

Appendix

Dependencies
	•	Salesforce CLI (sfdx) v7+
	•	Node.js (for Jest)
	•	Chart.js static resource (for dashboards)
	•	GitHub Actions (for CI/CD)
	•	PMD + sf-scanner (for static analysis)

Developer Resources
	•	Salesforce DX Developer Guide
	•	AppExchange Security Review Guide
	•	Einstein Prediction Builder

Compliance Artifacts
	•	/docs/compliance/data-flow.png – PII flow diagram
	•	/docs/compliance/encryption.md – Shield/TLS details
	•	/docs/compliance/incident-response.md – Triage & escalation policy
	•	/docs/compliance/deletion-policy.md – Data deletion procedures

---

=