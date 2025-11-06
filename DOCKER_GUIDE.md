# Docker Deployment Guide

## 🐳 Running the Application with Docker

This guide shows how to run the DevSecOps Research Project using Docker for cross-platform deployment.

## 📋 Prerequisites

- **Docker** installed ([Get Docker](https://docs.docker.com/get-docker/))
- **Docker Compose** installed (usually comes with Docker Desktop)

### Verify Installation:
```bash
docker --version
docker-compose --version
```

## 🚀 Quick Start (3 Steps)

### Step 1: Navigate to Project Directory
```bash
cd /home/zackweb/Desktop/DevSecOps-Research-Project
```

### Step 2: Build and Start Containers
```bash
docker-compose up -d --build
```

This command will:
- ✅ Build the PHP/Apache web server image
- ✅ Pull the MariaDB 10.5 database image
- ✅ Create and start both containers
- ✅ Automatically set up the database with sample data
- ✅ Connect the web app to the database

### Step 3: Access the Application
Open your browser and go to:
```
http://localhost:8080/index.php
```

## 🎯 What's Included

The Docker setup includes:

### Services:
1. **web** - PHP 8.2 + Apache web server (port 8080)
2. **db** - MariaDB 10.5 database (port 3306)

### Features:
- ✅ Automatic database initialization with 30 countries
- ✅ Persistent database storage (data survives container restarts)
- ✅ Network isolation between services
- ✅ Health checks for database readiness
- ✅ Volume mounting for live code updates

## 📝 Docker Commands Reference

### Start the Application
```bash
docker-compose up -d
```

### Stop the Application
```bash
docker-compose down
```

### Stop and Remove All Data (including database)
```bash
docker-compose down -v
```

### View Logs
```bash
# All services
docker-compose logs -f

# Web server only
docker-compose logs -f web

# Database only
docker-compose logs -f db
```

### Rebuild Containers (after code changes)
```bash
docker-compose up -d --build
```

### Check Container Status
```bash
docker-compose ps
```

### Access Container Shell
```bash
# Web container
docker-compose exec web bash

# Database container
docker-compose exec db bash
```

### Restart Services
```bash
docker-compose restart
```

## 🔍 Verification

### Test 1: Check Containers are Running
```bash
docker-compose ps
```
You should see both `devsecops-web` and `devsecops-db` as "Up".

### Test 2: Check Database
```bash
docker-compose exec db mysql -u webapp_user -pwebapp_password countries -e "SELECT COUNT(*) FROM countrydata_final;"
```
Should return: 30

### Test 3: Check Web Access
```bash
curl http://localhost:8080/index.php
```
Should return HTML content.

### Test 4: Check Application Logs
```bash
docker-compose logs web | grep "Retrieving settings"
```

## 🌐 Access Points

- **Web Application:** http://localhost:8080/index.php
- **Database (from host):** localhost:3306
  - User: `webapp_user`
  - Password: `webapp_password`
  - Database: `countries`

## 🔧 Configuration

### Database Credentials (docker-compose.yml)

The database credentials are configured in `docker-compose.yml`:

```yaml
environment:
  MYSQL_ROOT_PASSWORD: rootpassword
  MYSQL_DATABASE: countries
  MYSQL_USER: webapp_user
  MYSQL_PASSWORD: webapp_password
```

**To change credentials:**
1. Edit `docker-compose.yml`
2. Update the environment variables under both `db` and `web` services
3. Run: `docker-compose down -v && docker-compose up -d --build`

### Port Configuration

Default ports:
- Web: `8080` → `80` (container)
- Database: `3306` → `3306` (container)

**To change the web port:**
Edit `docker-compose.yml` under `web` service:
```yaml
ports:
  - "9000:80"  # Change 8080 to your desired port
```

## 📂 Project Structure for Docker

```
DevSecOps-Research-Project/
├── Dockerfile                      # Web server image definition
├── docker-compose.yml              # Multi-container orchestration
├── app/                           # Application code (mounted as volume)
│   ├── get-parameters.php         # Auto-detects Docker environment
│   └── ...
├── database/
│   ├── setup_database.sql         # For local/manual setup
│   └── setup_database_docker.sql  # For Docker auto-initialization
└── DOCKER_GUIDE.md                # This file
```

## 🛠️ Troubleshooting

### Containers Won't Start

**Check logs:**
```bash
docker-compose logs
```

**Common issues:**
- Port 8080 already in use → Change port in docker-compose.yml
- Port 3306 already in use → Stop local MySQL/MariaDB or change port

### Database Connection Error

**Check database is ready:**
```bash
docker-compose exec db mysqladmin ping -h localhost
```

**Restart containers:**
```bash
docker-compose restart
```

### Can't See Data in Queries

**Check database has data:**
```bash
docker-compose exec db mysql -u webapp_user -pwebapp_password countries -e "SELECT * FROM countrydata_final LIMIT 5;"
```

**If empty, rebuild:**
```bash
docker-compose down -v
docker-compose up -d --build
```

### Changes Not Reflecting

The `app` directory is mounted as a volume, so changes should reflect immediately. If not:

```bash
docker-compose restart web
```

### Permission Errors

**Fix permissions:**
```bash
docker-compose exec web chown -R www-data:www-data /var/www/html
docker-compose exec web chmod -R 755 /var/www/html
```

## 🔐 Security Notes

### For Production Deployment:

1. **Change default passwords** in `docker-compose.yml`
2. **Use secrets management** instead of plain text passwords
3. **Don't expose database port** (remove `ports` under `db` service)
4. **Use environment files:**

Create `.env` file:
```env
DB_ROOT_PASSWORD=your_secure_root_password
DB_PASSWORD=your_secure_password
WEB_PORT=8080
```

Update docker-compose.yml:
```yaml
environment:
  MYSQL_ROOT_PASSWORD: ${DB_ROOT_PASSWORD}
  MYSQL_PASSWORD: ${DB_PASSWORD}
ports:
  - "${WEB_PORT}:80"
```

## 🌍 Cross-Platform Support

This Docker setup works on:
- ✅ **Linux** (Ubuntu, Debian, CentOS, etc.)
- ✅ **macOS** (with Docker Desktop)
- ✅ **Windows** (with Docker Desktop or WSL2)

### Platform-Specific Notes:

**Windows:**
- Use PowerShell or Command Prompt
- Paths use forward slashes in docker-compose.yml
- Docker Desktop must be running

**macOS:**
- Docker Desktop must be running
- Performance optimized with Docker Desktop for Mac

**Linux:**
- Best performance (native containers)
- No Docker Desktop needed

## 📊 Monitoring

### View Resource Usage
```bash
docker stats
```

### View Container Details
```bash
docker-compose ps
docker inspect devsecops-web
docker inspect devsecops-db
```

## 🔄 Development Workflow

### Making Code Changes:

1. Edit files in `app/` directory
2. Changes are immediately available (volume mounted)
3. Refresh browser to see changes
4. For PHP configuration changes, restart: `docker-compose restart web`

### Database Changes:

1. Edit `database/setup_database_docker.sql`
2. Rebuild database:
   ```bash
   docker-compose down -v
   docker-compose up -d --build
   ```

## 🚢 Deployment Options

### Option 1: Docker Hub
```bash
# Build and tag image
docker build -t your-username/devsecops-app:latest .

# Push to Docker Hub
docker push your-username/devsecops-app:latest
```

### Option 2: Docker Registry
```bash
# Tag for private registry
docker tag devsecops-app:latest registry.example.com/devsecops-app:latest

# Push
docker push registry.example.com/devsecops-app:latest
```

### Option 3: Export/Import
```bash
# Save image
docker save devsecops-app:latest | gzip > devsecops-app.tar.gz

# Load on another machine
gunzip -c devsecops-app.tar.gz | docker load
```

## 🎉 Success Checklist

- [ ] Docker and Docker Compose installed
- [ ] Containers built and running: `docker-compose ps`
- [ ] Web accessible at http://localhost:8080
- [ ] Database has 30 countries
- [ ] All 5 queries working (Mobile, Population, Life Expectancy, GDP, Mortality)
- [ ] No errors in logs: `docker-compose logs`

## 📚 Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [PHP Docker Images](https://hub.docker.com/_/php)
- [MariaDB Docker Images](https://hub.docker.com/_/mariadb)

---

**Ready to deploy anywhere!** 🚀

This Docker setup ensures your application runs consistently across all platforms.
