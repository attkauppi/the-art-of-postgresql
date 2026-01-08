#!/bin/bash
set -euo pipefail

# Define variables.
C_GREEN='\033[32m'
C_RED='\033[31m'
C_RESET_ALL='\033[0m'

# Install packages if needed.
minikube version || brew install minikube
helm version -c || brew install helm

# Install addons.
mkdir -p ~/.minikube/addons

# (Re)Start the service.
# shellcheck disable=SC1083
# MINIKUBE_STATUS=$(minikube status --format  {{.MinikubeStatus}} || true)
# if [ "${MINIKUBE_STATUS}" == "Paused" ] || [ "${MINIKUBE_STATUS}" == "Stopped" ] || [ -z "${MINIKUBE_STATUS}" ]; then
#   echo -e "${C_GREEN}Starting Minikube...${C_RESET_ALL}"
#   minikube start --vm-driver docker --memory 4096 --cpus 4
# elif [ "${MINIKUBE_STATUS}" == "Running" ]; then
#   echo -e "${C_GREEN}Minikube is already running.${C_RESET_ALL}"
# else
#   echo -e "${C_RED}Minikube is in an unknown state.${C_RESET_ALL}"
#   echo -e "${C_RED}Please run 'minikube status' and fix the problem manually.${C_RESET_ALL}"
#   exit 1
# fi
host=$(minikube status --format='{{.Host}}' 2>/dev/null || true)
kubelet=$(minikube status --format='{{.Kubelet}}' 2>/dev/null || true)
apiserver=$(minikube status --format='{{.APIServer}}' 2>/dev/null || true)

if [[ -z "$host" ]]; then
  echo -e "${C_GREEN}Starting Minikube...${C_RESET_ALL}"
  minikube start --driver=docker --memory=4096 --cpus=4

elif [[ "$apiserver" == "Paused" ]]; then
  echo -e "${C_GREEN}Unpausing Minikube...${C_RESET_ALL}"
  minikube unpause

elif [[ "$host" == "Running" && "$kubelet" == "Running" && "$apiserver" == "Running" ]]; then
  echo -e "${C_GREEN}Minikube is already running.${C_RESET_ALL}"

elif [[ "$host" == "Stopped" || "$kubelet" == "Stopped" || "$apiserver" == "Stopped" ]]; then
  echo -e "${C_GREEN}Starting Minikube...${C_RESET_ALL}"
  minikube start --driver=docker --memory=4096 --cpus=4

else
  echo -e "${C_RED}Minikube is in an unknown/partial state.${C_RESET_ALL}"
  echo -e "${C_RED}Host=$host Kubelet=$kubelet APIServer=$apiserver${C_RESET_ALL}"
  echo -e "${C_RED}Please run 'minikube status' and fix the problem manually.${C_RESET_ALL}"
  exit 1
fi

# Set up Minikube context.
echo -e "${C_GREEN}Configuring minikube context...${C_RESET_ALL}"
kubectl config use-context minikube

# This is a hack to ensure tiller is ready.
echo -ne "${C_GREEN}Waiting for Tiller to start..."
while ! helm ls 2>/dev/null; do
  echo -ne "."
  sleep 1
done
echo -e "${C_RESET_ALL}"

# Add/Update Helm chart repositories.
# helm repo add ryr https://charts.requestyoracks.org
helm repo add stable https://charts.helm.sh/stable
helm repo update

# Display a message to tell to update the environment variables.
minikube docker-env

# Enable addons
minikube addons enable heapster
minikube addons enable ingress
minikube addons enable storage-provisioner
minikube addons enable default-storageclass

# Wait for the dashboard to be ready.
# echo -e -n "${C_GREEN}Waiting for the dashboard to be ready...${C_RESET_ALL}"
# until minikube service -n kubernetes-dashboard kubernetes-dashboard >/dev/null 2>&1; do
#   echo -e -n "${C_GREEN}.${C_RESET_ALL}"
#   sleep 1
# done
# echo
