# DefectDojo Setup Guide - Security Findings Centralization

## 📋 What is DefectDojo?

**DefectDojo** is an open-source vulnerability management platform that centralizes security findings from multiple scanning tools into a single dashboard.

### Why Use DefectDojo?

✅ **Centralized Dashboard** - All security findings in one place  
✅ **Deduplication** - Automatically merges duplicate findings  
✅ **Tracking & Metrics** - Track vulnerabilities over time  
✅ **Risk Prioritization** - Focus on critical issues first  
✅ **Reporting** - Generate compliance and executive reports  
✅ **Integration** - Supports 100+ security tools  

### Tools Integrated in This Project:
- ✅ Semgrep (SAST)
- ✅ Trivy (Container/SCA)
- ✅ Gitleaks (Secrets)
- ✅ OWASP ZAP (DAST)

---

## 🚀 Quick Start

### Option 1: Local Setup with Docker Compose (Recommended)

#### 1. Start DefectDojo
```bash
cd /path/to/DevSecOps-Research-Project
docker-compose up -d
```

This will start:
- ✅ Application (web + database)
- ✅ DefectDojo platform
- ✅ PostgreSQL (DefectDojo database)
- ✅ Redis (task queue)
- ✅ Celery workers (background jobs)

#### 2. Wait for Initialization (First Time Only)
```bash
# Check DefectDojo logs
docker-compose logs -f defectdojo

# Wait for this message:
# "Django initialization complete"
```

**First startup takes 2-3 minutes** to initialize the database.

#### 3. Access DefectDojo
Open browser: **http://localhost:8000**

**Default Credentials:**
- Username: `admin`
- Password: `admin`

**⚠️ IMPORTANT**: Change the password immediately after first login!

#### 4. Verify Services
```bash
docker-compose ps
```

Expected output:
```
NAME                        STATUS
defectdojo                  running (healthy)
defectdojo-celery-beat      running
defectdojo-celery-worker    running
defectdojo-postgres         running
defectdojo-redis            running
devsecops-web               running (healthy)
devsecops-db                running (healthy)
```

---

## 🔧 DefectDojo Configuration

### 1. **Change Default Password**
1. Login at http://localhost:8000
2. Click user icon (top right) → **Profile**
3. Click **Change Password**
4. Set a strong password

### 2. **Generate API Key** (For CI/CD Integration)

#### Step 1: Navigate to API Key Settings
1. Login to DefectDojo
2. Click user icon (top right) → **API v2 Key**

