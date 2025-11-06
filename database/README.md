# Database Setup

This folder contains the database setup script for the DevSecOps Research Project.

## Files

- `setup_database.sql` - Complete database initialization script

## What the Script Does

The `setup_database.sql` script performs the following operations:

1. **Creates the database** named `countries`
2. **Creates a user** named `webapp_user` with password (you must change the default password)
3. **Grants privileges** to the user for the countries database
4. **Creates the table** `countrydata_final` with the following columns:
   - `id` (Primary Key, Auto Increment)
   - `name` (Country Name)
   - `mobilephones` (Number of mobile phone providers)
   - `population` (Total population)
   - `lifeexpectancy` (Average life expectancy in years)
   - `gdp` (GDP in millions)
   - `mortality` (Mortality rate per 1000)
5. **Inserts sample data** for 30 countries
6. **Creates an index** on the country name for faster queries

## How to Run

### Step 1: Edit the Password

Before running the script, you **MUST** change the default password:

```bash
nano setup_database.sql
```

Find this line:
```sql
CREATE USER IF NOT EXISTS 'webapp_user'@'localhost' IDENTIFIED BY 'your_password';
```

Replace `'your_password'` with a strong password of your choice (keep the quotes).

### Step 2: Run the Script

Execute the script as the MySQL root user:

```bash
sudo mysql -u root -p < setup_database.sql
```

Or if you're in the database directory:

```bash
cd /home/zackweb/Desktop/DevSecOps-Research-Project/database
sudo mysql -u root -p < setup_database.sql
```

Enter your MariaDB root password when prompted.

### Step 3: Verify

Check that the database was created successfully:

```bash
mysql -u webapp_user -p countries -e "SELECT COUNT(*) FROM countrydata_final;"
```

You should see output showing 30 countries.

## Sample Data Included

The script includes data for 30 countries including:
- United States
- China
- India
- Brazil
- United Kingdom
- Germany
- France
- Japan
- And 22 more countries...

Each country includes statistics for mobile phones, population, life expectancy, GDP, and mortality rates.

## Troubleshooting

### "Access denied" Error
Make sure you're running the script as the MySQL root user and entering the correct password.

### "User already exists" Error
The script uses `IF NOT EXISTS` clauses, but if you need to recreate the user:
```sql
DROP USER 'webapp_user'@'localhost';
```

### "Database already exists" Error
To start fresh:
```sql
DROP DATABASE countries;
```
Then run the script again.

## Security Note

⚠️ **IMPORTANT**: Always use a strong password for the database user, especially in production environments!

Good password practices:
- At least 12 characters
- Mix of uppercase, lowercase, numbers, and special characters
- Avoid common words or patterns
- Different from other passwords

## Updating the Application Config

After running this script, update your application configuration file (`local-config.php`) with the same password you set in the SQL script:

```php
<?php
$ep = 'localhost';
$db = 'countries';
$un = 'webapp_user';
$pw = 'your_password';  // Use the SAME password you set in the SQL script
?>
```
