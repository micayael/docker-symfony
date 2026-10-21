# Misma imagen que php83-bullseye (root, puerto 80, mismas herramientas y
# extensiones), pero sobre trixie: la imagen oficial ya no publica PHP 8.3 para
# bullseye, así que es el único camino por el que llegan los parches de 8.3.
FROM php:8.3-apache-trixie

#######################################################

ENV COMPOSER_ALLOW_SUPERUSER=1
ENV PROJECT_ROOT=/src
ENV APACHE_DOCUMENT_ROOT=/src/public
ENV APACHE_HTTP_PORT=80

#######################################################

# Versiones fijas, las mismas que php84-trixie
ARG INSTALL_PHP_EXTENSIONS_VERSION=2.11.12
ARG INSTALL_PHP_EXTENSIONS_SHA256=7c133ae4b9490d912287188c62ea570729cfa74f0ea357e4be672ce696b4aa29
# Node 16 no tiene paquetes para trixie
ARG NODE_MAJOR=24

ENV COREPACK_HOME=/usr/local/share/corepack

#######################################################

COPY php.ini $PHP_INI_DIR
COPY 000-default.conf /etc/apache2/sites-available/
COPY ports.conf /etc/apache2/ports.conf

#######################################################

# Enable apache2 mod_rewrite
RUN a2enmod rewrite

#######################################################

# Install OS utils (en trixie mlocate fue reemplazado por plocate)
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

# Install Node.js LTS and enable corepack (provides yarn)
# apt-key ya no existe en trixie: el repo se agrega con su keyring.
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
        -o /usr/share/keyrings/nodesource.asc \
    && echo "deb [signed-by=/usr/share/keyrings/nodesource.asc] https://deb.nodesource.com/node_${NODE_MAJOR}.x nodistro main" \
        > /etc/apt/sources.list.d/nodesource.list \
    && apt update \
    && apt install -y --no-install-recommends nodejs \
    && corepack enable \
    && corepack install -g yarn@1 \
    && rm -rf /var/lib/apt/lists/*

#######################################################

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

#######################################################

# Install Symfony CLI
RUN curl -fsSL https://dl.cloudsmith.io/public/symfony/stable/gpg.key \
        -o /usr/share/keyrings/symfony-stable-archive-keyring.asc \
    && echo "deb [signed-by=/usr/share/keyrings/symfony-stable-archive-keyring.asc] https://dl.cloudsmith.io/public/symfony/stable/deb/debian trixie main" \
        > /etc/apt/sources.list.d/symfony-stable.list \
    && apt update \
    && apt install -y --no-install-recommends symfony-cli \
    && rm -rf /var/lib/apt/lists/*

#######################################################

# Install PHP extensions: intl, zip, apcu, xsl, opcache, pdo_mysql, pdo_pgsql
# Se baja una release concreta y se verifica el hash antes de ejecutarla.
RUN curl -fsSL "https://github.com/mlocati/docker-php-extension-installer/releases/download/${INSTALL_PHP_EXTENSIONS_VERSION}/install-php-extensions" \
        -o /usr/local/bin/install-php-extensions \
    && echo "${INSTALL_PHP_EXTENSIONS_SHA256}  /usr/local/bin/install-php-extensions" | sha256sum -c - \
    && chmod 0755 /usr/local/bin/install-php-extensions \
    && install-php-extensions intl zip apcu xsl opcache pdo_mysql pdo_pgsql

#######################################################

# Misma corrección que php84-trixie (ver la explicación completa ahí): ICU trae
# su tabla de zonas horarias congelada en 2024b y sigue creyendo que Paraguay
# usa UTC-4 en invierno, mientras PHP ya sabe que quedó fijo en UTC-3. Eso hace
# que DateType con single_text guarde las fechas un día antes.
ARG ICU_TZDATA_VERSION=2026c
ENV ICU_TIMEZONE_FILES_DIR=/usr/share/icu-tzdata

RUN mkdir -p "$ICU_TIMEZONE_FILES_DIR" \
    && cd "$ICU_TIMEZONE_FILES_DIR" \
    && for f in metaZones.res timezoneTypes.res windowsZones.res zoneinfo64.res; do \
        curl -fsSL -o "$f" \
            "https://raw.githubusercontent.com/unicode-org/icu-data/main/tzdata/icunew/${ICU_TZDATA_VERSION}/44/le/$f"; \
    done \
    && printf '%s  %s\n' \
        5b484c7f02c99d5164208ce84e18fba67c6314d77cf60503e2b19f708b66c6da metaZones.res \
        0bcae5adb34aed6e06c839dd5f516667e721e899deebf573ca29fb3b903ddb74 timezoneTypes.res \
        b8c3a7adb94fd659f8203ee4af4dc72a4e6b14566baac1855c493096f337184b windowsZones.res \
        d8811abef074193b1f2785eda79b8d9c4b816f352a3234e8df457ae80814588d zoneinfo64.res \
        | sha256sum -c - \
    && php -r 'exit(IntlTimeZone::createTimeZone("America/Asuncion")->getRawOffset() === -10800000 ? 0 : 1);'

#######################################################

WORKDIR /src
