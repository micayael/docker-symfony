FROM micayael/symfony-base:php71

# Install wkhtmltopdf
RUN cd /opt/ \
    && apt-get update \
    && apt-get install -y gdebi libxrender1 libfontconfig1 \
    && wget -c https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.jessie_amd64.deb \
    && gdebi -n wkhtmltox_0.12.5-1.jessie_amd64.deb