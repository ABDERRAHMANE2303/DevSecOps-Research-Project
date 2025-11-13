# DevSecOps Research Project - Comprehensive Documentation

## 📋 Table of Contents
1. [Project Overview](#project-overview)
2. [Application Architecture](#application-architecture)
3. [Docker Configuration](#docker-configuration)
4. [CI/CD Security Pipeline](#cicd-security-pipeline)
5. [Security Tools Overview](#security-tools-overview)
6. [DefectDojo - Centralized Vulnerability Management](#defectdojo---centralized-vulnerability-management)
7. [Security Findings & Results](#security-findings--results)
8. [Screenshots & Evidence](#screenshots--evidence)
9. [How to Run](#how-to-run)

---

## 🎯 Project Overview

This project demonstrates a **comprehensive DevSecOps pipeline** for a PHP web application. The application was manually **containerized using Docker** with security best practices, and integrated with a **multi-layered security scanning pipeline** using GitHub Actions.

### Key Achievements
✅ **Manually dockerized** PHP/Apache/MySQL application  
✅ **Zero Docker misconfigurations** (verified by Trivy config scan)  
✅ **Non-root user execution** for enhanced container security  
✅ **Automated security scanning** across 8+ tools  
✅ **SARIF integration** with GitHub Code Scanning  
✅ **Multi-stage security analysis**: SAST, DAST, SCA, Secrets, IaC  
✅ **DefectDojo integration** for centralized vulnerability management  

### Technology Stack
- **Application**: PHP 8.2, Apache, MySQL
- **Containerization**: Docker, Docker Compose
- **CI/CD**: GitHub Actions
- **Security Tools**: 8+ industry-standard tools (detailed below)
- **Vulnerability Management**: DefectDojo platform

---

## 🏗️ Application Architecture

### Components
```
┌─────────────────────────────────────────────────────────────┐
│                     GitHub Actions CI/CD                    │
│  (Automated Security Scanning on Every Push/PR)             │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                    Docker Environment                        │
│  ┌─────────────────────┐     ┌──────────────────────┐      │
│  │   Web Container     │────▶│   Database Container │      │
│  │  - PHP 8.2          │     │  - MariaDB 10.5      │      │
│  │  - Apache           │     │  - Countries DB      │      │
│  │  - Port 8080        │     │  - Port 3306         │      │
│  │  - Non-root (www)   │     │  - Persistent Volume │      │
│  └─────────────────────┘     └──────────────────────┘      │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │             DefectDojo Platform                       │  │
│  │  - Vulnerability Management Dashboard                 │  │
│  │  - PostgreSQL Database                                │  │
│  │  - Redis & Celery Workers                             │  │
│  │  - Port 8000                                          │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### Application Features
- **Country Data Queries**: GDP, Population, Life Expectancy, Mobile Phones, Mortality
- **Database**: MySQL with pre-loaded world statistics
- **Web Interface**: PHP-based query forms and result tables
- **Security Dashboard**: DefectDojo centralized vulnerability tracking

---

## 🐳 Docker Configuration

### Dockerfile - Security Hardened

**Key Security Features Implemented:**

#### 1. **Non-Root User Execution** ✅
```dockerfile
# Configure Apache to run on port 8080 (non-privileged port)
RUN sed -i 's/Listen 80/Listen 8080/' /etc/apache2/ports.conf

# Set proper permissions for www-data user
RUN chown -R www-data:www-data /var/www/html

# Switch to non-root user
USER www-data
```
**Why**: Running as non-root prevents privilege escalation attacks.

#### 2. **Health Checks** ✅
```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/ || exit 1
```
**Why**: Enables container orchestration to detect and restart unhealthy containers.

#### 3. **Minimal Attack Surface** ✅
```dockerfile
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*
```
**Why**: Only essential packages installed, reducing vulnerability exposure.

#### 4. **Non-Privileged Port** ✅
```dockerfile
EXPOSE 8080  # Instead of 80
```
**Why**: Ports below 1024 require root privileges; 8080 allows non-root execution.

### docker-compose.yml - Production Ready

**Security Hardening Applied:**

#### 1. **Security Options**
```yaml
security_opt:
  - no-new-privileges:true  # Prevents privilege escalation
```

#### 2. **Resource Isolation**
```yaml
tmpfs:
  - /tmp  # Temporary files in memory, not persistent
```

#### 3. **Health Monitoring**
```yaml
healthcheck:
  test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
  interval: 10s
  retries: 10
```

#### 4. **Network Segmentation**
```yaml
networks:
  app-network:
    driver: bridge  # Isolated network for containers
```

#### 5. **Restart Policies**
```yaml
restart: unless-stopped  # Auto-restart on failure
```

### Trivy Config Scan Results: **0 Misconfigurations** ✅

Our Docker configuration passed all Trivy checks with **zero misconfigurations**, demonstrating:
- ✅ Proper user configuration
- ✅ Health checks implemented
- ✅ Security options applied
- ✅ Best practices followed

---

## 🔄 CI/CD Security Pipeline

### Pipeline Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Trigger: Push/PR to main                 │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│              Stage 1: Code Quality & SAST                   │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │ PHPStan  │  │ Semgrep  │  │ PHPCS    │  │ Composer │   │
│  │ (Types)  │  │(Security)│  │ (Style)  │  │  Audit   │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│            Stage 2: Container & Dependency Scan             │
│  ┌────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │   Trivy    │  │    Trivy     │  │   Hadolint   │       │
│  │  (Image)   │  │   (Config)   │  │ (Dockerfile) │       │
│  └────────────┘  └──────────────┘  └──────────────┘       │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│              Stage 3: Secrets & IaC Scanning                │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────┐         │
│  │ Gitleaks │  │  tfsec   │  │  ansible-lint    │         │
│  │(Secrets) │  │(Terraform│  │   (Ansible)      │         │
│  └──────────┘  └──────────┘  └──────────────────┘         │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│               Stage 4: Dynamic Application Scan             │
│  ┌────────────────────────────────────────────────────┐    │
│  │              OWASP ZAP DAST                        │    │
│  │  - Builds & runs application container             │    │
│  │  - Active vulnerability scanning                   │    │
│  │  - Spider & AJAX spider                            │    │
│  └────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│            Stage 5: Results Upload & Reporting              │
│  ┌────────────────────────────────────────────────────┐    │
│  │  - Upload SARIF to GitHub Code Scanning            │    │
│  │  - Generate security summary report                │    │
│  │  - Archive all reports as artifacts                │    │
│  └────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

### Workflow Configuration

**File**: `.github/workflows/secure-ci.yml`

**Triggers**:
- Push to `main` branch
- Pull requests to `main` branch

**Permissions**:
```yaml
permissions:
  contents: read
  actions: read
  security-events: write  # Required for SARIF uploads
```

**Concurrency Control**:
```yaml
concurrency:
  group: ${{ github.ref }}
  cancel-in-progress: true  # Cancel old runs on new pushes
```

---

## 🛡️ Security Tools Overview

### 1. **PHPStan** - Static Analysis for PHP

**Category**: Code Quality / Type Safety  
**What it does**: Analyzes PHP code for type errors, undefined variables, and logic issues  
**Why we use it**: Catches bugs before runtime, improves code reliability  

**Configuration**:
```yaml
phpstan analyse --level=max --error-format=json app
```

**What it detects**:
- ✅ Type mismatches
- ✅ Undefined variables
- ✅ Method calls on wrong types
- ✅ Invalid array access

**Example Finding**:
```
Cannot access offset 'username' on mixed.
Variable $db might not be defined.
```

**Integration**: Results converted to SARIF and uploaded to GitHub Code Scanning

---

### 2. **Semgrep** - SAST (Static Application Security Testing)

**Category**: Security Vulnerability Detection  
**What it does**: Scans source code for security vulnerabilities and anti-patterns  
**Why we use it**: Identifies security issues in PHP code (SQL injection, XSS, etc.)  

**Configuration**:
```yaml
semgrep scan \
  --config "p/security-audit"    # General security rules
  --config "p/php"               # PHP-specific rules
  --config "p/owasp-top-ten"     # OWASP Top 10 vulnerabilities
  --config "p/cwe-top-25"        # CWE Top 25 dangerous errors
  --config ".semgrep.yml"        # Custom project rules
```

**Custom Rules Created**:
1. **Password in Logs** - Detects credentials being logged
2. **Hardcoded Credentials** - Finds hardcoded passwords
3. **Sensitive Data Exposure** - Catches error disclosure via var_dump()
4. **Unvalidated Input** - Identifies missing input validation

**What it detects**:
- ✅ SQL Injection patterns
- ✅ Cross-Site Scripting (XSS)
- ✅ Command Injection
- ✅ Insecure file operations
- ✅ Hardcoded secrets
- ✅ Authentication issues

**Integration**: SARIF output uploaded to GitHub Security tab

---

### 3. **PHPCS** - PHP Code Sniffer

**Category**: Code Quality / Style  
**What it does**: Enforces PSR-12 coding standards  
**Why we use it**: Maintains consistent code style across the project  

**Configuration**:
```yaml
phpcs --standard=PSR12 app
```

**What it checks**:
- ✅ Indentation and spacing
- ✅ Naming conventions
- ✅ File structure
- ✅ Best practices

---

### 4. **Composer Audit** - Dependency Vulnerability Scanner

**Category**: Software Composition Analysis (SCA)  
**What it does**: Checks PHP dependencies for known vulnerabilities  
**Why we use it**: Ensures third-party packages don't introduce vulnerabilities  

**Configuration**:
```yaml
composer audit --no-interaction
```

**What it detects**:
- ✅ Vulnerable package versions
- ✅ Security advisories
- ✅ Recommended updates

---

### 5. **Trivy** - Container & Vulnerability Scanner

**Category**: Container Security / SCA  
**What it does**: Multi-purpose security scanner for containers, filesystems, and configs  
**Why we use it**: Industry-standard tool for container security  

**Three Scan Types**:

#### a. **Trivy Image Scan**
```yaml
trivy image --scanners vuln --severity CRITICAL,HIGH
```
**Detects**:
- ✅ OS package vulnerabilities (Debian/Alpine)
- ✅ Application dependency vulnerabilities
- ✅ CVE tracking with severity ratings

**Results**: ~142 vulnerabilities (mostly base image)

#### b. **Trivy Config Scan**
```yaml
trivy config --format sarif
```
**Detects**:
- ✅ Dockerfile misconfigurations
- ✅ Docker Compose security issues
- ✅ Missing health checks
- ✅ Running as root user

**Results**: **0 misconfigurations** ✅ (perfect score!)

#### c. **Trivy Filesystem Scan**
```yaml
trivy fs --scanners vuln
```
**Fallback** when Docker not available

**Integration**: Uses `.trivyignore` to filter false positives (kernel CVEs)

---

### 6. **Hadolint** - Dockerfile Linter

**Category**: Infrastructure as Code (IaC)  
**What it does**: Lints Dockerfiles for best practices and common mistakes  
**Why we use it**: Ensures Dockerfile follows best practices  

**Configuration**:
```yaml
hadolint /d/Dockerfile
```

**What it checks**:
- ✅ Layer optimization
- ✅ Package manager best practices
- ✅ COPY vs ADD usage
- ✅ Deprecated instructions
- ✅ Security recommendations

---

### 7. **Gitleaks** - Secrets Detection

**Category**: Secrets Scanning  
**What it does**: Scans for hardcoded secrets, API keys, passwords in code  
**Why we use it**: Prevents credential leakage in version control  

**Configuration**:
```yaml
gitleaks detect --no-git --redact=0
```

**What it detects**:
- ✅ API keys (AWS, GCP, Azure)
- ✅ Database credentials
- ✅ Private keys
- ✅ Access tokens
- ✅ Generic passwords

**Integration**: JSON results converted to SARIF for GitHub

---

### 8. **OWASP ZAP** - DAST (Dynamic Application Security Testing)

**Category**: Runtime Security Testing  
**What it does**: Tests the **running application** for vulnerabilities  
**Why we use it**: Detects vulnerabilities that only appear at runtime  

**How it works**:
1. **Builds** Docker image from source
2. **Starts** application container
3. **Waits** for health check (container ready)
4. **Scans** running application on http://localhost:8080
5. **Tests** for OWASP Top 10 vulnerabilities

**Configuration**:
```yaml
zap-full-scan.py \
  -t http://localhost:8080 \
  -a -j                      # AJAX spider + active scan
  -T 30                      # 30 minute timeout
```

**What it detects**:
- ✅ SQL Injection
- ✅ Cross-Site Scripting (XSS)
- ✅ Security Misconfigurations
- ✅ Broken Authentication
- ✅ Sensitive Data Exposure
- ✅ XXE (XML External Entities)
- ✅ Broken Access Control
- ✅ CSRF (Cross-Site Request Forgery)

**Results**: ~92 findings (OWASP Top 10 vulnerabilities)

**Integration**: Generates multiple report formats (JSON, HTML, XML, Markdown)

---

### 9. **tfsec** - Terraform Security Scanner

**Category**: Infrastructure as Code (IaC)  
**What it does**: Scans Terraform configurations for security issues  
**Why we use it**: Ensures infrastructure code is secure  

**Configuration**:
```yaml
tfsec /src/infrastructure/terraform --format sarif
```

**What it detects**:
- ✅ Unencrypted resources
- ✅ Open security groups
- ✅ Public S3 buckets
- ✅ Missing logging
- ✅ Weak encryption

**Status**: Infrastructure files currently empty (prepared for future use)

---

### 10. **ansible-lint** - Ansible Playbook Linter

**Category**: Infrastructure as Code (IaC)  
**What it does**: Validates Ansible playbooks for best practices  
**Why we use it**: Ensures configuration management code quality  

**Configuration**:
```yaml
ansible-lint ansible -p
```

**What it checks**:
- ✅ Deprecated modules
- ✅ Best practices
- ✅ YAML syntax
- ✅ Security recommendations

**Status**: Infrastructure files currently empty (prepared for future use)

---

## 🎯 DefectDojo - Centralized Vulnerability Management

### What is DefectDojo?

**DefectDojo** is an open-source Application Vulnerability Management platform that **centralizes all security findings** from multiple tools into a single, unified dashboard.

### Why We Use DefectDojo

In this project, we run **8+ security tools** (Semgrep, Trivy, ZAP, Gitleaks, etc.), each generating separate reports. Managing findings across multiple tools becomes challenging. DefectDojo solves this by:

✅ **Centralized Dashboard** - All findings from all tools in one place  
✅ **Automatic Deduplication** - Merges duplicate findings across tools  
✅ **Historical Tracking** - Track vulnerability trends over time  
✅ **Risk Prioritization** - Focus on critical issues first  
✅ **Workflow Management** - Assign, track, and close findings  
✅ **Compliance Reporting** - Generate reports for audits  
✅ **Metrics & Analytics** - Visualize security posture  

### DefectDojo Integration

```
┌──────────────────────────────────────────────────────┐
│         GitHub Actions Workflow                      │
│  Run all security scans (Semgrep, Trivy, ZAP...)    │
└──────────────────────────────────────────────────────┘
                        ↓
┌──────────────────────────────────────────────────────┐
│     Generate Reports (SARIF/JSON)                    │
│  • semgrep-results.sarif                             │
│  • trivy-results.sarif                               │
│  • gitleaks-results.sarif                            │
│  • report_json.json (ZAP)                            │
└──────────────────────────────────────────────────────┘
                        ↓
┌──────────────────────────────────────────────────────┐
│     Upload to DefectDojo via API                     │
│  • Auto-create product & engagement                  │
│  • Import all scan results                           │
│  • Deduplicate findings                              │
└──────────────────────────────────────────────────────┘
                        ↓
┌──────────────────────────────────────────────────────┐
│     View in DefectDojo Dashboard                     │
│  http://localhost:8000                               │
│  • All findings centralized                          │
│  • Filter by severity, tool, status                  │
│  • Track remediation progress                        │
│  • Generate compliance reports                       │
└──────────────────────────────────────────────────────┘
```

### Quick Start with DefectDojo

#### 1. Start DefectDojo (Included in docker-compose)
```bash
docker-compose up -d
```

This starts:
- ✅ Application containers (web + db)
- ✅ DefectDojo platform
- ✅ PostgreSQL (DefectDojo database)
- ✅ Redis & Celery workers

#### 2. Access DefectDojo
**URL**: http://localhost:8000  
**Default Login**:
- Username: `admin`
- Password: `admin` (⚠️ change immediately!)

#### 3. Configure GitHub Actions Integration

**Add GitHub Secrets** (for automatic upload):
1. Login to DefectDojo → User Icon → **API v2 Key** → **Generate**
2. Copy the API key
3. In GitHub: **Settings** → **Secrets and variables** → **Actions**
4. Add **Variable**: `DEFECTDOJO_URL` = `http://your-server:8000`
5. Add **Secret**: `DEFECTDOJO_API_KEY` = `<your-api-key>`

Now GitHub Actions will automatically upload findings after each scan!

### DefectDojo Features

| Feature | Description |
|---------|-------------|
| **Dashboard** | Overview of all findings with severity breakdown |
| **Products** | Organize findings by application/project |
| **Engagements** | Group findings by scan date/release |
| **Findings** | Detailed view with CVE links, descriptions, mitigation |
| **Metrics** | Charts showing trends, MTTR, top vulnerabilities |
| **Reports** | Export compliance reports (PDF, CSV, JSON) |
| **API** | RESTful API for automation and integration |
| **Deduplication** | Automatically merges duplicate findings |
| **SLA Tracking** | Monitor time to fix critical vulnerabilities |

### Supported Scanners in Our Pipeline

DefectDojo natively supports parsers for all our tools:

| Tool | DefectDojo Parser | Format |
|------|-------------------|--------|
| Semgrep | `Semgrep JSON Report` | SARIF |
| Trivy | `Trivy Scan` | SARIF |
| Gitleaks | `Gitleaks Scan` | SARIF |
| OWASP ZAP | `ZAP Scan` | JSON |
| PHPStan | `Generic Findings Import` | SARIF |

### Example DefectDojo Workflow

1. **Developer pushes code** → GitHub Actions triggered
2. **Security scans run** → 8+ tools execute
3. **Results uploaded** → DefectDojo receives all findings
4. **Deduplication** → Removes duplicate vulnerabilities
5. **Dashboard updated** → Team sees centralized view
6. **Assignment** → Security team assigns critical findings
7. **Tracking** → Monitor remediation progress
8. **Verification** → Re-scan confirms fixes
9. **Reporting** → Generate metrics for management

### DefectDojo vs GitHub Code Scanning

| Feature | DefectDojo | GitHub Code Scanning |
|---------|------------|----------------------|
| **Centralized Dashboard** | ✅ Yes | ⚠️ Separate tabs per tool |
| **Deduplication** | ✅ Automatic | ❌ No |
| **Historical Tracking** | ✅ Full history | ✅ Limited |
| **Metrics & Charts** | ✅ Comprehensive | ⚠️ Basic |
| **Compliance Reports** | ✅ Yes (PDF/CSV) | ❌ No |
| **SLA Tracking** | ✅ Yes | ❌ No |
| **Multi-Tool View** | ✅ Unified | ❌ Separate |
| **Self-Hosted** | ✅ Yes | ❌ No |

**Recommendation**: Use **both**!
- GitHub Code Scanning for developer-friendly PR comments
- DefectDojo for security team management and reporting

### Screenshot Locations

See `DEFECTDOJO_SETUP.md` for:
- ✅ Complete installation guide
- ✅ Configuration steps
- ✅ API integration tutorial
- ✅ Troubleshooting guide
- ✅ Production deployment tips

---

## 📊 Security Findings & Results

### Summary Table

| Tool | Category | Findings | Status |
|------|----------|----------|--------|
| **PHPStan** | Static Analysis | 10 | Type errors, undefined variables |
| **Semgrep** | SAST | 0-5 | Clean code (custom rules detect 3-5) |
| **Trivy (Image)** | Container SCA | 142 | Base image vulnerabilities (2 critical) |
| **Trivy (Config)** | IaC | **0** ✅ | **Zero misconfigurations!** |
| **Gitleaks** | Secrets | Varies | Environment-dependent |
| **OWASP ZAP** | DAST | 92 | Runtime vulnerabilities |
| **Hadolint** | IaC | 0-2 | Dockerfile best practices |
| **tfsec** | IaC | 0 | No Terraform code yet |
| **ansible-lint** | IaC | 0 | No Ansible code yet |

### Key Highlights

#### ✅ **Successes**

1. **Perfect Docker Configuration** - 0 Trivy config issues
2. **Non-Root Container** - Security best practice implemented
3. **Health Checks** - Container monitoring enabled
4. **Security Hardening** - no-new-privileges, tmpfs, restart policies
5. **Clean SAST** - No classic vulnerabilities (SQL injection, XSS in code)

#### ⚠️ **Areas for Improvement**

1. **Base Image Vulnerabilities** (142 CVEs)
   - **Mitigation**: Switch to Alpine base (50-70% reduction)
   - **Current**: Using `.trivyignore` for false positives

2. **DAST Findings** (92 issues from ZAP)
   - **Type**: OWASP Top 10 vulnerabilities
   - **Mitigation**: Implement input validation, output encoding, security headers

3. **PHPStan Errors** (10 issues)
   - **Type**: Type safety and undefined variables
   - **Impact**: Code quality, not security-critical
   - **Mitigation**: Add type hints and validate variable initialization

### Trivy Vulnerability Breakdown

```
Total: 142 vulnerabilities
├── CRITICAL: 2
│   ├── CVE-2025-7458 (SQLite integer overflow)
│   └── CVE-2025-6020 (Linux-PAM directory traversal)
├── HIGH: ~140
│   ├── Applicable: ~20-30 (library vulnerabilities)
│   └── Not Applicable: ~110 (kernel CVEs, filtered by .trivyignore)
└── MEDIUM: Not scanned (reduced noise)
```

**Why So Many?**
- Using Debian Bookworm base image (full OS with 200+ packages)
- Many CVEs are kernel-related (not exploitable in containers)
- Hardware-specific issues (AMD/Intel CPU bugs)
- Display drivers (not used in headless server)

**Solutions Applied**:
- Created `.trivyignore` to filter 15-20 false positives
- Only scanning CRITICAL and HIGH (not MEDIUM)
- Documented accepted risks

---

## 📸 Screenshots & Evidence

### Screenshot Locations & What to Include

#### 1. **GitHub Actions Workflow Run**
**File**: `screenshots/1-github-actions-workflow.png`  
**What to show**:
- ✅ All jobs passing (green checkmarks)
- ✅ Workflow run time
- ✅ All security scan steps completed

#### 2. **Security Summary Table**
**File**: `screenshots/2-security-summary.png`  
**What to show**:
```
🔒 Security Scan Summary
Total Security Findings: XXX

| Tool | Scope | Findings |
|------|-------|----------|
| PHPStan | PHP Static Analysis | 10 |
| Semgrep | PHP SAST Security | X |
| Trivy | Image/FS vulns | 142 |
| Trivy (config) | Docker/Compose | 0 ✅ |
| ... | ... | ... |
```

#### 3. **GitHub Code Scanning Alerts**
**File**: `screenshots/3-code-scanning-alerts.png`  
**What to show**:
- Security tab → Code scanning alerts
- List of all findings from all tools
- Severity breakdown (Critical, High, Medium, Low)

#### 4. **Trivy Config Scan - Zero Issues**
**File**: `screenshots/4-trivy-config-zero-issues.png`  
**What to show**:
- Trivy config scan results showing **0 misconfigurations**
- Proof that Docker setup is secure
- "No vulnerabilities found" message

#### 5. **Trivy Image Scan Results**
**File**: `screenshots/5-trivy-image-scan.png`  
**What to show**:
- 142 vulnerabilities breakdown
- CRITICAL and HIGH severity counts
- Package names with CVEs

#### 6. **OWASP ZAP DAST Report**
**File**: `screenshots/6-zap-dast-results.png`  
**What to show**:
- ZAP HTML report summary
- 92 findings
- Risk severity breakdown (High, Medium, Low)
- Example vulnerabilities detected

#### 7. **Semgrep SAST Findings**
**File**: `screenshots/7-semgrep-findings.png`  
**What to show**:
- Semgrep scan output
- Custom rules triggered
- Code snippets with issues highlighted

#### 8. **PHPStan Static Analysis**
**File**: `screenshots/8-phpstan-errors.png`  
**What to show**:
- 10 PHPStan errors
- File paths and line numbers
- Type errors and undefined variables

#### 9. **Docker Container Running (Non-Root)**
**File**: `screenshots/9-docker-non-root.png`  
**What to show**:
```bash
docker exec devsecops-web whoami
# Output: www-data (NOT root!)
```

#### 10. **Application Screenshot**
**File**: `screenshots/10-application-running.png`  
**What to show**:
- Application homepage at http://localhost:8080
- Query form working
- Database connection successful
- Sample data displayed

#### 11. **Docker Compose Services**
**File**: `screenshots/11-docker-compose-services.png`  
**What to show**:
```bash
docker-compose ps
# Both containers healthy
```

#### 12. **Security Reports Artifacts**
**File**: `screenshots/12-artifacts-download.png`  
**What to show**:
- GitHub Actions artifacts section
- security-reports.zip available for download
- All SARIF files included

#### 13. **DefectDojo Dashboard Overview**
**File**: `screenshots/13-defectdojo-dashboard.png`  
**What to show**:
- DefectDojo main dashboard at http://localhost:8000
- Product overview with total findings
- Severity breakdown chart
- Findings by scanner visualization

#### 14. **DefectDojo Findings List**
**File**: `screenshots/14-defectdojo-findings.png`  
**What to show**:
- Complete list of findings from all tools
- Color-coded by severity (Critical=red, High=orange, etc.)
- Filter options (by tool, severity, status)
- Centralized view of all security issues

#### 15. **DefectDojo Finding Detail**
**File**: `screenshots/15-defectdojo-detail.png`  
**What to show**:
- Individual finding details
- CVE/CWE references
- Mitigation recommendations
- Affected file/component
- Scanner that found it

#### 16. **DefectDojo Metrics Dashboard**
**File**: `screenshots/16-defectdojo-metrics.png`  
**What to show**:
- Findings over time (trend chart)
- Top 10 vulnerabilities
- Findings by severity (pie chart)
- Mean time to remediate (MTTR)

#### 17. **DefectDojo Engagement View**
**File**: `screenshots/17-defectdojo-engagement.png`  
**What to show**:
- CI/CD engagement showing automated uploads
- Multiple scan results imported
- Scan date and engagement status

#### 18. **DefectDojo GitHub Actions Upload**
**File**: `screenshots/18-defectdojo-upload-logs.png`  
**What to show**:
- GitHub Actions workflow logs
- "Upload to DefectDojo" step successful
- Confirmation messages showing findings uploaded
- DefectDojo engagement URL

---

## 🚀 How to Run

### Prerequisites
- Docker Desktop installed
- Git installed
- Docker Compose installed

### Local Development

#### 1. **Clone Repository**
```bash
git clone https://github.com/ABDERRAHMANE2303/DevSecOps-Research-Project.git
cd DevSecOps-Research-Project
```

#### 2. **Start Application**
```bash
docker-compose up -d
```

This starts:
- ✅ Web application (PHP/Apache)
- ✅ MariaDB database
- ✅ DefectDojo platform (vulnerability management)
- ✅ PostgreSQL (DefectDojo database)
- ✅ Redis & Celery workers (DefectDojo background tasks)

**First startup**: DefectDojo initialization takes 2-3 minutes.

#### 3. **Verify Containers**
```bash
docker-compose ps
```

Expected output:
```
NAME                        COMMAND                  SERVICE                  STATUS              PORTS
devsecops-db                "docker-entrypoint.s…"   db                       running (healthy)   0.0.0.0:3307->3306/tcp
devsecops-web               "apache2-foreground"     web                      running (healthy)   0.0.0.0:8080->8080/tcp
defectdojo                  "uwsgi --ini /etc/uw…"   defectdojo               running (healthy)   0.0.0.0:8000->8080/tcp
defectdojo-postgres         "docker-entrypoint.s…"   defectdojo-postgres      running             5432/tcp
defectdojo-redis            "docker-entrypoint.s…"   defectdojo-redis         running             6379/tcp
defectdojo-celery-beat      "celery -A dojo beat…"   defectdojo-celery-beat   running             
defectdojo-celery-worker    "celery -A dojo work…"   defectdojo-celery-worker running             
```

#### 4. **Access Services**

**Application**: http://localhost:8080  
- PHP web interface with country data queries

**DefectDojo**: http://localhost:8000  
- Username: `admin`
- Password: `admin` (⚠️ Change after first login!)

#### 5. **Verify DefectDojo Ready**
```bash
# Check DefectDojo logs
docker-compose logs defectdojo | grep "Django initialization"

# Should see: "Django initialization complete"
```

#### 6. **First Time Setup - DefectDojo**

1. Login to DefectDojo (http://localhost:8000)
2. Change default password:
   - Click user icon → **Profile** → **Change Password**
3. Generate API key (for CI/CD integration):
   - Click user icon → **API v2 Key** → **Generate**
   - Save the key securely

#### 7. **Verify Non-Root Execution**
```bash
docker exec devsecops-web whoami
```
Expected output: `www-data` (NOT root!)

#### 8. **View Logs**
```bash
# Application logs
docker-compose logs -f web
docker-compose logs -f db

# DefectDojo logs
docker-compose logs -f defectdojo
```

#### 9. **Stop Services**
```bash
# Stop all services
docker-compose down

# Stop and remove volumes (⚠️ deletes all data)
docker-compose down -v
```

### Using DefectDojo

#### View Uploaded Findings

After running GitHub Actions pipeline:

1. Go to http://localhost:8000
2. Navigate to **Products** → **DevSecOps-Research-Project**
3. Click **View Findings**
4. See all security findings from all tools in one place!

#### Manual Upload to DefectDojo

If you want to manually upload scan results:

1. Run scans locally (see below)
2. Login to DefectDojo
3. **Products** → **DevSecOps-Research-Project** → **Engagements**
4. Click **Import Scan Results**
5. Select scanner type and upload SARIF/JSON file

---

### Running Security Scans Locally

#### Run Trivy Image Scan
```bash
docker build -t myapp:local .
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy:latest image --severity CRITICAL,HIGH myapp:local
```

#### Run Trivy Config Scan
```bash
docker run --rm -v "$(pwd)":/w aquasec/trivy:latest config .
```

#### Run Semgrep
```bash
pip install semgrep
semgrep --config "p/php" --config "p/owasp-top-ten" app/
```

#### Run PHPStan
```bash
composer install
vendor/bin/phpstan analyse --level=max app/
```

#### Run PHPCS
```bash
vendor/bin/phpcs --standard=PSR12 app/
```

---

## 🏆 Project Achievements Summary

### Security Implementation
✅ **Non-root container execution** - Enhanced security posture  
✅ **Health checks** - Container reliability monitoring  
✅ **Security hardening** - no-new-privileges, tmpfs, network isolation  
✅ **Zero Docker misconfigurations** - Verified by Trivy  
✅ **Multi-layered scanning** - 8+ security tools integrated  

### DevSecOps Pipeline
✅ **Automated security scanning** - Every push triggers full scan  
✅ **SARIF integration** - Results in GitHub Code Scanning  
✅ **Custom security rules** - Project-specific vulnerability detection  
✅ **Comprehensive reporting** - Multiple formats (SARIF, JSON, HTML)  
✅ **CI/CD best practices** - Caching, concurrency control, artifacts  

### Documentation
✅ **Detailed README** - Complete tool explanations  
✅ **Security findings** - Transparent vulnerability disclosure  
✅ **Remediation guides** - Clear mitigation strategies  
✅ **Screenshot guidelines** - Evidence collection framework  

---

## 📚 Additional Resources

### Related Documentation
- `DEFECTDOJO_SETUP.md` - **Complete DefectDojo installation and configuration guide**
- `SCAN_SUMMARY.md` - Before/after security scan comparison
- `SECURITY_FINDINGS.md` - Detailed vulnerability analysis
- `TRIVY_723_ANALYSIS.md` - Explanation of Trivy findings
- `VULNERABILITY_REDUCTION_GUIDE.md` - Mitigation strategies
- `QUICK_START.md` - Quick setup guide

### Security Tool Documentation
- [DefectDojo](https://documentation.defectdojo.com/) - Vulnerability management platform
- [Trivy](https://aquasecurity.github.io/trivy/) - Container scanner
- [Semgrep](https://semgrep.dev/) - SAST tool
- [OWASP ZAP](https://www.zaproxy.org/) - DAST scanner
- [Gitleaks](https://github.com/gitleaks/gitleaks) - Secrets detection
- [PHPStan](https://phpstan.org/) - PHP static analysis

---

## 👥 Project Team

**Author**: Meryem Elfadili (elfadilimeryem03@gmail.com)  
**Repository**: [DevSecOps-Research-Project](https://github.com/ABDERRAHMANE2303/DevSecOps-Research-Project)  
**Date**: November 2025  

---

## 📄 License

See `app/LICENSE` for details.

---

## 🎓 Learning Outcomes

This project demonstrates:
1. **Container Security** - Proper Docker configuration and hardening
2. **DevSecOps Integration** - Security embedded in CI/CD pipeline
3. **Multi-Tool Security Scanning** - Comprehensive vulnerability detection
4. **Centralized Vulnerability Management** - DefectDojo for unified tracking
5. **Risk Management** - Understanding and mitigating security findings
6. **Industry Best Practices** - Following OWASP, CWE, and Docker standards
7. **Automated Security Pipeline** - CI/CD with security gates

**Result**: A production-ready DevSecOps pipeline with security-first approach and professional vulnerability management! 🔒
