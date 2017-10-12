# Docker Impala

Run Impala in a Docker container.

```bash
docker-compose up -d
```

When Impala has started the web UI will be visible (after a minute or so) by running:

```bash
open http://$(docker-machine ip):25000
```

(Note that for troubleshooting purposes you can connect to the container with `docker-compose exec impala bash`, then check _/tmp/supervisord.log_ and the log files in _/var/log/hadoop-hdfs_, _/var/log/hive_, and _/var/log/impala_.)

Perform a trivial query:

```bash
docker-compose exec impala impala-shell -q 'select 1'
```

Shutdown the container with:

```bash
docker-compose down
```

This is based on the work at [https://github.com/parrot-stream](https://github.com/parrot-stream), the main difference being that unnecessary services like YARN are
 not included. 