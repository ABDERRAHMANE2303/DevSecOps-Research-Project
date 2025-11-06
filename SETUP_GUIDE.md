# DevSecOps Research Project - Setup Guide

## 📋 Table of Contents
- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [System Requirements](#system-requirements)
- [Installation Steps](#installation-steps)
- [Database Setup](#database-setup)
  - [Using the SQL Script](#step-3-create-database-and-user-using-sql-script)
- [Application Configuration](#application-configuration)
- [Starting the Application](#starting-the-application)
- [Verification](#verification)
- [Troubleshooting](#troubleshooting)
- [Project Structure](#project-structure)

---

## 🎯 Overview

This is a PHP-based social research web application that provides data queries for countries worldwide, including demographics and development statistics. The application uses:
- **PHP 8.2** - Backend scripting language
- **MariaDB 10.5** - Database server (MySQL equivalent)
- **Apache HTTP Server** - Web server
- **AWS Services** (optional) - For cloud deployment with RDS and Secrets Manager

---

## 🔧 Prerequisites

Before you begin, ensure you have:
- A Ubuntu system (20.04 LTS or higher recommended)
- Root or sudo access
- Internet connection for downloading packages
- Basic knowledge of Linux command line

---

## 💻 System Requirements

- **Operating System**: Ubuntu 20.04 LTS or higher
- **PHP**: Version 8.2 or higher
- **MariaDB**: Version 10.5 or higher
- **Web Server**: Apache HTTP Server (apache2)
- **Memory**: Minimum 1GB RAM
- **Disk Space**: At least 2GB free space

---

## 📦 Installation Steps

### Step 1: Update System Packages

```bash
sudo apt update
sudo apt upgrade -y
```

This updates all system packages to their latest versions.

### Step 2: Install PHP 8.2

First, add the PHP repository:

```bash
sudo apt install -y software-properties-common
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update
```

Install PHP 8.2 and common extensions:

```bash
sudo apt install -y php8.2 php8.2-cli php8.2-common
```

Verify PHP installation:
```bash
php -v
```

### Step 3: Install MariaDB Server

```bash
sudo apt install -y mariadb-server mariadb-client
```

### Step 4: Install PHP MySQL Extension

```bash
sudo apt install -y php8.2-mysqli
```

This enables PHP to communicate with the MariaDB/MySQL database.

### Step 5: Install Apache HTTP Server

```bash
sudo apt install -y apache2
```

### Step 6: Install Additional PHP Extensions (Recommended)

```bash
sudo apt install -y php8.2-curl php8.2-json php8.2-xml php8.2-mbstring libapache2-mod-php8.2
```

---

## 🗄️ Database Setup

### Step 1: Start MariaDB Service

```bash
sudo systemctl start mariadb
sudo systemctl enable mariadb
```

### Step 2: Secure MariaDB Installation

```bash
sudo mysql_secure_installation
```

Follow the prompts:
- Set root password (remember this!)
- Remove anonymous users: **Y**
- Disallow root login remotely: **Y**
- Remove test database: **Y**
- Reload privilege tables: **Y**

### Step 3: Create Database and User Using SQL Script

The project includes a ready-to-use SQL script that sets up everything automatically.

**Option A: Run the SQL Script (Recommended)**

First, edit the password in the SQL script:

```bash
nano /home/zackweb/Desktop/DevSecOps-Research-Project/database/setup_database.sql
```

Find the line:
```sql
CREATE USER IF NOT EXISTS 'webapp_user'@'localhost' IDENTIFIED BY 'your_password';
```

Replace `'your_password'` with a strong password (keep the quotes), then save and exit (Ctrl+X, Y, Enter).

Now run the script:

```bash
sudo mysql -u root -p < /home/zackweb/Desktop/DevSecOps-Research-Project/database/setup_database.sql
```

Enter your MariaDB root password when prompted. The script will:
- Create the `countries` database
- Create the `webapp_user` with your chosen password
- Create the `countrydata_final` table
- Insert 30 sample countries with data
- Display confirmation and sample data

**Option B: Manual Setup (Alternative)**

If you prefer to set up manually, connect to MySQL:

```bash
sudo mysql -u root -p
```

Enter your root password, then run these SQL commands:

```sql
-- Create the database
CREATE DATABASE countries;

-- Create a database user (change 'your_password' to a strong password)
CREATE USER 'webapp_user'@'localhost' IDENTIFIED BY 'your_password';

-- Grant privileges
GRANT ALL PRIVILEGES ON countries.* TO 'webapp_user'@'localhost';

-- Apply changes
FLUSH PRIVILEGES;

-- Switch to the database
USE countries;

-- Create the table
CREATE TABLE countrydata_final (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    mobilephones INT,
    population BIGINT,
    lifeexpectancy DECIMAL(5,2),
    gdp DECIMAL(15,2),
    mortality DECIMAL(5,2)
);

-- Exit MySQL
EXIT;
```

Then you can import the sample data:

```bash
mysql -u webapp_user -p countries < /home/zackweb/Desktop/DevSecOps-Research-Project/database/setup_database.sql
```

### Step 4: Verify Database Setup

Check that the database was created successfully:

```bash
mysql -u webapp_user -p countries -e "SELECT COUNT(*) AS total_countries FROM countrydata_final;"
```

You should see that 30 countries were inserted.

---

## ⚙️ Application Configuration

### Step 1: Copy Application Files

Copy the `app` folder contents to the Apache web root:

```bash
sudo cp -r /home/zackweb/Desktop/DevSecOps-Research-Project/app/* /var/www/html/
```

### Step 2: Set Proper Permissions

```bash
sudo chown -R www-data:www-data /var/www/html/
sudo chmod -R 755 /var/www/html/
```

### Step 3: Configure Database Connection

The application uses AWS services by default. For local development without AWS, you need to modify the database connection.

**Option A: Use Local Database (Recommended for local development)**

Create a new file `/var/www/html/local-config.php`:

```bash
sudo nano /var/www/html/local-config.php
```

Add this content (replace with your actual database credentials):

```php
<?php
// Local database configuration
$ep = 'localhost';
$db = 'countries';
$un = 'webapp_user';
$pw = 'your_password';  // Replace with your actual password
?>
```

Then modify each query file (mobile.php, population.php, etc.) to include this config instead of `get-parameters.php`:

```bash
# For local development, comment out AWS parameters
sudo sed -i 's/include '\''get-parameters.php'\'';/\/\/ include '\''get-parameters.php'\'';\ninclude '\''local-config.php'\'';/' /var/www/html/query2.php
```

**Option B: Use AWS Services (For production deployment)**

The application is configured to use:
- AWS RDS for database
- AWS Secrets Manager for credentials
- EC2 Instance Metadata Service

You'll need to:
1. Deploy the application on an EC2 instance
2. Create an RDS MariaDB instance
3. Store credentials in AWS Secrets Manager
4. Configure IAM roles and policies

### Step 4: Configure SELinux (if enabled)

**Note:** Ubuntu uses AppArmor instead of SELinux by default. Usually no additional configuration is needed, but if you have issues, you can check AppArmor status:

```bash
sudo aa-status
```

If you need to allow Apache database connections and are using AppArmor:

```bash
# Check if AppArmor is blocking Apache
sudo aa-complain /etc/apparmor.d/usr.sbin.apache2
```

### Step 5: Configure Firewall (UFW)

```bash
sudo ufw allow 'Apache'
sudo ufw allow 'Apache Full'
sudo ufw enable
sudo ufw status
```

---

## 🚀 Starting the Application

### Step 1: Enable Apache to Start on Boot

```bash
sudo systemctl enable apache2
sudo systemctl enable mariadb
```

### Step 2: Start Apache Service

```bash
sudo systemctl start apache2
sudo systemctl start mariadb
```

### Step 3: Check Service Status

```bash
sudo systemctl status apache2
sudo systemctl status mariadb
```

Both services should show as "active (running)".

---

## ✅ Verification

### Test 1: Check Apache is Running

```bash
curl http://localhost
```

You should see HTML content.

### Test 2: Access the Application

Open a web browser and navigate to:
- Local: `http://localhost/index.php`
- Remote: `http://your-server-ip/index.php`

### Test 3: Test Database Connection

```bash
mysql -u webapp_user -p countries -e "SELECT COUNT(*) FROM countrydata_final;"
```

### Test 4: Run a Query

1. Go to the home page
2. Click on "Query"
3. Select a query type (e.g., "Mobile phones")
4. Click "Run Query"
5. You should see data displayed in a table

---

## 🔍 Troubleshooting

### Apache Won't Start

**Check error logs:**
```bash
sudo tail -f /var/log/apache2/error.log
```

**Common fixes:**
```bash
# Check configuration syntax
sudo apache2ctl configtest

# Check if port 80 is already in use
sudo netstat -tulpn | grep :80
# Or use ss command
sudo ss -tulpn | grep :80
```

### Database Connection Errors

**Test database connection:**
```bash
mysql -u webapp_user -p -h localhost countries
```

**Check MariaDB is running:**
```bash
sudo systemctl status mariadb
```

**View PHP errors:**
Add to `/etc/php/8.2/apache2/php.ini`:
```ini
display_errors = On
error_reporting = E_ALL
```

Then restart Apache:
```bash
sudo systemctl restart apache2
```

### Permission Denied Errors

```bash
sudo chown -R www-data:www-data /var/www/html/
sudo chmod -R 755 /var/www/html/
```

### 404 Not Found

Check that files are in the correct location:
```bash
ls -la /var/www/html/
```

### PHP Not Processing

```bash
# Verify PHP module is loaded
php -m | grep mysqli

# Check if PHP module is enabled in Apache
sudo a2enmod php8.2

# Restart Apache
sudo systemctl restart apache2
```

### Can't See Error Messages

Enable PHP error display temporarily:
```bash
sudo sed -i 's/display_errors = Off/display_errors = On/' /etc/php/8.2/apache2/php.ini
sudo systemctl restart apache2
```

---

## 📁 Project Structure

```
DevSecOps-Research-Project/
├── app/
│   ├── index.php              # Home page
│   ├── query.php              # Query selection page
│   ├── query2.php             # Query processor
│   ├── query3.php             # Additional queries
│   ├── get-parameters.php     # AWS parameter retrieval (for production)
│   ├── mobile.php             # Mobile phones query
│   ├── population.php         # Population query
│   ├── lifeexpectancy.php     # Life expectancy query
│   ├── gdp.php                # GDP query
│   ├── mortality.php          # Mortality query
│   ├── menu.php               # Navigation menu
│   ├── style.css              # Stylesheets
│   └── README.md              # AWS SDK documentation
├── database/
│   └── setup_database.sql     # Database setup script
├── infrastructure/
│   ├── ansible/
│   │   └── inventory.yml      # Ansible inventory
│   └── terraform/
│       └── main.tf            # Terraform configuration
├── .github/
│   └── pipeline.yml           # CI/CD pipeline
└── SETUP_GUIDE.md             # This setup guide
```

---

## 🌐 Application Features

The application provides queries for:
1. **Mobile Phones** - Number of mobile phone providers per country
2. **Population** - Population statistics
3. **Life Expectancy** - Average life expectancy data
4. **GDP** - Gross Domestic Product figures
5. **Mortality** - Mortality rates

---

## 🔐 Security Recommendations

1. **Change Default Passwords**: Never use default or weak passwords
2. **Limit Database Access**: Only allow localhost connections for development
3. **Keep Software Updated**: Regularly update PHP, MariaDB, and Apache
4. **Use HTTPS**: Configure SSL/TLS certificates for production
5. **Input Validation**: Review PHP code for SQL injection vulnerabilities
6. **File Permissions**: Ensure web files are not writable by the web server
7. **Disable Directory Listing**: Add `Options -Indexes` to Apache config

---

## 📚 Additional Resources

- [PHP Documentation](https://www.php.net/docs.php)
- [MariaDB Documentation](https://mariadb.org/documentation/)
- [Apache HTTP Server Documentation](https://httpd.apache.org/docs/)
- [AWS PHP SDK](https://docs.aws.amazon.com/sdk-for-php/)

---

## 🆘 Getting Help

If you encounter issues:
1. Check the error logs: `/var/log/apache2/error.log`
2. Enable PHP error display (see Troubleshooting section)
3. Verify all services are running
4. Check database connectivity
5. Review file permissions

---

## 📝 Quick Reference Commands

```bash
# Database setup - Run the SQL script
sudo mysql -u root -p < /home/zackweb/Desktop/DevSecOps-Research-Project/database/setup_database.sql

# Verify database setup
mysql -u webapp_user -p countries -e "SELECT COUNT(*) FROM countrydata_final;"

# View sample data
mysql -u webapp_user -p countries -e "SELECT * FROM countrydata_final LIMIT 5;"

# Restart all services
sudo systemctl restart apache2 mariadb

# View logs
sudo tail -f /var/log/apache2/error.log
sudo tail -f /var/log/mysql/error.log

# Check status
sudo systemctl status apache2
sudo systemctl status mariadb

# Test PHP
php -v
php -m

# Test database connection
mysql -u webapp_user -p countries
```

---

**Last Updated**: November 6, 2025
