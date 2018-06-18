Docker setup for running all parts of the [IIIF Curation Platform](http://codh.rois.ac.jp/iiif-curation-platform/).

### First use

* in setup.sh, set the value of `externalurl`
* `$ ./setup.sh`
* `$ docker-compose up --build`

### General use

* `./setup.sh`: reset everything (application code, configuration, containers)
* `./reset.sh`: reset containers (i.e application storage, but not configuration)
* `docker restart <container_id>`: make configuration changes take effect
