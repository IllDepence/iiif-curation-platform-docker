Docker setup for running all parts of the [IIIF Curation Platform](http://codh.rois.ac.jp/iiif-curation-platform/).

### First use

* in setup.sh, set the value of `externalurl`
* `$ ./setup.sh`
* `$ docker-compose up --build`

### General use

* `./setup.sh`: reset everything (application code, configuration, containers)
* `./reset.sh`: reset containers (i.e application storage, but not configuration)
* `docker restart <container_id>`: make configuration changes take effect

### Proxy config examples

#### Apache

        ProxyPassMatch "^/curation/(.*)" "http://127.0.0.1:8001/$1"
        ProxyPassReverse "^/curation/(.*)" "http://127.0.0.1:8001/$1"
        ProxyPassMatch "^/ci/(.*)" "http://127.0.0.1:8002/$1"
        ProxyPassReverse "^/ci/(.*)" "http://127.0.0.1:8002/$1"
        ProxyPassMatch "^/find/(.*)" "http://127.0.0.1:8003/$1"
        ProxyPassReverse "^/find/(.*)" "http://127.0.0.1:8003/$1"
        ProxyPassMatch "^/view/(.*)" "http://127.0.0.1:8004/$1"
        ProxyPassReverse "^/view/(.*)" "http://127.0.0.1:8004/$1"

##### Restricting access

* run `docker network inspect curationframeworkbackend_default` while the containers are running
* note the value of `Subnet` (for the network, not a single container)
* if not already existing, generate a htpasswd file (e.g.: `sudo htpasswd -c /etc/apache2/.htpasswd curt`)
* configure Apache as shown below
    * replace `<subnet_value>` with the value you got in the first step
    * replace `<path_to_htpasswd_file>` with the path to your htpasswd file

        <Proxy *>
        Authtype Basic
        Authname "Password Required"
        AuthUserFile <path_to_htpasswd_file>
        Require valid-user
        Deny from all
        Allow from <subnet_value>
        Satisfy any
        </Proxy>

#### Nginx

        location /curation/ {
            proxy_pass http://127.0.0.1:8001/;
        }
        location /ci/ {
            proxy_pass http://127.0.0.1:8002/;
        }
        location /find/ {
            proxy_pass http://127.0.0.1:8003/;
        }
        location /view/ {
            proxy_pass http://127.0.0.1:8004/;
        }
