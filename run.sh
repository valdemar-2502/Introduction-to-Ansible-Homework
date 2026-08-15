#!/bin/bash

echo "=== Starting containers ==="
docker run --name "ubuntu" -d pycontribs/ubuntu:latest sleep 999999
docker run --name "centos7" -d pycontribs/centos:7 sleep 999999
docker run --name "fedora" -d pycontribs/fedora:latest sleep 999999

echo "=== Installing Python in containers ==="
docker exec centos7 bash -c "
  sed -i 's|^mirrorlist=|#mirrorlist=|g; s|^#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*.repo
  yum clean all && yum install -y python3
" >/dev/null 2>&1

docker exec ubuntu bash -c "apt-get update && apt-get install -y python3" >/dev/null 2>&1
docker exec fedora bash -c "dnf install -y python3" >/dev/null 2>&1

echo "=== Running playbook ==="
ansible-playbook -i inventory/prod.yml site.yml --ask-vault-pass

echo "=== Stopping containers ==="
docker stop ubuntu centos7 fedora
docker rm ubuntu centos7 fedora
