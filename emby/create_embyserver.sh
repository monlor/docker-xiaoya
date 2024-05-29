#!/bin/sh

docker pull amilys/embyserver:latest
docker pull amilys/embyserver_arm64v8:latest

docker buildx imagetools create \
  --tag monlor/embyserver:latest \
  amilys/embyserver:latest \
  amilys/embyserver_arm64v8:latest