# NGINX Host Confluence Unit [![Docker Pulls](https://img.shields.io/docker/pulls/handcraftedbits/nginx-unit-confluence.svg?maxAge=2592000)](https://hub.docker.com/r/handcraftedbits/nginx-unit-confluence)

A [Docker](https://www.docker.com) container that provides an
[Atlassian Confluence](https://www.atlassian.com/software/confluence) unit for
[NGINX Host](https://github.com/handcraftedbits/docker-nginx-host).

# Features

* Atlassian Confluence 6.0.5
* NGINX Host SSL certificates are automatically imported into Confluence's JVM so Atlassian application links can
  easily be created

# Support Notes

This container uses [OpenJDK](http://openjdk.java.net/) for its JVM and as such this unit is considered an **unsupported
platform** by Atlassian.

# Usage

## Prerequisites

### Database

Make sure you have a
[supported database](https://confluence.atlassian.com/doc/database-configuration-159764.html) available either as a
container or standalone.

### `NGINX_UNIT_HOSTS` Considerations

It is important that the value of your `NGINX_UNIT_HOSTS` environment variable is set to a single value and doesn't
include wildcards or regular expressions as this value will be used by Confluence to determine the hostname.

## Configuration

It is highly recommended that you use container orchestration software such as
[Docker Compose](https://www.docker.com/products/docker-compose) when using this NGINX Host unit as several Docker
containers are required for operation.  This guide will assume that you are using Docker Compose.  Additionally, we
will use the [official PostgreSQL Docker container](https://hub.docker.com/_/postgres/) for our database.

To begin, start with a basic `docker-compose.yml` file as described in the
[NGINX Host configuration guide](https://github.com/handcraftedbits/docker-nginx-host#configuration).  Then, add a
service for the database (named `db-confluence`) and the NGINX Host Confluence unit (named `confluence`):

```yaml
confluence:
  image: handcraftedbits/nginx-unit-confluence
  environment:
    - NGINX_UNIT_HOSTS=mysite.com
    - NGINX_URL_PREFIX=/confluence
  links:
    - db-confluence
  volumes:
    - /home/me/confluence:/opt/data/confluence
  volumes_from:
    - data

db-confluence:
  image: postgres
  environment:
    - POSTGRES_USER=user
    - POSTGRES_PASSWORD=password
    - POSTGRES_DB=confluence
  volumes:
    /home/me/db-confluence:/var/lib/postgresql/data
```

Observe the following:

* We create a link in `confluence` to `db-confluence` in order to allow Confluence to connect to our database.
* We mount `/opt/data/confluence` using the local directory `/home/me/confluence`.  This is the directory where
  Confluence stores its data.
* As with any other NGINX Host unit, we mount the volumes from our
  [NGINX Host data container](https://github.com/handcraftedbits/docker-nginx-host-data), in this case named `data`.

For more information on configuring the PostgreSQL container, consult its
[documentation](https://hub.docker.com/_/postgres/).

Finally, we need to create a link in our NGINX Host container to the `confluence` container in order to proxy
Confluence.  Here is our final `docker-compose.yml` file:

```yaml
version: "3"

services:
  confluence:
    image: handcraftedbits/nginx-unit-confluence
    environment:
      - NGINX_UNIT_HOSTS=mysite.com
      - NGINX_URL_PREFIX=/confluence
    links:
      - db-confluence
    volumes:
      - /home/me/confluence:/opt/data/confluence
    volumes_from:
      - data

  data:
    image: handcraftedbits/nginx-host-data

  db-confluence:
    image: postgres
    environment:
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=password
      - POSTGRES_DB=confluence
    volumes:
      /home/me/db-confluence:/var/lib/postgresql/data

  proxy:
    image: handcraftedbits/nginx-host
    depends_on:
      confluence:
        condition: service_healthy
    ports:
      - "443:443"
    volumes:
      - /etc/letsencrypt:/etc/letsencrypt
      - /home/me/dhparam.pem:/etc/ssl/dhparam.pem
    volumes_from:
      - data
```

This will result in making a Confluence instance available at `https://mysite.com/confluence`.

## Running the NGINX Host Confluence Unit

Assuming you are using Docker Compose, simply run `docker-compose up` in the same directory as your
`docker-compose.yml` file.  Otherwise, you will need to start each container with `docker run` or a suitable
alternative, making sure to add the appropriate environment variables and volume references.

When configuring Confluence, be sure to select `PostgreSQL` as your database, `db-confluence` as the database hostname,
and `5432` as the database port if you configured your database according to the previous section.

# Reference

## Environment Variables

Please see the NGINX Host [documentation](https://github.com/handcraftedbits/docker-nginx-host#units) for information
on the environment variables understood by this unit.
