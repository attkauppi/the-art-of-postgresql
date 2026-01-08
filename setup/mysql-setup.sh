#!/bin/bash

helm \
  --kube-context minikube \
  upgrade --install \
  mysql \
  oci://registry-1.docker.io/bitnamicharts/mysql \
  -n default \
  --set primary.service.type=NodePort \
  --set auth.rootPassword=mysql \
  --set auth.username=mysql \
  --set auth.password=my-mysql \
  --set auth.database=my-mysql \
  --set image.registry=docker.io \
  --set image.repository=bitnamilegacy/mysql \
  --set image.tag=9.4.0-debian-12-r1 \
  --set metrics.image.registry=docker.io \
  --set metrics.image.repository=bitnamilegacy/mysqld-exporter