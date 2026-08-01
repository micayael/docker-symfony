symfony-base
------------

Dos imágenes salen del mismo Dockerfile, compartiendo la etapa `base`: el
runtime, las extensiones y el endurecimiento son idénticos en las dos, así que
no pueden desincronizarse.

| Tag | Etapa | Para qué |
|---|---|---|
| `php84-trixie` | `dev` | desarrollo: trae composer, symfony-cli, node, yarn, git, vim |
| `php84-trixie-prod` | `prod` | producción: solo el runtime, sin ninguna de esas herramientas |

~~~
docker build --target dev  -t micayael/symfony-base:php84-trixie .
docker build --target prod -t micayael/symfony-base:php84-trixie-prod .
~~~

La diferencia no es el tamaño (553 MB contra 898 MB) sino la superficie: lo que
no está instalado no lo puede usar quien consiga ejecución de código para bajar
un payload o pivotear. En `prod` además opcache no revalida timestamps, porque
el código no cambia entre requests.

Se publican también tags fechadas inmutables (`php84-trixie-AAAAMMDD`) para
quien necesite un punto fijo al que volver.

## Seguridad

Esta imagen corre como usuario no-root (`www-data`, remapeado a UID/GID 1000
para que los bind mounts en desarrollo queden con el usuario típico del host)
y Apache escucha en el puerto **8080** (un proceso sin privilegios no puede
bindear puertos <1024 en todos los runtimes).

~~~
docker run -d -v ${PWD}:/src -p 9999:8080 micayael/symfony-base:php84-trixie
~~~

El puerto se puede cambiar en runtime con la variable `APACHE_HTTP_PORT`
(en Docker funciona incluso el 80 sin root):

~~~
docker run -d -e APACHE_HTTP_PORT=80 -p 9999:80 micayael/symfony-base:php84-trixie
~~~

Los logs de Apache salen por stdout/stderr (`docker logs`).

Apache no anuncia versión ni sistema operativo (`ServerTokens Prod`,
`ServerSignature Off`, `TraceEnable Off`) y PHP tampoco (`expose_php=Off`).

Toda respuesta sale con `X-Content-Type-Options: nosniff`, `X-Frame-Options:
SAMEORIGIN` y `Referrer-Policy: strict-origin-when-cross-origin`. **No** se
define una `Content-Security-Policy`: imponerla desde una imagen base rompe
cualquier proyecto con scripts inline, y qué orígenes son válidos solo lo sabe
cada proyecto.

El vhost reenvía el header `Authorization` a PHP (`SetEnvIf`). Sin eso Apache lo
descarta y cualquier API con tokens Bearer responde 401 a todo.

### Versiones fijas

`install-php-extensions` se baja de una release concreta y se verifica su
sha256; Node.js y el Symfony CLI se instalan agregando su repositorio a mano en
vez de con `curl ... | bash`, que ejecutaría como root lo que el servidor
devuelva en ese momento. Las claves GPG son las mismas que instalaban esos
scripts. Para actualizar cualquiera de las tres se cambian los `ARG` del
Dockerfile a propósito.

`php:8.4-apache-trixie` queda a propósito **sin** fijar por digest: es el único
camino por el que llegan los parches de seguridad de PHP y Debian a todos los
proyectos, y fijarlo los congelaría hasta que alguien lo suba a mano. La
reproducibilidad la da el otro lado: lo que consumen los proyectos es una imagen
ya publicada, inmutable por digest en el registro, y para eso están las tags
fechadas.

## Uso desde un proyecto

En desarrollo el proyecto agrega solo lo suyo encima:

~~~dockerfile
FROM micayael/symfony-base:php84-trixie

# conf.d se carga después del php.ini de esta imagen
COPY php.ini $PHP_INI_DIR/conf.d/zz-app.ini
~~~

Para producción se usa la imagen de desarrollo como etapa de build —ahí están
composer y yarn— y se ensambla sobre la de producción, que no los tiene:

~~~dockerfile
FROM micayael/symfony-base:php84-trixie AS build
COPY . /src
RUN composer install --no-dev --optimize-autoloader --no-interaction \
    && yarn install --frozen-lockfile && yarn encore production

FROM micayael/symfony-base:php84-trixie-prod
COPY --from=build --chown=www-data:www-data /src /src
~~~
