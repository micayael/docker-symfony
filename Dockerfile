FROM php:7.0-apache

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
        wget

#######################################################

# Install php-cli
RUN apt-get install -y php5-cli

# Install nodejs, npm
RUN curl -sL https://deb.nodesource.com/setup_4.x | bash - \
    && apt-get install -y nodejs

# Install Git
RUN apt-get install -y git

# Install MySQL Client
RUN apt-get install -y mysql-client

# Install PostgreSQL Client
RUN apt-get install -y libpq-dev postgresql-client

#######################################################

# Install bower
RUN npm install -g bower

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

# Link web context: http://localhost:port/dtc
#RUN cd /var/www/html/ \
#    && ln -s /src/web/ dtc

RUN cd /var/www/ \
    && rm -rf html \
    && ln -s /src/web/ html

WORKDIR /src
