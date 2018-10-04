FROM nginx:1.11-alpine
MAINTAINER Tarek Saier <tareksaier@gmail.com>

RUN rm -rf /usr/share/nginx/html/*
RUN mkdir /usr/share/nginx/html/finder
RUN mkdir /usr/share/nginx/html/viewer
RUN mkdir /usr/share/nginx/html/manager
RUN mkdir /usr/share/nginx/html/editor
RUN mkdir /usr/share/nginx/html/player
COPY ./IIIFCurationFinder/ /usr/share/nginx/html/finder/
COPY ./IIIFCurationViewer/ /usr/share/nginx/html/viewer/
COPY ./IIIFCurationManager/ /usr/share/nginx/html/manager/
COPY ./IIIFCurationEditor/ /usr/share/nginx/html/editor/
COPY ./IIIFCurationPlayer/ /usr/share/nginx/html/player/
