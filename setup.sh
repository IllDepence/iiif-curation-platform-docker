#!/bin/bash

# Configurate the external URL (without trailing slash) and start port number here
externalurl=http://192.168.0.158/cp

start_port=9001

jk_git_url="https://github.com/IllDepence/JSONkeeper.git"
ci_git_url="https://github.com/IllDepence/Canvas-Indexer.git"
cv_zip_url="http://codh.rois.ac.jp/software/download/IIIFCurationViewer_latest.zip"
cf_zip_url="http://codh.rois.ac.jp/software/download/IIIFCurationFinder_latest.zip"
cm_zip_url="http://codh.rois.ac.jp/software/download/IIIFCurationManager_latest.zip"
ce_zip_url="http://codh.rois.ac.jp/software/download/IIIFCurationEditor_latest.zip"

# NOTE: services are expected to be accessible at
# - JSONkeeper: <externalurl>/curation/
# - Canvas Indexer: <externalurl>/index/
# - Curation Viewer: <externalurl>/viewer/
# - Curation Finder: <externalurl>/finder/
# - Curation Manager: <externalurl>/manager/
# - Curation Editor: <externalurl>/editor/
# - Loris: <externalurl>/image/
# from outside (web/intranet/...)
# and will be exposed by docker at
# - JSONkeeper: http://127.0.0.1:<start_port>
# - Canvas Indexer: http://127.0.0.1:<start_port+1>
# - Curation Viewer: http://127.0.0.1:<start_port+2>/viewer
# - Curation Finder: http://127.0.0.1:<start_port+2>/finder
# - Curation Manager: http://127.0.0.1:<start_port+2>/manager
# - Curation Editor: http://127.0.0.1:<start_port+2>/editor
# - Loris: http://127.0.0.1:<start_port+3>
# see README.md for a proxy configuration examples

exturlesc="${externalurl//\//\\/}"

# - - - - - Jk and CI - - - - -
rm -rf JSONkeeper
rm -rf Canvas-Indexer
git clone $jk_git_url
git clone $ci_git_url
cp -rv jk/.dockerignore jk/* JSONkeeper
cp -rv ci/.dockerignore ci/* Canvas-Indexer
sed -i -E "s/server_url =.+/server_url = $exturlesc\/curation/" JSONkeeper/config.ini
sed -i -E "s/as_sources =.+/as_sources = $exturlesc\/curation\/as\/collection.json/" Canvas-Indexer/config.ini

# check if a custom api path for JSONkeeper was defined
sharp='#'
api_line=`cat jk/config.ini | grep api_path | head -n 1`
if [ -z "${api_line##*$sharp*}" ]; then
    # default path
    jk_api_path='api'
else
    # clean and save custom path
    tmp_line=`echo $api_line | sed 's/.*api_path\s*=\s*//g'`
    jk_api_path=`echo $tmp_line | sed 's/\s*$//g'`
fi

# - - - - - CV and CF - - - - -
rm -rf Frontend/IIIFCurationViewer
rm -rf Frontend/IIIFCurationFinder

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

sed -i -E "s/curationJsonExportUrl: '.+'/curationJsonExportUrl: '$exturlesc\/curation\/$jk_api_path'/" IIIFCurationViewer/index.js
sed -i -E "s/curationJsonExportUrl: '.+'/curationJsonExportUrl: '$exturlesc\/curation\/$jk_api_path'/" IIIFCurationFinder/index.js
sed -i -E "s/curationViewerUrl: '.+'/curationViewerUrl: '$exturlesc\/viewer\/'/" IIIFCurationFinder/index.js
sed -i -E "s/searchEndpointUrl: '.+'/searchEndpointUrl: '$exturlesc\/index\/api'/" IIIFCurationFinder/index.js
sed -i -E "s/facetsEndpointUrl: '.+'/facetsEndpointUrl: '$exturlesc\/index\/facets'/" IIIFCurationFinder/index.js
sed -i -E "s/redirectUrl: '.+'/redirectUrl: '$exturlesc\/viewer\/'/" IIIFCurationFinder/exportJsonKeeper.js

# - - - - - CM and CE - - - - -
rm -rf Frontend/IIIFCurationManager
rm -rf Frontend/IIIFCurationEditor

curl $cm_zip_url -o cm_tmp.zip
mkdir cm_tmp_folder
unzip -q -d cm_tmp_folder cm_tmp.zip
rm cm_tmp.zip
cmunzipped=`ls cm_tmp_folder`
mv -v "cm_tmp_folder/${cmunzipped}" IIIFCurationManager
rmdir cm_tmp_folder

curl $ce_zip_url -o ce_tmp.zip
mkdir ce_tmp_folder
unzip -q -d ce_tmp_folder ce_tmp.zip
rm ce_tmp.zip
ceunzipped=`ls ce_tmp_folder`
mv -v "ce_tmp_folder/${ceunzipped}" IIIFCurationEditor
rmdir ce_tmp_folder

cp -v cm/.dockerignore cm/* IIIFCurationManager
cp -v ce/.dockerignore ce/* IIIFCurationEditor

sed -i -E "s/curationJsonExportUrl: '.+'/curationJsonExportUrl: '$exturlesc\/curation\/$jk_api_path'/" IIIFCurationEditor/index.js
sed -i -E "s/curationJsonExportUrl: '.+'/curationJsonExportUrl: '$exturlesc\/curation\/$jk_api_path'/" IIIFCurationManager/index.js
sed -i -E "s/curationViewerUrl: '.+'/curationViewerUrl: '$exturlesc\/viewer\/'/" IIIFCurationManager/index.js
sed -i -E "s/jsonKeeperEditorUrl: '.+'/jsonKeeperEditorUrl: '$exturlesc\/editor\/'/" IIIFCurationManager/index.js

# - - - - - move frontent components - - - - -
# (so that the frontend dockerfile is be able to access the folders)
mv IIIFCurationViewer Frontend/
mv IIIFCurationFinder Frontend/
mv IIIFCurationManager Frontend/
mv IIIFCurationEditor Frontend/

# - - - - - Docker Compose - - - - -
cp docker-compose.yml.dist docker-compose.yml
sed -i -E "s/strtport/$start_port/" docker-compose.yml
sed -i -E "s/jkport/$((start_port + 0))/" docker-compose.yml
sed -i -E "s/ciport/$((start_port + 1))/" docker-compose.yml
sed -i -E "s/feport/$((start_port + 2))/" docker-compose.yml
sed -i -E "s/lport/$((start_port + 3))/" docker-compose.yml

echo -n "curation_platform_$start_port" > proj_name

./reset.sh

docker-compose --project-name `cat ./proj_name` build
docker-compose --project-name `cat ./proj_name` up --build --no-start
