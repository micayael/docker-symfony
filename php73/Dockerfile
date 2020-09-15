FROM php:7.3-apache

COPY php.ini /usr/local/etc/php/

#######################################################

# APT-GET UPDATE
RUN apt-get update

# Install OS utils
RUN apt-get install -y \
        vim \
        zip \
        unzip \
        telnet \
        wget \
        mlocate \
        gnupg\
        iputils-ping

#######################################################

# Install nodejs, npm
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - \
    && apt-get install -y nodejs

# Install Git
RUN apt-get install -y git

# Install MySQL Client
RUN apt-get install -y mysql-client

# Install PostgreSQL Client

RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main' >  /etc/apt/sources.list.d/pgdg.list \
    && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
    && apt-get update \
    && apt-get install -y libpq-dev postgresql-client-10

#######################################################

# Install yarn
RUN npm install -g yarn

#######################################################

# Install PHP Mysql Extension
RUN docker-php-ext-install pdo_mysql

# Install PHP PostgreSQL Extension
RUN docker-php-ext-install pdo_pgsql

# Install mbstring
RUN docker-php-ext-install mbstring

# Install intl Extension
RUN apt-get install -y libicu-dev \
    && docker-php-ext-configure intl \
    && docker-php-ext-install intl

# Install PHP zip Extensions
RUN apt-get install -y zlib1g-dev \
    && docker-php-ext-install zip

# Install APCu
RUN printf "\n" | pecl install apcu \
    && docker-php-ext-enable apcu

#######################################################

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

#######################################################

# Enable apache2 mod_rewrite
RUN a2enmod rewrite

# https://getcomposer.org/doc/03-cli.md#composer-allow-superuser
ENV COMPOSER_ALLOW_SUPERUSER 1

ENV PROJECT_ROOT /src
ENV APACHE_DOCUMENT_ROOT /src/public

COPY 000-default.conf /etc/apache2/sites-available/

WORKDIR /src
