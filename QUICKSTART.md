# Quick Start Guide - Running the Application

This guide shows you how to quickly set up and run the DevSecOps Research Project application.

## 📋 Prerequisites

Make sure you have completed the installation from `SETUP_GUIDE.md`:
- ✅ PHP 8.2 installed
- ✅ MariaDB installed and running
- ✅ Apache2 installed and running

## 🚀 Quick Setup (5 Steps)

### Step 1: Set Up the Database

Edit the database password in the SQL script:

```bash
cd /home/zackweb/Desktop/DevSecOps-Research-Project/database
nano setup_database.sql
```

Change this line (around line 15):
```sql
CREATE USER IF NOT EXISTS 'webapp_user'@'localhost' IDENTIFIED BY 'your_password';
```

Replace `'your_password'` with a strong password (remember it!), then save (Ctrl+X, Y, Enter).

Run the database setup script:

```bash
sudo mysql -u root -p < setup_database.sql
```

Enter your MySQL root password when prompted.

### Step 2: Configure the Application

Edit the database credentials directly in the `get-parameters.php` file:

```bash
cd /home/zackweb/Desktop/DevSecOps-Research-Project/app
nano get-parameters.php
```

Find the `catch (Exception $e)` block (around line 75-80) and update the credentials:

```php
catch (Exception $e) {
  $ep = 'localhost';           # Database host
  $db = 'countries';           # Database name
  $un = 'webapp_user';         # Database user
  $pw = 'your_actual_password'; # Change this to your actual password!
}
```

Replace `'your_actual_password'` with the **same password** you used in Step 1.

Save the file (Ctrl+X, Y, Enter).

### Step 3: Copy Files to Web Server

```bash
sudo cp -r /home/zackweb/Desktop/DevSecOps-Research-Project/app/* /var/www/html/
```

Set proper permissions:

```bash
sudo chown -R www-data:www-data /var/www/html/
sudo chmod -R 755 /var/www/html/
```

### Step 4: Restart Services

```bash
sudo systemctl restart apache2
sudo systemctl restart mariadb
```

Verify services are running:

```bash
sudo systemctl status apache2
sudo systemctl status mariadb
```

Both should show "active (running)" in green.

### Step 5: Test the Application

Open your web browser and go to:

```
http://localhost/index.php
```

Or from another computer on your network:

```
http://YOUR_SERVER_IP/index.php
```

## ✅ Testing the Queries

1. Click on **"Query"** in the navigation menu
2. Select a query type from the dropdown:
   - Mobile phones
   - Population
   - Life Expectancy
   - GDP
   - Mortality
3. Click the submit button
4. You should see a table with data for 30 countries

## 🔍 Verify Everything is Working

### Test 1: Check PHP Configuration

```bash
php -v
php -m | grep mysqli
```

You should see PHP 8.2.x and mysqli listed.

### Test 2: Check Database Connection

```bash
mysql -u webapp_user -p countries -e "SELECT COUNT(*) FROM countrydata_final;"
```

Should return: 30

### Test 3: Check Apache is Serving PHP

```bash
curl http://localhost/index.php | head -20
```

Should see HTML output.

### Test 4: Check Credentials Configuration

```bash
grep -A 5 "catch (Exception" /var/www/html/get-parameters.php
```

Should show your configured credentials in the catch block.

## 🛠️ Troubleshooting

### Error: "Access denied for user"

Database credentials in `get-parameters.php` don't match the database user.

**Fix:**
```bash
# Edit the credentials file
sudo nano /var/www/html/get-parameters.php

# Find the catch block and update:
# $pw = 'your_correct_password';

# Test database login
mysql -u webapp_user -p countries

# If password is wrong, reset it in database:
sudo mysql -u root -p
```
```sql
ALTER USER 'webapp_user'@'localhost' IDENTIFIED BY 'new_password';
FLUSH PRIVILEGES;
EXIT;
```

Then update `get-parameters.php` with the new password.

### Error: "Connection error" or blank page

**Check Apache error log:**
```bash
sudo tail -f /var/log/apache2/error.log
```

**Check PHP error display:**
```bash
sudo nano /etc/php/8.2/apache2/php.ini
```
Set: `display_errors = On`

Then restart:
```bash
sudo systemctl restart apache2
```

### No data showing in queries

**Check if database has data:**
```bash
mysql -u webapp_user -p countries -e "SELECT * FROM countrydata_final LIMIT 5;"
```

If empty, re-run the database setup script.

### Permission errors

**Reset file permissions:**
```bash
sudo chown -R www-data:www-data /var/www/html/
sudo chmod -R 755 /var/www/html/
sudo chmod 600 /var/www/html/.env
```

## 📝 Configuration Explained

The `get-parameters.php` file handles database credentials:

- **For AWS Production:** Fetches credentials from AWS Secrets Manager (lines 1-73)
- **For Local Development:** Uses hardcoded values in the `catch` block (lines 75-80)

When running locally, the AWS connection fails (expected), and it falls back to your local credentials in the catch block:

```php
catch (Exception $e) {
  $ep = 'localhost';      # Your database host
  $db = 'countries';      # Your database name
  $un = 'webapp_user';    # Your database username
  $pw = 'your_password';  # Your database password - CHANGE THIS!
}
```

## 🔐 Security Best Practices

1. **Use strong passwords:**
   - At least 12 characters
   - Mix of letters, numbers, and symbols

2. **Restrict file permissions:**
   ```bash
   chmod 644 /var/www/html/get-parameters.php
   ```

3. **For production, use AWS Secrets Manager** instead of hardcoded credentials

## 🌐 Accessing from Other Computers

### Find Your Server IP:

```bash
ip addr show | grep "inet " | grep -v 127.0.0.1
```

### Configure Firewall:

```bash
sudo ufw allow 'Apache Full'
sudo ufw enable
```

### Access from Browser:

```
http://YOUR_SERVER_IP/index.php
```

## 🔄 How the Configuration Works

1. **get-parameters.php** handles all database credentials
2. It first tries to connect to AWS Secrets Manager (for production)
3. If AWS connection fails (local development), it uses the hardcoded values in the `catch` block
4. **query2.php** includes `get-parameters.php` to get credentials
5. All query files (mobile.php, population.php, etc.) use the variables: `$ep`, `$db`, `$un`, `$pw`

## 📂 File Structure

```
/var/www/html/
├── get-parameters.php     # Database credentials (edit the catch block)
├── index.php              # Home page
├── query.php              # Query selection
├── query2.php             # Query processor
├── mobile.php             # Mobile phones query
├── population.php         # Population query
├── lifeexpectancy.php     # Life expectancy query
├── gdp.php               # GDP query
├── mortality.php         # Mortality query
└── style.css             # Styles
```

## 🎯 Summary Commands

```bash
# Setup database
cd /home/zackweb/Desktop/DevSecOps-Research-Project/database
nano setup_database.sql  # Edit password
sudo mysql -u root -p < setup_database.sql

# Configure app
cd /home/zackweb/Desktop/DevSecOps-Research-Project/app
nano get-parameters.php  # Edit the catch block with your credentials

# Deploy
sudo cp -r /home/zackweb/Desktop/DevSecOps-Research-Project/app/* /var/www/html/
sudo chown -R www-data:www-data /var/www/html/

# Restart services
sudo systemctl restart apache2 mariadb

# Test
curl http://localhost/index.php
```

## 🎉 Success!

If you can see the home page and run queries successfully, congratulations! Your application is now running.

For detailed installation instructions, see `SETUP_GUIDE.md`.

For database details, see `database/README.md`.