#### Step 2: Generate New Key
1. Click **Generate Key** button
2. Copy the API key (you won't see it again!)
3. Save it securely

Example API key:
```
Token a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0
```

### 3. **Configure Product** (First Time Setup)

DefectDojo organizes findings by **Products** and **Engagements**.

#### Manual Setup:
1. Navigate to **Products** → **Add Product**
2. Fill in details:
   - **Name**: `DevSecOps-Research-Project`
   - **Description**: `PHP web application with security pipeline`
   - **Product Type**: Select or create "Web Application"
3. Click **Submit**

#### Automatic Setup:
The GitHub Actions workflow will auto-create the product on first run!

---

## 🔗 GitHub Actions Integration

### Setup GitHub Secrets & Variables

#### Step 1: Add DefectDojo URL
1. Go to GitHub repository
2. **Settings** → **Secrets and variables** → **Actions**
3. Click **Variables** tab → **New repository variable**
4. Name: `DEFECTDOJO_URL`
5. Value: `http://your-defectdojo-server:8000` (or public URL if deployed)
6. Click **Add variable**

#### Step 2: Add API Key
1. Still in **Secrets and variables** → **Actions**
2. Click **Secrets** tab → **New repository secret**
3. Name: `DEFECTDOJO_API_KEY`
4. Value: Paste your API key from DefectDojo
5. Click **Add secret**

### Workflow Integration

The workflow automatically uploads findings to DefectDojo after each scan!

**File**: `.github/workflows/secure-ci.yml`

```yaml
- name: Upload to DefectDojo
  if: env.DEFECTDOJO_URL != ''
  env:
    DEFECTDOJO_URL: ${{ vars.DEFECTDOJO_URL }}
    DEFECTDOJO_API_KEY: ${{ secrets.DEFECTDOJO_API_KEY }}
  run: |
    # Uploads all scan results automatically
```

**What gets uploaded**:
- ✅ Semgrep SARIF results
- ✅ Trivy vulnerability scan
- ✅ Gitleaks secrets scan
- ✅ OWASP ZAP DAST results

---

## 📊 Using DefectDojo Dashboard

### 1. **View All Findings**

#### Navigate to Product
1. Login to DefectDojo
2. **Products** → **DevSecOps-Research-Project**
3. Click **View Findings**

### 2. **Filter Findings**

**By Severity:**
- Critical (red)
- High (orange)
- Medium (yellow)
- Low (blue)
- Info (gray)

**By Tool:**
- Semgrep
- Trivy Scan
- Gitleaks
- ZAP Scan

**By Status:**
- Active
- Verified
- False Positive
- Risk Accepted
- Mitigated

### 3. **View Finding Details**

Click any finding to see:
- **Description** - What the vulnerability is
- **Severity** - Risk level
- **Mitigation** - How to fix it
- **References** - CVE, CWE links
- **Affected Files** - Where the issue is
- **Scanner** - Which tool found it

### 4. **Manage Findings**

**Mark as False Positive:**
1. Open finding
2. Click **Edit**
3. Check **False Positive**
4. Add justification
5. Click **Submit**

**Accept Risk:**
1. Open finding
2. Click **Accept Risk**
3. Add justification and expiration date
4. Click **Submit**

**Mark as Mitigated:**
1. Open finding
2. Click **Close**
3. Select **Mitigated**
4. Add notes
5. Click **Submit**

### 5. **Generate Reports**

#### Executive Report:
1. **Products** → **DevSecOps-Research-Project**
2. Click **View Metrics**
3. Click **Generate Report**
4. Select report type (PDF, CSV, HTML)

#### Compliance Report:
1. **Products** → **DevSecOps-Research-Project**
2. **Engagements** → Select engagement
3. Click **Generate Report**
4. Choose compliance framework (OWASP, PCI-DSS, etc.)

---

## 📈 Metrics & Dashboards

### Product Metrics

**Navigate to**: Products → DevSecOps-Research-Project → Metrics

**Available Metrics:**
- ✅ Total findings by severity
- ✅ Findings trend over time
- ✅ Top 10 vulnerabilities
- ✅ Mean time to remediate
- ✅ Findings by scanner
- ✅ Age of open findings

### Custom Dashboards

1. Navigate to **Metrics** → **Dashboard**
2. Click **Add Widget**
3. Choose visualization:
   - Pie chart (findings by severity)
   - Line chart (findings over time)
   - Bar chart (findings by product)
   - Table (top vulnerabilities)

---

## 🔄 Workflow: CI/CD to DefectDojo

```
┌──────────────────────────────────────────────────────────┐
│         GitHub Actions Pipeline Runs                     │
│  (Triggered on push/PR to main)                          │
└──────────────────────────────────────────────────────────┘
                        ↓
┌──────────────────────────────────────────────────────────┐
│      Security Tools Execute                              │
│  • Semgrep, Trivy, Gitleaks, ZAP                         │
│  • Generate SARIF/JSON reports                           │
└──────────────────────────────────────────────────────────┘
                        ↓
┌──────────────────────────────────────────────────────────┐
│      Upload to DefectDojo                                │
│  • Create/find product                                   │
│  • Create new engagement                                 │
│  • Upload all scan results                               │
└──────────────────────────────────────────────────────────┘
                        ↓
┌──────────────────────────────────────────────────────────┐
│      DefectDojo Processing                               │
│  • Parse scan results                                    │
│  • Deduplicate findings                                  │
│  • Assign severity & risk                                │
│  • Update metrics                                        │
└──────────────────────────────────────────────────────────┘
                        ↓
┌──────────────────────────────────────────────────────────┐
│      View in Dashboard                                   │
│  • All findings centralized                              │
│  • Track remediation progress                            │
│  • Generate reports                                      │
└──────────────────────────────────────────────────────────┘
```

---

## 🛠️ Manual Upload (Testing)

### Upload via Web UI

1. Login to DefectDojo
2. **Engagements** → **Add Engagement**
3. Fill in details:
   - Name: `Manual Test Scan`
   - Product: `DevSecOps-Research-Project`
   - Target Start/End: Today's date
4. Click **Submit**
5. In engagement page, click **Import Scan Results**
6. Select:
   - **Scan Type**: (e.g., "Semgrep JSON Report", "Trivy Scan")
   - **File**: Browse and upload SARIF/JSON file
7. Click **Import**

### Upload via API (Manual Testing)

```bash
# Set variables
DD_URL="http://localhost:8000"
DD_API_KEY="your-api-key-here"
ENGAGEMENT_ID="1"

# Upload Trivy results
curl -X POST "${DD_URL}/api/v2/import-scan/" \
  -H "Authorization: Token ${DD_API_KEY}" \
  -F "engagement=${ENGAGEMENT_ID}" \
  -F "scan_type=Trivy Scan" \
  -F "file=@trivy-results.sarif"

# Upload Semgrep results
curl -X POST "${DD_URL}/api/v2/import-scan/" \
  -H "Authorization: Token ${DD_API_KEY}" \
  -F "engagement=${ENGAGEMENT_ID}" \
  -F "scan_type=Semgrep JSON Report" \
  -F "file=@semgrep-results.sarif"

# Upload ZAP results
curl -X POST "${DD_URL}/api/v2/import-scan/" \
  -H "Authorization: Token ${DD_API_KEY}" \
  -F "engagement=${ENGAGEMENT_ID}" \
  -F "scan_type=ZAP Scan" \
  -F "file=@report_json.json"
```

---

## 🐛 Troubleshooting

### Issue: DefectDojo Won't Start

**Check logs:**
```bash
docker-compose logs defectdojo
```

**Common causes:**
1. **Port 8000 already in use**
   ```bash
   # Check what's using port 8000
   netstat -ano | findstr :8000  # Windows
   lsof -i :8000                  # Linux/Mac
   
   # Change port in docker-compose.yml:
   ports:
     - "8001:8080"  # Use port 8001 instead
   ```

2. **Database not initialized**
   ```bash
   # Restart DefectDojo
   docker-compose restart defectdojo
   
   # Wait 2-3 minutes for initialization
   ```

3. **Insufficient memory**
   ```bash
   # Increase Docker memory to at least 4GB
   # Docker Desktop → Settings → Resources → Memory
   ```

### Issue: Upload to DefectDojo Fails in GitHub Actions

**Check:**
1. **Variables configured?**
   - Go to: Settings → Secrets and variables → Actions
   - Verify `DEFECTDOJO_URL` exists in Variables
   - Verify `DEFECTDOJO_API_KEY` exists in Secrets

2. **DefectDojo accessible from GitHub?**
   - If running locally: GitHub Actions can't reach localhost!
   - **Solution**: Deploy DefectDojo to a public server or use ngrok

3. **API key valid?**
   - Login to DefectDojo
   - Regenerate API key if needed

### Issue: Findings Not Appearing

**Check:**
1. **Scan type correct?**
   - DefectDojo has specific scan type names
   - Use exact names: "Trivy Scan", "Semgrep JSON Report", "ZAP Scan"

2. **File format correct?**
   - Trivy/Semgrep: Must be SARIF format
   - ZAP: Must be JSON format

3. **Engagement active?**
   - Check engagement status is "In Progress" or "Completed"

---

## 📦 Production Deployment

### Deploy DefectDojo to Cloud

**Recommended Options:**

#### 1. **AWS EC2 + Docker**
```bash
# SSH into EC2 instance
ssh -i key.pem ec2-user@your-instance-ip

# Clone repo
git clone https://github.com/ABDERRAHMANE2303/DevSecOps-Research-Project.git
cd DevSecOps-Research-Project

# Start only DefectDojo services
docker-compose up -d defectdojo defectdojo-postgres defectdojo-redis defectdojo-celery-beat defectdojo-celery-worker

# Access via public IP
# http://your-ec2-public-ip:8000
```

#### 2. **DigitalOcean Droplet**
Same as AWS EC2 above

#### 3. **Kubernetes (Advanced)**
Use official DefectDojo Helm chart:
```bash
helm repo add defectdojo https://raw.githubusercontent.com/DefectDojo/django-DefectDojo/helm-charts
helm install defectdojo defectdojo/defectdojo
```

### Security Considerations for Production

**⚠️ IMPORTANT: Update these before production!**

1. **Change Secret Keys**
   ```yaml
   DD_SECRET_KEY: "Generate-Strong-Random-Key-Here"
   DD_CREDENTIAL_AES_256_KEY: "Exactly32CharactersForEncryption"
   ```

2. **Change Default Password**
   - Login and change admin password immediately

3. **Use HTTPS**
   - Add reverse proxy (Nginx) with SSL certificate
   - Use Let's Encrypt for free SSL

4. **Restrict Access**
   - Set `DD_ALLOWED_HOSTS` to your domain only
   - Use firewall rules to limit access

5. **Backup Database**
   ```bash
   # Backup DefectDojo PostgreSQL
   docker exec defectdojo-postgres pg_dump -U defectdojo defectdojo > defectdojo_backup.sql
   ```

---

## 📸 Screenshots for Documentation

### DefectDojo Screenshots to Take:

#### 1. **Dashboard Overview**
**File**: `screenshots/defectdojo-1-dashboard.png`  
**Show**: Main dashboard with product overview and metrics

#### 2. **Product Findings List**
**File**: `screenshots/defectdojo-2-findings-list.png`  
**Show**: List of all findings with severity colors

#### 3. **Finding Details**
**File**: `screenshots/defectdojo-3-finding-detail.png`  
**Show**: Individual finding with description, severity, mitigation

#### 4. **Metrics Dashboard**
**File**: `screenshots/defectdojo-4-metrics.png`  
**Show**: Charts showing findings over time, by severity, by tool

#### 5. **Engagement View**
**File**: `screenshots/defectdojo-5-engagement.png`  
**Show**: CI/CD engagement with scan results uploaded

#### 6. **API Upload Success**
**File**: `screenshots/defectdojo-6-upload-success.png`  
**Show**: GitHub Actions log showing successful upload to DefectDojo

---

## 🎯 Quick Reference

### Common Commands

```bash
# Start all services (app + DefectDojo)
docker-compose up -d

# Start only DefectDojo
docker-compose up -d defectdojo defectdojo-postgres defectdojo-redis defectdojo-celery-beat defectdojo-celery-worker

# View DefectDojo logs
docker-compose logs -f defectdojo

# Restart DefectDojo
docker-compose restart defectdojo

# Stop all services
docker-compose down

# Remove all data (CAUTION!)
docker-compose down -v
```

### Important URLs

- **DefectDojo UI**: http://localhost:8000
- **Application**: http://localhost:8080
- **DefectDojo API**: http://localhost:8000/api/v2/

### Default Credentials

- **Username**: admin
- **Password**: admin (⚠️ Change immediately!)

---

## 📚 Additional Resources

- **DefectDojo Documentation**: https://documentation.defectdojo.com/
- **DefectDojo GitHub**: https://github.com/DefectDojo/django-DefectDojo
- **API Documentation**: http://localhost:8000/api/v2/doc/
- **Supported Scanners**: https://documentation.defectdojo.com/integrations/parsers/

---

## ✅ Summary

DefectDojo provides:
- ✅ **Centralized vulnerability management**
- ✅ **Automatic deduplication**
- ✅ **Historical tracking**
- ✅ **Risk prioritization**
- ✅ **Compliance reporting**
- ✅ **CI/CD integration**

**Result**: Professional-grade vulnerability management for your DevSecOps pipeline! 🚀
