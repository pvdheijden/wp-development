FROM php:7.2-apache
RUN apt-get update -y && apt-get install -y build-essential

# Enable the rewrite module
RUN a2enmod rewrite

# Set php.ini
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

# Install extra modules
RUN docker-php-ext-install mysqli
RUN apt-get install -y libmagickcore-dev libmagickwand-dev && pecl install imagick && docker-php-ext-enable imagick

# Xdebug
RUN pecl install xdebug && docker-php-ext-enable xdebug

RUN echo 'xdebug.remote_port=9000' >> $PHP_INI_DIR/php.ini && \
    echo 'xdebug.remote_enable=on' >> $PHP_INI_DIR/php.ini && \
    echo 'xdebug.remote_connect_back=on' >> $PHP_INI_DIR/php.ini


RUN sed -ri -e 's!Listen 80!Listen 8080!g' /etc/apache2/ports.conf
RUN sed -ri -e 's!VirtualHost \*:80!VirtualHost \*:8080!g' /etc/apache2/sites-available/*.conf
#RUN sed -ri -e 's!/var/www/html!/var/www/public!g' /etc/apache2/sites-available/*.conf

# Install the application/site
EXPOSE 8080
WORKDIR /var/www

COPY --chown=www-data:www-data ./html ./html
COPY --chown=www-data:www-data ./.env.development ./html/.env
