#!/bin/bash

git clone https://github.com/IllDepence/JSONkeeper.git
git clone https://github.com/IllDepence/Canvas-Indexer.git
cp -v jk/.dockerignore jk/Dockerfile jk/gunicorn_config.py jk/config.ini JSONkeeper
cp -v ci/.dockerignore ci/Dockerfile ci/gunicorn_config.py ci/config.ini Canvas-Indexer
