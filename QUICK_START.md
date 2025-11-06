# Security Pipeline - Quick Start Guide

## ✅ Zero Configuration Required!

Your security pipeline is **ready to use** with no setup needed.

## What You Get

### Automatic Security Scans
- **SAST** - Semgrep analyzes PHP code
- **IaC** - Trivy scans infrastructure files  
- **SCA** - Trivy checks container vulnerabilities
- **DAST** - OWASP ZAP tests running application

### Where to See Results
1. **GitHub Security Tab**: `Security → Code scanning`
2. **Actions Summary**: Shows vulnerability counts
3. **Downloadable Reports**: HTML, JSON, XML formats

## How to Run

### Automatic (Recommended)
Just push code to `main` or `dev`:
```bash
git add .
git commit -m "Your changes"
git push origin main
```

### Manual Trigger
1. Go to **Actions** tab
2. Click **Security Scan** 
3. Click **Run workflow**
4. Select branch → **Run workflow**

## View Results

**GitHub Security Dashboard:**
```
https://github.com/ABDERRAHMANE2303/DevSecOps-Research-Project/security/code-scanning
```

**Download Reports:**
- Go to Actions → Latest run → Scroll to **Artifacts**
- Download `security-reports-{commit}` or `zap_dast_reports`

## When Pipeline Fails

❌ **Critical vulnerabilities** in container (must fix)
❌ **High-risk DAST** issues (must fix)

Check the Security tab or downloaded reports for details.

## That's It!

No servers, no API tokens, no configuration. Just secure code. 🔒

For advanced options, see the workflow file: `.github/workflows/security-scan.yml`
