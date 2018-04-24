

```bash
VERSION=`curl https://github.com/docker/compose/releases | sed -n 's_^\s*<a href="/docker/compose/releases/tag/\([0-9]\+\(\.[0-9]\+\)\+\)">\1</a>\s*$_\1_p' | head --line=1`
curl --location https://github.com/docker/compose/releases/download/${VERSION}/docker-compose-`uname --kernel-name`-`uname --machine` --output /usr/local/bin/docker-compose

DOCKER_COMPOSE_URL='https://s3.amazonaws.com/workflowexecutor/seahorse/releases/1.4.3/docker-compose.yml'
DOCKER_COMPOSE_YML=${DOCKER_COMPOSE_URL##*/} 
curl --location ${DOCKER_COMPOSE_URL} --output ${DOCKER_COMPOSE_YML} 
```
