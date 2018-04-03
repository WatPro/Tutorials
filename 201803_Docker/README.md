
# Docker 

### Installation and Run on CentOS

```bash
yum install --assumeyes yum-utils \
    device-mapper-persistent-data \
    lvm2
yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
yum --assumeyes install docker-ce
systemctl start docker
```
