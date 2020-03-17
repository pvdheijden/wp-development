FROM php:7.3-apache
RUN apt-get update -y && apt-get install -y git subversion build-essential

# Enable the rewrite module
RUN a2enmod rewrite

# Set php.ini
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

# Install extra modules
RUN docker-php-ext-install mysqli
RUN apt-get install -y libmagickcore-dev libmagickwand-dev && pecl install imagick && docker-php-ext-enable imagick
RUN pecl install redis && docker-php-ext-enable redis
RUN docker-php-ext-install sockets
ADD https://pecl.php.net/get/ssh2 /tmp/ssh2-latest.tgz
RUN apt-get install -y libssh2-1-dev libssh2-1 && pecl -v install /tmp/ssh2-latest.tgz && docker-php-ext-enable ssh2

# Xdebug
RUN pecl install xdebug && docker-php-ext-enable xdebug

RUN echo 'xdebug.remote_port=9000' >> $PHP_INI_DIR/php.ini && \
    echo 'xdebug.remote_enable=on' >> $PHP_INI_DIR/php.ini && \
    echo 'xdebug.remote_connect_back=on' >> $PHP_INI_DIR/php.ini

RUN sed -ri -e 's!Listen 80!Listen 8080!g' /etc/apache2/ports.conf
RUN sed -ri -e 's!VirtualHost \*:80!VirtualHost \*:8080!g' /etc/apache2/sites-available/*.conf

EXPOSE 8080

# Install the application/site
ADD https://getcomposer.org/installer composer-setup.php
RUN php composer-setup.php --install-dir=/usr/local/bin --filename=composer

USER www-data:www-data
WORKDIR /var/www
COPY ./html/composer.json ./html/composer.json
RUN cd /var/www/html && composer install
COPY ./.env.development ./html/.env
COPY ./html/.htaccess ./html/.htaccess
