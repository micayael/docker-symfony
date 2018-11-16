FROM micayael/symfony-base:php72

# Install wkhtmltopdf
RUN cd /opt/ \
    && apt-get update \
    && apt-get install -y gdebi libxrender1 libfontconfig1 \
    && wget -c https://downloads.wkhtmltopdf.org/0.12/0.12.5/wkhtmltox_0.12.5-1.stretch_amd64.deb \
    && gdebi -n wkhtmltox_0.12.5-1.stretch_amd64.deb
