FROM php:8.4-apache-trixie

#######################################################

ENV COMPOSER_ALLOW_SUPERUSER=1
ENV PROJECT_ROOT=/src
ENV APACHE_DOCUMENT_ROOT=/src/public
ENV APACHE_HTTP_PORT=80

#######################################################

COPY php.ini $PHP_INI_DIR
COPY 000-default.conf /etc/apache2/sites-available/
COPY ports.conf /etc/apache2/ports.conf
COPY security.conf /etc/apache2/conf-available/security.conf

#######################################################

# Enable apache2 mod_rewrite
RUN a2enmod rewrite

#######################################################

# Install OS utils
RUN apt update \
    && apt install -y --no-install-recommends \
        vim \
        zip \
        unzip \
        telnet \
        wget \
        plocate \
        gnupg \
        iputils-ping \
        git \
    && rm -rf /var/lib/apt/lists/*

#######################################################

# Install Node.js LTS and enable corepack (provides yarn and pnpm)
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt install -y nodejs \
    && corepack enable \
    && rm -rf /var/lib/apt/lists/*

#######################################################

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

#######################################################

# Install Symfony CLI
RUN curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.deb.sh' | bash \
    && apt install -y symfony-cli \
    && rm -rf /var/lib/apt/lists/*

#######################################################

# Install PHP extensions (handles apt/pecl dependencies automatically)
ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN install-php-extensions intl zip apcu xsl opcache pdo_mysql pdo_pgsql

#######################################################

WORKDIR /src
