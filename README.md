Docker setup for running all parts of the [IIIF Curation Platform](http://codh.rois.ac.jp/iiif-curation-platform/).

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

* `./setup.sh`: reset everything (application code, configuration, containers)
* `./reset.sh`: reset containers (i.e application storage, but not configuration)
* `docker restart <container_id>`: make configuration changes take effect

### Proxy config examples

Let's assume you want to serve the bundle on `<your_host>/cp/...`, have therefore set `externalurl` in setup.sh to `<your_host>/cp` (no trailing slash) and set the `start_port` to 8001. Proxy configurations then may look as follows:

#### Apache

        ProxyPassMatch "^/cp/curation/(.*)" "http://127.0.0.1:8001/$1"
        ProxyPassReverse "^/cp/curation/(.*)" "http://127.0.0.1:8001/$1"
        ProxyPassMatch "^/cp/index/(.*)" "http://127.0.0.1:8002/$1"
        ProxyPassReverse "^/cp/index/(.*)" "http://127.0.0.1:8002/$1"
        ProxyPassMatch "^/cp/viewer/(.*)" "http://127.0.0.1:8003/$1"
        ProxyPassReverse "^/cp/viewer/(.*)" "http://127.0.0.1:8003/$1"
        ProxyPassMatch "^/cp/finder/(.*)" "http://127.0.0.1:8004/$1"
        ProxyPassReverse "^/cp/finder/(.*)" "http://127.0.0.1:8004/$1"
        ProxyPassMatch "^/cp/manager/(.*)" "http://127.0.0.1:8005/$1"
        ProxyPassReverse "^/cp/manager/(.*)" "http://127.0.0.1:8005/$1"
        ProxyPassMatch "^/cp/editor/(.*)" "http://127.0.0.1:8006/$1"
        ProxyPassReverse "^/cp/editor/(.*)" "http://127.0.0.1:8006/$1"
        ProxyPassMatch "^/cp/image/(.*)" "http://127.0.0.1:8007/$1"
        ProxyPassReverse "^/cp/image/(.*)" "http://127.0.0.1:8007/$1"

##### Restricting access

* run `docker network inspect curation-framework-docker`<sup>[1]</sup> while the containers are running
* note the value of `Subnet` (for the network, not a single container)
* if not already existing, generate a htpasswd file (e.g.: `sudo htpasswd -c /etc/apache2/.htpasswd curt`)
* configure Apache as shown below
    * replace `<subnet_value>` with the value you got in the first step
    * replace `<path_to_htpasswd_file>` with the path to your htpasswd file

[1] the network name may differ if you renamed the folder in which this repository is placed

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

        location /cp/curation/ {
            proxy_pass http://127.0.0.1:8001/;
        }
        location /cp/index/ {
            proxy_pass http://127.0.0.1:8002/;
        }
        location /cp/viewer/ {
            proxy_pass http://127.0.0.1:8003/;
        }
        location /cp/finder/ {
            proxy_pass http://127.0.0.1:8004/;
        }
        location /cp/manager/ {
            proxy_pass http://127.0.0.1:8005/;
        }
        location /cp/editor/ {
            proxy_pass http://127.0.0.1:8006/;
        }
        location /cp/image/ {
            proxy_pass http://127.0.0.1:8007/;
        }
