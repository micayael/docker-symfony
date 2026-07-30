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
