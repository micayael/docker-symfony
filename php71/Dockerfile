FROM php:7.1-apache

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
        mlocate

#######################################################

# Install php-cli
RUN apt-get install -y php5-cli

# Install nodejs, npm
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - \
    && apt-get install -y nodejs

# Install Git
RUN apt-get install -y git

# Install MySQL Client
RUN apt-get install -y mysql-client

# Install PostgreSQL Client
RUN apt-get install -y libpq-dev postgresql-client

#######################################################

# Install bower
RUN npm install -g bower \
    && ln -s /usr/bin/bower /usr/local/bin/

# Install yarn
RUN npm install -g yarn

# Install uglify
RUN npm install -g uglify-js uglifycss

#######################################################

# Install PHP Mysql Extension
RUN docker-php-ext-install pdo_mysql

# Install PHP PostgreSQL Extension
RUN docker-php-ext-install pdo_pgsql

# Install mbstring
RUN docker-php-ext-install mbstring

# Install intl Extension
RUN apt-get install -y libicu-dev \
    && docker-php-ext-install intl \
    && apt-get install -y  libicu52  libltdl7

#######################################################

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

# Install php-cs-fixer
RUN curl http://get.sensiolabs.org/php-cs-fixer.phar -o php-cs-fixer \
    && chmod a+x php-cs-fixer \
    && mv php-cs-fixer /usr/local/bin/php-cs-fixer

# Install phpunit
RUN curl https://phar.phpunit.de/phpunit.phar -Lo phpunit \
    && chmod a+x phpunit \
    && mv phpunit /usr/local/bin/phpunit

#######################################################

# Enable apache2 mod_rewrite
RUN a2enmod rewrite

# https://getcomposer.org/doc/03-cli.md#composer-allow-superuser
ENV COMPOSER_ALLOW_SUPERUSER 1

RUN cd /var/www/ \
    && rm -rf html \
    && ln -s /src/web/ html

WORKDIR /src
