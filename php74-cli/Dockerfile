FROM php:7.4.10-cli-alpine3.12

#######################################################

ENV COMPOSER_ALLOW_SUPERUSER 1

#######################################################

COPY php.ini $PHP_INI_DIR

#######################################################

# Install OS utils
RUN apk update \
    && apk add \
        bash \
        vim \
        zip \
        unzip \
        busybox-extras \
        wget \
        mlocate \
        git

#######################################################

## Install database clients
#RUN apk --update add mysql-client
#RUN apk --update add postgresql-dev

#######################################################

# Install PHP mbstring Extension
RUN apk add oniguruma-dev \
    && docker-php-ext-install mbstring \
    && docker-php-ext-enable mbstring

RUN apk --update add mysql-client \
    && docker-php-ext-install pdo_mysql

RUN apk --update add postgresql-dev \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pdo_pgsql

## Install PHP curl Extension
RUN apk add curl-dev \
    && docker-php-ext-install curl

# Install PHP intl Extension
RUN apk add icu-dev \
    && docker-php-ext-configure intl \
    && docker-php-ext-install intl

# Install PHP zip Extensions
RUN apk add libzip-dev \
    && docker-php-ext-install zip

#######################################################

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

#######################################################

# Install Symfony command
RUN wget https://get.symfony.com/cli/installer -O - | bash \
    && mv /root/.symfony/bin/symfony /usr/local/bin/symfony

#######################################################

WORKDIR /src