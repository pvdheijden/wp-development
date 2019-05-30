FROM php:7.2-apache
RUN apt-get update -y && apt-get install -y build-essential zlib1g-dev zip unzip

# Enable the rewrite module
RUN a2enmod rewrite

# Set php.ini
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

# Install extra PHP modules
RUN docker-php-ext-install mysqli zip && \
    apt-get install -y libmagickcore-dev libmagickwand-dev && pecl install imagick && docker-php-ext-enable imagick

# Xdebug
RUN pecl install xdebug && docker-php-ext-enable xdebug && \
    echo 'xdebug.remote_port=9000' >> $PHP_INI_DIR/php.ini && \
    echo 'xdebug.remote_enable=on' >> $PHP_INI_DIR/php.ini && \
    echo 'xdebug.remote_connect_back=on' >> $PHP_INI_DIR/php.ini

RUN sed -ri -e 's!Listen 80!Listen 8080!g' /etc/apache2/ports.conf && \
    sed -ri -e 's!VirtualHost \*:80!VirtualHost \*:8080!g' /etc/apache2/sites-available/*.conf

# Install the application/site
ADD https://getcomposer.org/installer composer-setup.php
RUN apt-get install -y git subversion && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer

WORKDIR /var/www
USER www-data

COPY ./html/composer.* ./html/
RUN composer --no-interaction --working-dir=./html install && \
    mkdir -p ./html/content/uploads
COPY ./.env.development ./html/.env

EXPOSE 8080
