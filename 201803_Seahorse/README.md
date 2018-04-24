

```bash
DOCKER_COMPOSE_URL='https://s3.amazonaws.com/workflowexecutor/seahorse/releases/1.4.3/docker-compose.yml'
DOCKER_COMPOSE_YML=${DOCKER_COMPOSE_URL##*/} 
curl --location ${DOCKER_COMPOSE_URL} --output ${DOCKER_COMPOSE_YML} 
```
