FROM php:8.4-apache-trixie

#######################################################

ENV COMPOSER_ALLOW_SUPERUSER=1
ENV PROJECT_ROOT=/src
ENV APACHE_DOCUMENT_ROOT=/src/public
# 8080 para poder correr como usuario no privilegiado (puertos <1024 requieren root)
ENV APACHE_HTTP_PORT=8080

#######################################################

# Versiones fijas: reconstruir esta imagen dentro de un año tiene que dar el
# mismo software. Para actualizarlas se cambian estos ARG a propósito.
ARG INSTALL_PHP_EXTENSIONS_VERSION=2.11.12
ARG INSTALL_PHP_EXTENSIONS_SHA256=7c133ae4b9490d912287188c62ea570729cfa74f0ea357e4be672ce696b4aa29
ARG NODE_MAJOR=24

# Corepack guarda su caché en el HOME del usuario. Sin esto, lo que se instala
# durante el build (root) no lo encuentra www-data en runtime y yarn se vuelve a
# descargar en cada contenedor, con red obligatoria.
ENV COREPACK_HOME=/usr/local/share/corepack

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
# El repo se agrega a mano en vez de con "curl ... | bash": ese pipe ejecuta como
# root lo que el servidor devuelva en el momento del build, sin nada que lo
# verifique. La clave es la misma que instalaba el script.
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

# Install Symfony CLI (mismo criterio que Node: repo explícito, sin pipe a bash)
RUN curl -fsSL https://dl.cloudsmith.io/public/symfony/stable/gpg.key \
        -o /usr/share/keyrings/symfony-stable-archive-keyring.asc \
    && echo "deb [signed-by=/usr/share/keyrings/symfony-stable-archive-keyring.asc] https://dl.cloudsmith.io/public/symfony/stable/deb/debian trixie main" \
        > /etc/apt/sources.list.d/symfony-stable.list \
    && apt update \
    && apt install -y --no-install-recommends symfony-cli \
    && rm -rf /var/lib/apt/lists/*

#######################################################

# Install PHP extensions (handles apt/pecl dependencies automatically)
# Se baja una release concreta y se verifica el hash antes de ejecutarla.
RUN curl -fsSL "https://github.com/mlocati/docker-php-extension-installer/releases/download/${INSTALL_PHP_EXTENSIONS_VERSION}/install-php-extensions" \
        -o /usr/local/bin/install-php-extensions \
    && echo "${INSTALL_PHP_EXTENSIONS_SHA256}  /usr/local/bin/install-php-extensions" | sha256sum -c - \
    && chmod 0755 /usr/local/bin/install-php-extensions \
    && install-php-extensions intl zip apcu xsl opcache pdo_mysql pdo_pgsql

#######################################################

WORKDIR /src

#######################################################

# Correr como no-root. Se remapea www-data a UID/GID 1000 para que los bind
# mounts en desarrollo queden con el usuario típico del host
RUN groupmod -g 1000 www-data \
    && usermod -u 1000 -g 1000 www-data \
    && mkdir -p /var/run/apache2 /var/lock/apache2 \
    && chown -R www-data:www-data /var/run/apache2 /var/lock/apache2 /var/log/apache2 /var/www /src "$COREPACK_HOME"

USER www-data
