# DevSecOps Research Project 

A PHP-based web application for querying and displaying country statistics including demographics, GDP, life expectancy, and more.

## 🚀 Quick Start

**New to this project? Start here:**

1. **First time setup:** Follow [QUICKSTART.md](QUICKSTART.md) (5 steps, ~10 minutes)
2. **Detailed installation:** See [SETUP_GUIDE.md](SETUP_GUIDE.md) for complete instructions
3. **Database setup:** Check [database/README.md](database/README.md) for database details

## 📋 What's This Project?

This is a social research web application that provides data queries for countries worldwide:

- 📱 **Mobile Phones** - Number of mobile phone providers
- 👥 **Population** - Total and urban population statistics  
- 💚 **Life Expectancy** - Birth rates and life expectancy data
- 💰 **GDP** - Gross Domestic Product figures
- 👶 **Mortality** - Childhood mortality rates

## 🛠️ Technology Stack

- **Backend:** PHP 8.2
- **Database:** MariaDB 10.5 (MySQL)
- **Web Server:** Apache2
- **OS:** Ubuntu 20.04+ / Linux
- **Cloud (Optional):** AWS (RDS, Secrets Manager, EC2)

## 📦 Project Structure

```
DevSecOps-Research-Project/
├── app/                    # Application files
│   ├── .env               # Your credentials (not committed)
│   ├── config.php         # Configuration loader
│   ├── index.php          # Home page
│   ├── query*.php         # Query files
│   └── ...
├── database/              # Database setup
│   ├── setup_database.sql # SQL setup script
│   └── README.md          # Database docs
├── infrastructure/        # DevOps configs
│   ├── ansible/
│   └── terraform/
├── QUICKSTART.md          # ⭐ Start here!
├── SETUP_GUIDE.md         # Complete guide
└── README_CONFIG.md       # Configuration docs
```

## 🎯 Features

- ✅ Secure credential management using `.env` files
- ✅ Auto-detection of AWS vs local environment
- ✅ 30 countries with sample data included
- ✅ Responsive web interface
- ✅ Multiple query types
- ✅ Ready for DevSecOps pipeline integration

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| [QUICKSTART.md](QUICKSTART.md) | **Start here** - Quick 5-step setup |
| [SETUP_GUIDE.md](SETUP_GUIDE.md) | Complete installation guide |
| [database/README.md](database/README.md) | Database setup details |
| [README_CONFIG.md](README_CONFIG.md) | Configuration system explained |

## 🔐 Security

- Credentials configured in `get-parameters.php` catch block for local dev
- AWS Secrets Manager for production deployments
- `.gitignore` protects sensitive files
- File permissions properly configured
- Separate configs for dev/prod environments

## 💻 Requirements

- Ubuntu 20.04 LTS or higher
- PHP 8.2+
- MariaDB 10.5+
- Apache2
- 1GB RAM minimum
- 2GB disk space

## ⚡ Quick Command Reference

```bash
# Start services
sudo systemctl start apache2 mariadb

# Check status
sudo systemctl status apache2 mariadb

# View logs
sudo tail -f /var/log/apache2/error.log

# Test database
mysql -u webapp_user -p countries -e "SELECT COUNT(*) FROM countrydata_final;"
```

## 🚀 Getting Started

### 1. Clone the repository
```bash
cd ~/Desktop
git clone <your-repo-url>
cd DevSecOps-Research-Project
```

### 2. Follow the Quick Start
```bash
# Read and follow the quick start guide
cat QUICKSTART.md
```

### 3. Access the application
```
http://localhost/index.php
```

## 🔧 Configuration

The app uses `get-parameters.php` for credentials:

- **Local Development:** Edit the `catch` block in `get-parameters.php` with your database credentials
- **AWS Production:** Automatically uses AWS Secrets Manager and RDS
- **Auto-detection:** Tries AWS first, falls back to local credentials

See [QUICKSTART.md](QUICKSTART.md) for configuration details.

## 📊 Sample Data

Includes data for 30 countries:
- United States, China, India, Brazil, UK
- Germany, France, Japan, Canada, Australia
- And 20 more...

Each country includes:
- Mobile phone providers count
- Population (total and urban)
- Birth rate and life expectancy
- GDP and mortality rates

## 🐛 Troubleshooting

**Application not loading?**
- Check Apache is running: `sudo systemctl status apache2`
- Check error logs: `sudo tail -f /var/log/apache2/error.log`

**Database connection error?**
- Verify credentials in `.env` match database
- Test connection: `mysql -u webapp_user -p countries`

**No data showing?**
- Check database has data: `mysql -u webapp_user -p countries -e "SELECT COUNT(*) FROM countrydata_final;"`

For more troubleshooting, see [QUICKSTART.md](QUICKSTART.md) or [SETUP_GUIDE.md](SETUP_GUIDE.md).

## 🏗️ Infrastructure as Code

The project includes:
- **Terraform** - AWS infrastructure provisioning
- **Ansible** - Configuration management
- **CI/CD Pipeline** - GitHub Actions workflow

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📝 License

See [LICENSE](app/LICENSE) file for details.

## 🎓 Learning Resources

This project demonstrates:
- PHP web application development
- Database design and management
- Secure credential management
- DevSecOps practices
- Infrastructure as Code
- CI/CD pipeline integration

## 📞 Support

If you encounter issues:

1. Check the [QUICKSTART.md](QUICKSTART.md) troubleshooting section
2. Review [SETUP_GUIDE.md](SETUP_GUIDE.md) for detailed instructions
3. Check application logs: `/var/log/apache2/error.log`
4. Verify services are running: `sudo systemctl status apache2 mariadb`

## 🎉 Success Criteria

You know it's working when:
- ✅ Home page loads at `http://localhost/index.php`
- ✅ You can click "Query" in the menu
- ✅ Selecting a query type shows data for 30 countries
- ✅ No errors in Apache error log

## 🔄 Updates

To update the application:

```bash
cd /home/zackweb/Desktop/DevSecOps-Research-Project
git pull
sudo cp -r app/* /var/www/html/
sudo systemctl restart apache2
```

---

**Ready to get started?** → [Open QUICKSTART.md](QUICKSTART.md)

**Need detailed instructions?** → [Open SETUP_GUIDE.md](SETUP_GUIDE.md)

**Questions about config?** → [Open README_CONFIG.md](README_CONFIG.md)
