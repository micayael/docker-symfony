FROM php:7.4-apache-buster

#######################################################

ENV COMPOSER_ALLOW_SUPERUSER 1
ENV PROJECT_ROOT /src
ENV APACHE_DOCUMENT_ROOT /src/public

#######################################################

COPY php.ini $PHP_INI_DIR

#######################################################

# Install OS utils
RUN apt-get update && apt-get install -y \
        vim \
        zip \
        unzip \
        telnet \
        wget \
        mlocate \
        gnupg \
        iputils-ping \
        git

#######################################################

# Install nodejs, npm
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash - \
    && apt-get install -y nodejs

# Install Git
RUN apt-get install -y git

# Install MySQL Client
RUN apt-get install -y default-mysql-client

# Install PostgreSQL Client

RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main' >  /etc/apt/sources.list.d/pgdg.list \
    && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
    && apt-get update \
    && apt-get install -y libpq-dev postgresql-client-10

#######################################################

# Install PHP mbstring Extension
RUN apt-get install -y libonig-dev \
    && docker-php-ext-install mbstring

# Install PHP Mysql Extension
RUN docker-php-ext-install pdo_mysql

# Install PHP PostgreSQL Extension
RUN docker-php-ext-install pdo_pgsql

## Install PHP curl Extension
RUN apt-get install -y libcurl3-openssl-dev curl \
    && docker-php-ext-install curl

# Install intl Extension
RUN apt-get install -y libicu-dev \
    && docker-php-ext-configure intl \
    && docker-php-ext-install intl

# Install PHP zip Extensions
RUN apt-get install -y \
        libzip-dev \
        zip \
  && docker-php-ext-install zip

# Install APCu
RUN printf "\n" | pecl install apcu \
    && docker-php-ext-enable apcu

# Install xsl Etension
RUN apt install -y libxslt-dev \
    && docker-php-ext-install xsl

#######################################################

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

#######################################################

# Install Symfony command
RUN wget https://get.symfony.com/cli/installer -O - | bash \
    && mv /root/.symfony/bin/symfony /usr/local/bin/symfony

#######################################################

# Enable apache2 mod_rewrite
RUN a2enmod rewrite

COPY 000-default.conf /etc/apache2/sites-available/

#######################################################

WORKDIR /src