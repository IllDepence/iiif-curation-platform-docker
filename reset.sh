#!/bin/bash

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
