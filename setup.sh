#!/bin/bash

# externalurl=http://127.0.0.1
#
# NOTE: services are expected to be accessible at
# - JSONkeeper: <externalurl>/curation
# - Canvas Indexer: <externalurl>/ci
# - Curation Finder: <externalurl>/search
# - Curation Viewer: <externalurl>/view
# from outside (web/intranet/...)
# and will be exposed by docker at
# - JSONkeeper: http://127.0.0.1:8001
# - Canvas Indexer: http://127.0.0.1:8002
# - Curation Finder: http://127.0.0.1:8003
# - Curation Viewer: http://127.0.0.1:8004
#
# exturlexp="${externalurl//\//\\/}"

# Jk and CI
rm -rf JSONkeeper
rm -rf Canvas-Indexer
git clone https://github.com/IllDepence/JSONkeeper.git
git clone https://github.com/IllDepence/Canvas-Indexer.git
cp -v jk/.dockerignore jk/Dockerfile jk/gunicorn_config.py jk/config.ini JSONkeeper
cp -v ci/.dockerignore ci/Dockerfile ci/gunicorn_config.py ci/config.ini ci/log.txt Canvas-Indexer

# CV and CF
rm -rf IIIFCurationViewer
rm -rf IIIFCurationFinder
cp -r cv/IIIFCurationViewer .
cp -r cf/IIIFCurationFinder .
sed -i -E "s/curationJsonExportUrl: '.+'/curationJsonExportUrl: 'http:\/\/127.0.0.1:8001\/api'/" IIIFCurationViewer/index.js
sed -i -E "s/curationJsonExportUrl: '.+'/curationJsonExportUrl: 'http:\/\/127.0.0.1:8001\/api'/" IIIFCurationFinder/index.js
sed -i -E "s/curationViewerUrl: '.+'/curationViewerUrl: 'http:\/\/127.0.0.1:8081'/" IIIFCurationFinder/index.js
sed -i -E "s/searchEndpointUrl: '.+'/searchEndpointUrl: 'http:\/\/127.0.0.1:8002\/api'/" IIIFCurationFinder/index.js
sed -i -E "s/facetsEndpointUrl: '.+'/facetsEndpointUrl: 'http:\/\/127.0.0.1:8002\/facets'/" IIIFCurationFinder/index.js
sed -i -E "s/redirectUrl: '.+'/redirectUrl: 'http:\/\/127.0.0.1:8081'/" IIIFCurationFinder/exportJsonKeeper.js
cp -v cv/.dockerignore cv/Dockerfile IIIFCurationViewer
cp -v cf/.dockerignore cf/Dockerfile IIIFCurationFinder

./reset.sh
