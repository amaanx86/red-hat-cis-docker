# Base image: Red Hat Universal Base Image 10
FROM registry.access.redhat.com/ubi10/ubi:latest

LABEL org.opencontainers.image.authors="Amaan Ul Haq Siddiqui" \
      org.opencontainers.image.title="WordPress on UBI10 with Apache and PHP-FPM" \
      org.opencontainers.image.description="WordPress on UBI10 with Apache 2.4 and PHP 8.3 FPM (CIS baseline ready)" \
      org.opencontainers.image.version="1.0" \
      org.opencontainers.image.source="https://github.com/amaanx86/red-hat-cis-docker" \
      org.opencontainers.image.licenses="Apache-2.0"

# Install system packages and PHP 8.3
RUN dnf -y update && \
    dnf -y install \
        httpd \
        php \
        php-fpm \
        php-mysqlnd \
        php-gd \
        php-mbstring \
        php-xml \
        php-intl \
        php-soap \
        php-zip \
        php-curl \
        php-opcache \
        wget \
        tar && \
    dnf clean all

# Download and setup WordPress
WORKDIR /tmp
RUN wget -q https://wordpress.org/latest.tar.gz && \
    tar -xzf latest.tar.gz && \
    mv wordpress/* /var/www/html/ && \
    rm -rf latest.tar.gz wordpress && \
    mkdir -p /var/www/html/wp-content/{plugins,themes,uploads} \
             /var/lib/php/{session,wsdlcache} \
             /run/php-fpm

# Copy configuration files
COPY config/apache.conf /etc/httpd/conf.d/wordpress.conf
COPY config/php-fpm.conf /etc/php-fpm.d/zz-wordpress.conf

# Set permissions
RUN chown -R apache:apache /var/www/html /var/lib/php /run/php-fpm && \
    chmod -R 755 /var/www/html

# Copy and set entrypoint
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /var/www/html

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
