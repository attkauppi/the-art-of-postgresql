#!/bin/bash

helm \
  --kube-context minikube \
  upgrade \
  --install \
  postgresql \
  oci://registry-1.docker.io/bitnamicharts/postgresql \
  -n default \
  --set service.type=NodePort \
  --set auth.postgresPassword=postgres
  