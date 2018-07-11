#!/bin/bash

# Configurate the external URL here (without trailing slash)
externalurl=http://136.187.82.133/cp


jk_git_url="https://github.com/IllDepence/JSONkeeper.git"
ci_git_url="https://github.com/IllDepence/Canvas-Indexer.git"
cv_zip_url="http://codh.rois.ac.jp/software/download/IIIFCurationViewer_20180710.zip"
cf_zip_url="http://codh.rois.ac.jp/software/download/IIIFCurationFinder_20180710.zip"

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
git clone $jk_git_url
git clone $ci_git_url
cp -v jk/.dockerignore jk/* JSONkeeper
cp -v ci/.dockerignore ci/* Canvas-Indexer
sed -i -E "s/server_url =.+/server_url = $exturlesc\/curation/" JSONkeeper/config.ini
sed -i -E "s/as_sources =.+/as_sources = $exturlesc\/curation\/as\/collection.json/" Canvas-Indexer/config.ini

# CV and CF
rm -rf IIIFCurationViewer
rm -rf IIIFCurationFinder

curl $cv_zip_url -o cv_tmp.zip
mkdir cv_tmp_folder
unzip -q -d cv_tmp_folder cv_tmp.zip
rm cv_tmp.zip
cvunzipped=`ls cv_tmp_folder`
mv -v "cv_tmp_folder/${cvunzipped}" IIIFCurationViewer
rmdir cv_tmp_folder

curl $cf_zip_url -o cf_tmp.zip
mkdir cf_tmp_folder
unzip -q -d cf_tmp_folder cf_tmp.zip
rm cf_tmp.zip
cfunzipped=`ls cf_tmp_folder`
mv -v "cf_tmp_folder/${cfunzipped}" IIIFCurationFinder
rmdir cf_tmp_folder

cp -v cv/.dockerignore cv/* IIIFCurationViewer
cp -v cf/.dockerignore cf/* IIIFCurationFinder
sed -i -E "s/curationJsonExportUrl: '.+'/curationJsonExportUrl: '$exturlesc\/curation\/api'/" IIIFCurationViewer/index.js
sed -i -E "s/curationJsonExportUrl: '.+'/curationJsonExportUrl: '$exturlesc\/curation\/api'/" IIIFCurationFinder/index.js
sed -i -E "s/curationViewerUrl: '.+'/curationViewerUrl: '$exturlesc\/viewer\/'/" IIIFCurationFinder/index.js
sed -i -E "s/searchEndpointUrl: '.+'/searchEndpointUrl: '$exturlesc\/ci\/api'/" IIIFCurationFinder/index.js
sed -i -E "s/facetsEndpointUrl: '.+'/facetsEndpointUrl: '$exturlesc\/ci\/facets'/" IIIFCurationFinder/index.js
sed -i -E "s/redirectUrl: '.+'/redirectUrl: '$exturlesc\/viewer\/'/" IIIFCurationFinder/exportJsonKeeper.js

./reset.sh
