#!/bin/sh
cp /data/gogs/data/gogs.db.bak /data/gogs/data/gogs.db

cd /data/git/gogs-repositories/hashicraft/payments.git
rm -rf .git
git config --global init.defaultBranch main
git config --global user.email "admin@hashicraft.com"
git config --global user.name "Barry"
git init --bare
git checkout -b main
git add . 
git commit -m "initial commit"

/app/gogs/docker/start.sh