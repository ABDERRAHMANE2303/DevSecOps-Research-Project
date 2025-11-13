FROM php:8.2-apache-bookworm

# Install system dependencies for healthcheck
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Enable Apache modules
RUN a2enmod rewrite

# Set working directory
WORKDIR /var/www/html

# Copy application files
COPY ./app/ /var/www/html/

# Configure Apache to run on port 8080 (non-privileged port)
RUN sed -i 's/Listen 80/Listen 8080/' /etc/apache2/ports.conf && \
    sed -i 's/:80/:8080/' /etc/apache2/sites-available/000-default.conf

# Set proper permissions for www-data user
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html && \
    chown -R www-data:www-data /var/run/apache2 /var/log/apache2 && \
    chmod -R 755 /var/run/apache2 /var/log/apache2

# Add healthcheck (updated for port 8080)
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/ || exit 1

# Expose port 8080 (non-privileged port)
EXPOSE 8080

# Switch to non-root user
USER www-data

# Start Apache as www-data user
CMD ["apache2-foreground"]