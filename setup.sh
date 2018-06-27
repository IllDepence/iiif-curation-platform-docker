#!/bin/bash

# Configurate the external URL here (without trailing slash)
externalurl=http://136.187.82.133

# NOTE: services are expected to be accessible at
# - JSONkeeper: <externalurl>/curation/
# - Canvas Indexer: <externalurl>/ci/
# - Curation Finder: <externalurl>/finder/
# - Curation Viewer: <externalurl>/viewer/
# from outside (web/intranet/...)
# and will be exposed by docker at
# - JSONkeeper: http://127.0.0.1:8001
# - Canvas Indexer: http://127.0.0.1:8002
# - Curation Finder: http://127.0.0.1:8003
# - Curation Viewer: http://127.0.0.1:8004
# see README.md for a proxy configuration examples

exturlesc="${externalurl//\//\\/}"

# Jk and CI
rm -rf JSONkeeper
rm -rf Canvas-Indexer
git clone https://github.com/IllDepence/JSONkeeper.git
git clone https://github.com/IllDepence/Canvas-Indexer.git
cp -v jk/.dockerignore jk/* JSONkeeper
cp -v ci/.dockerignore ci/* Canvas-Indexer
sed -i -E "s/server_url =.+/server_url = $exturlesc\/curation/" JSONkeeper/config.ini
sed -i -E "s/as_sources =.+/as_sources = $exturlesc\/curation\/as\/collection.json/" Canvas-Indexer/config.ini

# CV and CF
rm -rf IIIFCurationViewer
rm -rf IIIFCurationFinder
cp -r cv/IIIFCurationViewer .
cp -r cf/IIIFCurationFinder .
cp -v cv/.dockerignore cv/Dockerfile IIIFCurationViewer
cp -v cf/.dockerignore cf/Dockerfile IIIFCurationFinder
sed -i -E "s/curationJsonExportUrl: '.+'/curationJsonExportUrl: '$exturlesc\/curation\/api'/" IIIFCurationViewer/index.js
sed -i -E "s/curationJsonExportUrl: '.+'/curationJsonExportUrl: '$exturlesc\/curation\/api'/" IIIFCurationFinder/index.js
sed -i -E "s/curationViewerUrl: '.+'/curationViewerUrl: '$exturlesc\/viewer\/'/" IIIFCurationFinder/index.js
sed -i -E "s/searchEndpointUrl: '.+'/searchEndpointUrl: '$exturlesc\/ci\/api'/" IIIFCurationFinder/index.js
sed -i -E "s/facetsEndpointUrl: '.+'/facetsEndpointUrl: '$exturlesc\/ci\/facets'/" IIIFCurationFinder/index.js
sed -i -E "s/redirectUrl: '.+'/redirectUrl: '$exturlesc\/viewer\/'/" IIIFCurationFinder/exportJsonKeeper.js

./reset.sh
