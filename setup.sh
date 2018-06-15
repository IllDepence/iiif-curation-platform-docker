#!/bin/bash

# Jk and CI
rm -rf JSONkeeper
rm -rf Canvas-Indexer
git clone https://github.com/IllDepence/JSONkeeper.git
git clone https://github.com/IllDepence/Canvas-Indexer.git
cp -v jk/.dockerignore jk/Dockerfile jk/gunicorn_config.py jk/config.ini JSONkeeper
cp -v ci/.dockerignore ci/Dockerfile ci/gunicorn_config.py ci/config.ini Canvas-Indexer

# CV and CF
rm -rf IIIFCurationViewer
rm -rf IIIFCurationFinder
cp -r cv/IIIFCurationViewer .
cp -r cf/IIIFCurationFinder .
sed -i -E "s/curationJsonExportUrl: '.+'/curationJsonExportUrl: 'http:\/\/jsonkeeper:8000\/api'/" IIIFCurationViewer/index.js
sed -i -E "s/curationJsonExportUrl: '.+'/curationJsonExportUrl: 'http:\/\/jsonkeeper:8000\/api'/" IIIFCurationFinder/index.js
sed -i -E "s/curationViewerUrl: '.+'/curationViewerUrl: 'http:\/\/curationviewer'/" IIIFCurationFinder/index.js
sed -i -E "s/searchEndpointUrl: '.+'/searchEndpointUrl: 'http:\/\/canvasindexer\/api'/" IIIFCurationFinder/index.js
sed -i -E "s/facetsEndpointUrl: '.+'/searchEndpointUrl: 'http:\/\/canvasindexer\/facets'/" IIIFCurationFinder/index.js
sed -i -E "s/redirectUrl: '.+'/redirectUrl: 'http:\/\/curationviewer'/" IIIFCurationFinder/exportJsonKeeper.js
cp -v cv/.dockerignore cv/Dockerfile IIIFCurationViewer
cp -v cf/.dockerignore cf/Dockerfile IIIFCurationFinder

cic=`docker ps -a -q -f name=curationframeworkbackend_canvasindexer_1`
jkc=`docker ps -a -q -f name=curationframeworkbackend_jsonkeeper_1`
cvc=`docker ps -a -q -f name=curationframeworkbackend_curationviewer_1`
cfc=`docker ps -a -q -f name=curationframeworkbackend_curationfinder_1`
if [ ! -z "$cic" -a "$cic" != "" ]; then
    docker container rm "$cic"
fi
if [ ! -z "$jkc" -a "$jkc" != "" ]; then
    docker container rm "$jkc"
fi
if [ ! -z "$cvc" -a "$cvc" != "" ]; then
    docker container rm "$cvc"
fi
if [ ! -z "$cfc" -a "$cfc" != "" ]; then
    docker container rm "$cfc"
fi
