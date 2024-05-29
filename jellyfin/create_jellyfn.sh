#!/bin/sh

docker pull nyanmisaka/jellyfin:240220-amd64-legacy
docker pull nyanmisaka/jellyfin:240220-arm64

docker buildx imagetools create \
  --tag monlor/jellyfin:latest \
  nyanmisaka/jellyfin:240220-amd64-legacy \
  nyanmisaka/jellyfin:240220-arm64