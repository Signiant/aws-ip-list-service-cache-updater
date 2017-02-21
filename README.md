# aws-ip-list-service-cache-updater
Small container that keeps the cache fresh for a linked [aws-ip-ranges](https://github.com/Signiant/aws-ip-list-service) container

# Purpose
Designed to be used in a linked docker container model to keep the cache up to date in the main ip-ranges container.

# Usage

```bash
docker pull signiant/aws-ip-list-service-cache-updater
```

This command below assumes you have first started the ip-ranges container and called it `ip-list` with the `--name` argument to docker

```bash
docker run --link ip-list:ip-list \
   --volumes-from ip-list \
    signiant/aws-ip-list-service-cache-updater
```
