#!/bin/sh

rm -rf .git
git init
git checkout -b main
git add . 
git commit -m "initial commit"