# 🎯 Configuration & Credentials Setup - Summary

## What You Need to Know

Your project uses the existing `get-parameters.php` file for database credentials - **no new PHP files needed!**

## 📁 Files You'll Edit

### 1. **`get-parameters.php`** (app/get-parameters.php)
Edit the `catch` block with your database credentials:

```php
catch (Exception $e) {
  $ep = 'localhost';           // Database host
  $db = 'countries';           // Database name  
  $un = 'webapp_user';         // Database username
  $pw = 'your_password';       // CHANGE THIS!
}
```

### 2. **`setup_database.sql`** (database/setup_database.sql)
Edit line 15 to set the database user password (must match the password in get-parameters.php)

## 🔄 How It Works

The `get-parameters.php` file:

1. **Lines 1-73:** Tries to connect to AWS Secrets Manager (for production on AWS)
2. **Lines 75-80:** Falls back to local credentials in `catch` block when AWS unavailable
3. **Result:** Sets variables `$ep`, `$db`, `$un`, `$pw` that all queries use

When running locally, the AWS connection fails (expected behavior), and it uses your hardcoded values.

## 🚀 How to Run Your Application

### Quick Version (Copy-Paste Ready):

```bash
# 1. Setup database
cd /home/zackweb/Desktop/DevSecOps-Research-Project/database
nano setup_database.sql  # Change password on line 15
sudo mysql -u root -p < setup_database.sql

# 2. Configure app
cd /home/zackweb/Desktop/DevSecOps-Research-Project/app
nano get-parameters.php  # Edit catch block (around line 75) with your password

# 3. Deploy to web server
sudo cp -r /home/zackweb/Desktop/DevSecOps-Research-Project/app/* /var/www/html/
sudo chown -R www-data:www-data /var/www/html/

# 4. Restart services
sudo systemctl restart apache2 mariadb

# 5. Open browser
# Go to: http://localhost/index.php
```

### Detailed Version:

See **`QUICKSTART.md`** for detailed step-by-step instructions with troubleshooting.

## 🔐 Security Features

1. **Local credentials** - Stored in existing PHP file's catch block
2. **AWS production** - Uses AWS Secrets Manager (no hardcoded credentials)
3. **`.gitignore`** - Already configured to protect sensitive files
4. **File permissions** - Standard web server permissions

## 📊 Database Schema

The `countrydata_final` table includes:

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key (auto-increment) |
| name | VARCHAR(255) | Country name |
| mobilephones | INT | Number of mobile phone providers |
| population | BIGINT | Total population |
| populationurban | BIGINT | Urban population |
| birthrate | DECIMAL(5,2) | Birth rate per 1000 |
| lifeexpectancy | DECIMAL(5,2) | Life expectancy in years |
| gdp | DECIMAL(15,2) | GDP in millions |
| mortality | DECIMAL(5,2) | Mortality rate per 1000 |
| mortalityunder5 | DECIMAL(5,2) | Under-5 mortality rate |

## 🎯 What Each Query Shows

1. **Mobile Phones** (`mobile.php`)
   - Country name
   - Number of mobile phone providers

2. **Population** (`population.php`)
   - Country name
   - Total population
   - Urban population

3. **Life Expectancy** (`lifeexpectancy.php`)
   - Country name
   - Birth rate
   - Life expectancy

4. **GDP** (`gdp.php`)
   - Country name
   - Gross Domestic Product

5. **Mortality** (`mortality.php`)
   - Country name
   - Childhood mortality rate (under 5)

## ✅ Verification Checklist

After setup, verify:

- [ ] Database has 30 countries: `mysql -u webapp_user -p countries -e "SELECT COUNT(*) FROM countrydata_final;"`
- [ ] Credentials configured: `grep -A 5 "catch (Exception" /var/www/html/get-parameters.php`
- [ ] Apache is running: `sudo systemctl status apache2`
- [ ] MariaDB is running: `sudo systemctl status mariadb`
- [ ] PHP works: `curl http://localhost/index.php`

## 🔧 Configuration Flow

```
User Request → Apache → PHP File (e.g., query2.php)
                           ↓
                    include 'get-parameters.php'
                           ↓
                  Try AWS Connection
                    ↙           ↘
            Fails (Local)    Success (AWS)
                ↓                ↓
          Use catch block   Use AWS values
                ↘           ↙
            Set variables: $ep, $db, $un, $pw
                      ↓
            Connect to MySQL Database
                      ↓
            Execute Query
                      ↓
            Return Results to User
```

## 📚 Documentation Files

- **`QUICKSTART.md`** - Fast setup guide (start here!)
- **`SETUP_GUIDE.md`** - Complete installation guide
- **`database/README.md`** - Database setup details
- **`README_CONFIG.md`** - This file

## 🆘 Common Issues & Solutions

### Issue: "Access denied for user"
**Solution:** Password mismatch between database and `get-parameters.php`
```bash
# Check what's in get-parameters.php
grep -A 5 "catch (Exception" /var/www/html/get-parameters.php
# Update if needed
sudo nano /var/www/html/get-parameters.php
```

### Issue: Queries show no data
**Solution:** Database might be empty
```bash
mysql -u webapp_user -p countries -e "SELECT COUNT(*) FROM countrydata_final;"
# If 0, re-run database script
```

### Issue: Permission denied
**Solution:**
```bash
sudo chown -R www-data:www-data /var/www/html/
sudo chmod -R 755 /var/www/html/
```

## 🎉 You're Ready!

Your application now has:
- ✅ Simple credential configuration in existing PHP file
- ✅ Complete database schema with all required columns
- ✅ All queries working with proper credentials
- ✅ Production-ready with AWS Secrets Manager support

**Next Step:** Run through `QUICKSTART.md` to get your application running!

## 📞 Need Help?

Check the troubleshooting sections in:
1. `QUICKSTART.md` - For running the app
2. `SETUP_GUIDE.md` - For installation issues
3. `database/README.md` - For database problems
