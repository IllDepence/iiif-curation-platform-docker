Docker setup for running all parts of the [IIIF Curation Platform](http://codh.rois.ac.jp/iiif-curation-platform/).

### First use

* in setup.sh, set the value of `externalurl`
* `$ ./setup.sh`
* `$ docker-compose up --build`

### General use

* `./setup.sh`: reset everything (application code, configuration, containers)
* `./reset.sh`: reset containers (i.e application storage, but not configuration)
* `docker restart <container_id>`: make configuration changes take effect

### Apache proxy config example

        ProxyPassMatch "^/curation/(.*)" "http://127.0.0.1:8001/$1"
        ProxyPassReverse "^/curation/(.*)" "http://127.0.0.1:8001/$1"
        ProxyPassMatch "^/ci/(.*)" "http://127.0.0.1:8002/$1"
        ProxyPassReverse "^/ci/(.*)" "http://127.0.0.1:8002/$1"
        ProxyPassMatch "^/find/(.*)" "http://127.0.0.1:8003/$1"
        ProxyPassReverse "^/find/(.*)" "http://127.0.0.1:8003/$1"
        ProxyPassMatch "^/view/(.*)" "http://127.0.0.1:8004/$1"
        ProxyPassReverse "^/view/(.*)" "http://127.0.0.1:8004/$1"
