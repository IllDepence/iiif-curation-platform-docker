#!/bin/bash

rm -rf JSONkeeper
rm -rf Canvas-Indexer
git clone https://github.com/IllDepence/JSONkeeper.git
git clone https://github.com/IllDepence/Canvas-Indexer.git
cp -v jk/.dockerignore jk/Dockerfile jk/gunicorn_config.py jk/config.ini JSONkeeper
cp -v ci/.dockerignore ci/Dockerfile ci/gunicorn_config.py ci/config.ini Canvas-Indexer

cic=`docker ps -a -q -f name=curationframeworkbackend_canvasindexer_1`
jkc=`docker ps -a -q -f name=curationframeworkbackend_jsonkeeper_1`
if [ ! -z "$cic" -a "$cic" != "" ]; then
    docker container rm "$cic"
fi
if [ ! -z "$jkc" -a "$jkc" != "" ]; then
    docker container rm "$jkc"
fi
