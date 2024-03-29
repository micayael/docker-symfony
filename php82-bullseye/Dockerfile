FROM php:8.2-cli-bullseye
FROM php:8.2-apache-bullseye

#######################################################

ENV COMPOSER_ALLOW_SUPERUSER 1
ENV PROJECT_ROOT /src
ENV APACHE_DOCUMENT_ROOT /src/public
ENV APACHE_HTTP_PORT 80

#######################################################

COPY php.ini $PHP_INI_DIR
COPY 000-default.conf /etc/apache2/sites-available/
COPY ports.conf /etc/apache2/ports.conf

#######################################################

# Enable apache2 mod_rewrite
RUN a2enmod rewrite

#######################################################

# Install OS utils
RUN apt update && apt install -y \
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

# Install node lts
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash -

# Intall yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# Install nodejs, yarn
RUN apt update \
    && apt install nodejs yarn

#######################################################

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

#######################################################

# Install Symfony command
RUN curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.deb.sh' | bash \
    && apt install symfony-cli

#######################################################

# Install intl extension
RUN apt-get install -y libicu-dev \
    && docker-php-ext-configure intl \
    && docker-php-ext-install intl

# Install PHP zip extension
RUN apt-get install -y \
        libzip-dev \
        zip \
  && docker-php-ext-install zip

# Install APCu extension
RUN printf "\n" | pecl install apcu \
    && docker-php-ext-enable apcu

# Install xsl extension
RUN apt install -y libxslt-dev \
    && docker-php-ext-install xsl

# install opcache extension
RUN docker-php-ext-install opcache

# Install Mysql extension
RUN docker-php-ext-install pdo_mysql

# Install PostgreSQL extension
RUN apt install -y libpq-dev \
    && docker-php-ext-install pdo_pgsql

#######################################################

WORKDIR /src
