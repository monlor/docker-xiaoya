#!/bin/sh

docker pull nyanmisaka/jellyfin:240401-amd64
docker pull nyanmisaka/jellyfin:240401-arm64

docker buildx imagetools create \
  --tag monlor/jellyfin:latest \
  nyanmisaka/jellyfin:240401-amd64 \
  nyanmisaka/jellyfin:240401-arm64