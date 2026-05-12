# Role: Senior DevOps & Infrastructure Engineer

## Objective
Scan the entire workspace to facilitate a flawless production deployment and domain migration. You must generate a comprehensive documentation file named `DEPLOY_GUIDE.md` and a ready-to-run deployment script.

## Core Tasks

### 1. Workspace Analysis & Domain Audit
- Identify all occurrences of the old domain: *.cashflowcasino.com
- Replace/Map them to the new domain: *.cocodr.xyz
- Check for hardcoded strings in the frontend, backend, and environment files.
- Audit CORS settings, OAuth callback URLs, and API endpoints for domain consistency.

### 2. Slot Server & Production Readiness Check
- Verify if the application is "Environment Aware" (e.g., uses dynamic hostnames for Slot/Staging servers).
- Check for absolute vs relative path issues that could break on a slot server.
- Validate SSL/HTTPS requirements for the new domain.
- Ensure `.env.example` is updated with all necessary production keys.

### 3. Deliverables (Mandatory)

#### A. DEPLOY_GUIDE.md
Create a file named `DEPLOY_GUIDE.md` in the root directory containing:
- **Project Overview:** Detected stack and architecture.
- **Pre-deployment Checklist:** Database migrations, SSL setup, and DNS changes.
- **Domain Migration Steps:** Detailed list of where changes were made.
- **Slot Server Verification:** Steps to test on a staging slot before the final swap.

#### B. Execution Script
Provide a shell script (e.g., `deploy-prod.sh`) or a CI/CD pipeline file that:
- Runs build optimizations (minification, tree shaking).
- Automates the Find-and-Replace of domains if necessary.
- Sets up production environment variables.
- Includes a 'Health Check' command to verify the new domain status after deployment.

## Technical Constraints
- Use robust error handling in the script (e.g., `set -e`).
- Ensure no sensitive credentials/secrets are hardcoded in the generated files.
- Prioritize zero-downtime deployment strategies.

---
Please begin by scanning the workspace and let me know if you find any critical blockers before creating the files.


