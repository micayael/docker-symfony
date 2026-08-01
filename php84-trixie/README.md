symfony-base
------------

~~~
docker build -t micayael/symfony-base:php84-trixie .
~~~

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

El vhost reenvía el header `Authorization` a PHP (`SetEnvIf`). Sin eso Apache lo
descarta y cualquier API con tokens Bearer responde 401 a todo.

### Versiones fijas

`install-php-extensions` se baja de una release concreta y se verifica su
sha256; Node.js y el Symfony CLI se instalan agregando su repositorio a mano en
vez de con `curl ... | bash`, que ejecutaría como root lo que el servidor
devuelva en ese momento. Las claves GPG son las mismas que instalaban esos
scripts. Para actualizar cualquiera de las tres se cambian los `ARG` del
Dockerfile a propósito.

## Uso desde un proyecto

El proyecto agrega solo lo suyo encima:

~~~dockerfile
FROM micayael/symfony-base:php84-trixie

# conf.d se carga después del php.ini de esta imagen
COPY php.ini $PHP_INI_DIR/conf.d/zz-app.ini
~~~
