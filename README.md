Docker setup for running all parts of the [IIIF Curation Platform](http://codh.rois.ac.jp/iiif-curation-platform/) (ICP).

# Overview

This repository contains scripts and configuration files for setting up an ICP instance with Docker containers.  
To use the platform *within a local network*, it is sufficient to set the value of `externalurl` in the file `setup.sh` to your IP within the network and then execute `./setup.sh` followed by `./start.sh`.  In order to host a remotely accessible instance you need to know how to configure proxy settings of a web server (see details below).  
Note that IIIF Curation Viewer, IIIF Curation Editor and JSONkeeper are usable out of the box. In order to make use of IIIF Curation Finder, IIIF Curation Manager and Canvas Indexer you have to configure Firebase authentication (see section *First use* below).

### Functionality

The setup script `setup.sh` retrieves all of the ICP components and configures them so that they work together nicely and can be started with Docker. To do so it copies over files from the folders `ce`, `cf`, `ci`, `cm`, `cp`, `cv` and `jk` and then edits them in their respective destinations (folders `Frontent/IIIFCurationViewer`, `JSONkeeper`, etc.). This means that you can either make configuration changes in files in `ce`, `cf`, ... and then run `setup.sh`, or you first run the script and then edit configuration files in `Frontend/IIIFCurationViewer`, `JSONkeeper`, ... (the latter is preferred).

# Use

### First use

* in setup.sh, set the value of `externalurl` and `start_port`
* *if* Firebase is to be used
    * place a file `firebase-adminsdk.json` in jk/
    * uncomment the firebase config section in jk/config.ini
    * place a modified `authFirebase.js` in cv/, cf/, cm/ and ce/
    * add the host part of `externalurl` to the authorized domains in your Firebase console
* `$ ./setup.sh`
* `$ ./start.sh`

### General use

* `$ ./setup.sh`: reset everything (application code, configuration, containers)
* `$ ./reset.sh`: reset containers (i.e application storage, but not configuration) (does not work with older Docker versions; verified with version 17.12.1)
* `$ docker restart <container_id>`: make configuration changes take effect

### Proxy config examples

Let's assume you want to serve the bundle on `<your_host>/cp/...`, have therefore set `externalurl` in setup.sh to `<your_host>/cp` (no trailing slash) and set the `start_port` to 8001. Proxy configurations then may look as follows:

#### Apache

        # JSONkeeper
        ProxyPassMatch "^/cp/curation/(.*)" "http://127.0.0.1:8001/$1"
        ProxyPassReverse "^/cp/curation/(.*)" "http://127.0.0.1:8001/$1"
        # Canvas Indexer
        ProxyPassMatch "^/cp/index/(.*)" "http://127.0.0.1:8002/$1"
        ProxyPassReverse "^/cp/index/(.*)" "http://127.0.0.1:8002/$1"
        # IIIF Curation Viewer
        ProxyPassMatch "^/cp/viewer/(.*)" "http://127.0.0.1:8003/viewer/$1"
        ProxyPassReverse "^/cp/viewer/(.*)" "http://127.0.0.1:8003/viewer/$1"
        # IIIF Curation Finder
        ProxyPassMatch "^/cp/finder/(.*)" "http://127.0.0.1:8003/finder/$1"
        ProxyPassReverse "^/cp/finder/(.*)" "http://127.0.0.1:8003/finder/$1"
        # IIIF Curation Manager
        ProxyPassMatch "^/cp/manager/(.*)" "http://127.0.0.1:8003/manager/$1"
        ProxyPassReverse "^/cp/manager/(.*)" "http://127.0.0.1:8003/manager/$1"
        # IIIF Curation Editor
        ProxyPassMatch "^/cp/editor/(.*)" "http://127.0.0.1:8003/editor/$1"
        ProxyPassReverse "^/cp/editor/(.*)" "http://127.0.0.1:8003/editor/$1"
        # IIIF Curation Editor
        ProxyPassMatch "^/cp/player/(.*)" "http://127.0.0.1:8003/player/$1"
        ProxyPassReverse "^/cp/player/(.*)" "http://127.0.0.1:8003/player/$1"
        # # Loris (deactivated by default)
        # ProxyPassMatch "^/cp/image/(.*)" "http://127.0.0.1:8004/$1"
        # ProxyPassReverse "^/cp/image/(.*)" "http://127.0.0.1:8004/$1"

##### Restricting access

* run `docker network inspect curationplatform9001_default`<sup>[2]</sup> while the containers are running
* note the value of `Subnet` (for the network, not a single container)
* if not already existing, generate a htpasswd file (e.g.: `sudo htpasswd -c /etc/apache2/.htpasswd curt`)
* configure Apache as shown below
    * replace `<subnet_value>` with the value you got in the first step
    * replace `<path_to_htpasswd_file>` with the path to your htpasswd file

[2] the network name may differ. run `docker network ls` to see all networks.

‌

        <Location /cp/>
            Authtype Basic
            Authname "Password Required"
            AuthUserFile <path_to_htpasswd_file>
            Require valid-user
            Deny from all
            Allow from <subnet_value>
            Satisfy any
        </Location>

#### Nginx

        # JSONkeeper
        location /cp/curation/ {
            proxy_pass http://127.0.0.1:8001/;
        }
        # Canvas Indexer
        location /cp/index/ {
            proxy_pass http://127.0.0.1:8002/;
        }
        # IIIF Curation Viewer
        location /cp/viewer/ {
            proxy_pass http://127.0.0.1:8003/viewer/;
        }
        # IIIF Curation Finder
        location /cp/finder/ {
            proxy_pass http://127.0.0.1:8003/finder/;
        }
        # IIIF Curation Manager
        location /cp/manager/ {
            proxy_pass http://127.0.0.1:8003/manager/;
        }
        # IIIF Curation Editor
        location /cp/editor/ {
            proxy_pass http://127.0.0.1:8003/editor/;
        }
        # IIIF Curation Player
        location /cp/player/ {
            proxy_pass http://127.0.0.1:8003/player/;
        }
        # # Loris (deactivated by default)
        # location /cp/image/ {
        #     proxy_pass http://127.0.0.1:8004/;
        # }

# Component specific notes

### JSONkeeper & Canvas Indexer

#### Database

JSONkeeper and Canvas Indexer are configured to use a SQLite database by default. You can use other types of databases by just changing the configuration. The Docker containers are set up to support SQLite and PostgreSQL out of the box. If you use another type of database, you might need to add installation instructions for an additional Python database driver in the respective `Dockerfile` files (see [SQLAlchemy supported databases](http://docs.sqlalchemy.org/en/latest/core/engines.html#supported-databases)).
