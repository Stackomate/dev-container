## dev-container-web

A Docker image containing everything from [`dev-container-base`](../base/README.md), plus:

- [Node.js](https://nodejs.org/) (LTS version)
    - [pnpm](https://pnpm.io/) - an efficient package manager.
    - Node configured to use `mkcert` local certificates.
- Caddy - a built-in web server with local HTTPS support
    - Reverse proxy and file server.
    - Certificate authority.

### Environment Variables (Optional)
- `REVERSE_PROXIES`: Create a SSL reverse proxy with Caddy. Separate proxies with `|`, the first port will be the port used by HTTPS, followed by the url to be proxied
    - E.g.: `localhost:443 localhost:8080|`
    - You can proxy other containers on the same docker network by providing their name. E.g.: `9999 my-container-name:7654` 
- `FILE_SERVERS`: Create a SSL file server with Caddy. Separate servers with `|`, the first port will be used by HTTPS, followed by the path to be served
    - E.g.: `7777 /mounted/directory`
- `EXTRA_CERT_HOSTS`: Extra hosts for which the certificate will be issued. Defaults for `CERT_HOSTS` are `localhost 127.0.0.1 192.168.1.109 172.18.0.1 ::1`
    - **Tip** If you want to add custom domains, e.g.: `local.mylocal.org`, also add them to [`extra_hosts`](https://docs.docker.com/compose/compose-file/compose-file-v3/#extra_hosts) on docker-compose or `--add-host` and to `REVERSE_PROXIES`/`FILE_SERVERS`    
- `EXTRA_CADDY_CONFIG`: Append extra config to Caddyfile.
- `NODE_EXTRA_CA_CERTS`: Append created certs to the Node.js runtime, e.g.:
    - `NODE_EXTRA_CA_CERTS="$(mkcert -CAROOT)/rootCA.pem"` will add our local certs to Node.js

## Using Previously Built Image (Recommended)

- Simple example:

```
docker run \
-p 6080:6080 \
-e UID=$(id -u) \
-e GID=$(id -g) \
ghcr.io/stackomate/dev-container-web
```
Wait for `Navigate to this URL:` and then navigate to `http://localhost:6080` instead (same port used in `-p` command above).

- Customizable example:
```
docker run \
-p 6080:6080 \
-e UID=$(id -u) \
-e GID=$(id -g) \
-e VNC_PASSWORD=avocado \
-e SUDO_PASSWORD=orange \
-e ON_NEW_SESSION="firefox https://www.placeholder.com" \
--add-host local.mylocal.org:127.0.0.1 \
-e EXTRA_CERT_HOSTS="local.mylocal.org" \
-e REVERSE_PROXIES="localhost:443 localhost:8080 | local.mylocal.org:443 localhost:8080" \
-e FILE_SERVERS="localhost:7777 /home/developer/.config | localhost:8888 /mapped" \
-v $(pwd):/home/developer/Desktop/project \
${WEB_URL}
```

## Build Locally And Run `dev-container-web` - Example
Change `TARGETPLATFORM` accordingly below:
- With many options:
```
TARGETPLATFORM=linux/arm64
BASE_URL="base-image-url-here"
WEB_URL="web-image-url-here"
. build.sh && \
docker run \
-p 6080:6080 \
-e UID=$(id -u) \
-e GID=$(id -g) \
-e VNC_PASSWORD=password \
-e SUDO_PASSWORD=password \
-e ON_NEW_SESSION="firefox https://www.firefox.com" \
-e EXTRA_CERT_HOSTS="local.mylocal.org" \
-e REVERSE_PROXIES="localhost:443 localhost:8080 | local.mylocal.org:443 localhost:8080" \
-e FILE_SERVERS="localhost:7777 /home/developer/.config | localhost:8888 /mapped" \
-v $(pwd):/mapped \
-v $(pwd)/examples/package-viewer.desktop:/home/developer/Desktop/package-viewer.desktop \
dev-container-web
```
- Simple:
```
. build.sh && \
docker run -p 6080:6080 -e UID=$(id -u) -e GID=$(id -g) \
-v $(pwd):/mapped ${WEB_URL}
```