#!/bin/sh

# Copy the gogs db
cp /data/gogs/data/gogs.db.bak /data/gogs/data/gogs.db

/app/gogs/docker/start.sh