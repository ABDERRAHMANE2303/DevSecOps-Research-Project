-- ============================================================
-- Database Setup Script for DevSecOps Research Project
-- ============================================================
-- This script creates the database, user, and table structure
-- for the Country Data Query Application
-- ============================================================

-- Create the database
CREATE DATABASE IF NOT EXISTS countries;

-- Use the database
USE countries;

-- Create a database user with password
-- NOTE: Change 'your_password' to a strong password of your choice
CREATE USER IF NOT EXISTS 'webapp_user'@'localhost' IDENTIFIED BY 'your_password';

-- Grant all privileges on the countries database to the user
GRANT ALL PRIVILEGES ON countries.* TO 'webapp_user'@'localhost';

-- Apply the privilege changes
FLUSH PRIVILEGES;

-- Create the main data table
CREATE TABLE IF NOT EXISTS countrydata_final (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    mobilephones INT COMMENT 'Number of mobile phone providers',
    population BIGINT COMMENT 'Total population',
    lifeexpectancy DECIMAL(5,2) COMMENT 'Average life expectancy in years',
    gdp DECIMAL(15,2) COMMENT 'GDP in millions',
    mortality DECIMAL(5,2) COMMENT 'Mortality rate per 1000'
);

-- Create index on country name for faster queries
CREATE INDEX idx_country_name ON countrydata_final(name);

-- Insert sample data
INSERT INTO countrydata_final (name, mobilephones, population, lifeexpectancy, gdp, mortality) VALUES
('United States', 4, 331000000, 78.93, 21427700.00, 8.7),
('China', 3, 1439323776, 76.96, 14342900.00, 7.5),
('India', 5, 1380004385, 69.66, 2875142.00, 30.7),
('Brazil', 4, 212559417, 75.88, 1839758.00, 14.0),
('United Kingdom', 4, 67886011, 81.26, 2827113.00, 3.9),
('Germany', 4, 83783942, 81.33, 3846414.00, 3.3),
('France', 4, 65273511, 82.66, 2715518.00, 3.3),
('Japan', 3, 126476461, 84.62, 5081770.00, 2.0),
('Canada', 3, 37742154, 82.30, 1736426.00, 4.9),
('Australia', 3, 25499884, 83.44, 1392681.00, 3.2),
('South Korea', 3, 51269185, 83.03, 1646739.00, 2.8),
('Spain', 4, 46754778, 83.56, 1394116.00, 2.7),
('Italy', 4, 60461826, 83.51, 2003576.00, 3.2),
('Mexico', 5, 128932753, 75.05, 1258287.00, 12.6),
('Russia', 4, 145934462, 72.58, 1699877.00, 6.7),
('South Africa', 5, 59308690, 64.13, 351432.00, 33.2),
('Argentina', 3, 45195774, 76.67, 449663.00, 10.2),
('Egypt', 4, 102334404, 71.99, 302256.00, 19.4),
('Turkey', 4, 84339067, 77.69, 754412.00, 10.3),
('Indonesia', 5, 273523615, 71.72, 1119191.00, 22.3),
('Nigeria', 5, 206139589, 54.69, 448120.00, 75.7),
('Saudi Arabia', 3, 34813871, 75.13, 792967.00, 6.8),
('Netherlands', 3, 17134872, 82.28, 909070.00, 3.6),
('Switzerland', 3, 8654622, 83.78, 703082.00, 3.3),
('Sweden', 3, 10099265, 82.80, 531283.00, 2.4),
('Poland', 4, 37846611, 78.73, 594160.00, 4.4),
('Belgium', 3, 11589623, 81.63, 529607.00, 3.7),
('Thailand', 4, 69799978, 77.15, 543550.00, 6.7),
('Austria', 3, 9006398, 81.77, 446315.00, 3.6),
('Norway', 3, 5421241, 82.80, 403336.00, 2.3);

-- Display confirmation message
SELECT 'Database setup completed successfully!' AS Status;
SELECT COUNT(*) AS 'Total Countries Inserted' FROM countrydata_final;

-- Display sample data
SELECT * FROM countrydata_final LIMIT 5;
