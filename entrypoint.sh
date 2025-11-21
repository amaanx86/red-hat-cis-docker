#!/bin/bash
set -e

# Create wp-config.php if it doesn't exist
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "Creating wp-config.php with environment variables..."
    cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
    
    # Replace database settings
    sed -i "s/database_name_here/${WORDPRESS_DB_NAME:-wordpress}/" /var/www/html/wp-config.php
    sed -i "s/username_here/${WORDPRESS_DB_USER:-wpuser}/" /var/www/html/wp-config.php
    sed -i "s/password_here/${WORDPRESS_DB_PASSWORD:-wppassword}/" /var/www/html/wp-config.php
    sed -i "s/localhost/${WORDPRESS_DB_HOST:-db:3306}/" /var/www/html/wp-config.php
    
    # Set proper permissions
    chown apache:apache /var/www/html/wp-config.php
    chmod 640 /var/www/html/wp-config.php
fi

# Start PHP-FPM in background
php-fpm -D

# Start Apache in foreground
exec httpd -D FOREGROUND
