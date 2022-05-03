#!/bin/sh
cd /data/git/gogs-repositories/hashicraft/payments.git
rm -rf .git
git config --global user.email "admin@hashicraft.com"
git config --global user.name "Barry"
git init
git checkout -b main
git add . 
git commit -m "initial commit"