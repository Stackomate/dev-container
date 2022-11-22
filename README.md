# Development Container 

## Base

A basic image with graphical interface, VNC server and noVNC
Inspired by `dorowu/docker-ubuntu-vnc-desktop`, but created from scratch with slightly different features:

- Support for `ubuntu:latest` only.
- [xfce4](https://www.xfce.org/) with minimal features for the Desktop Environment.
    - Using dark theme
- [TigerVNC](https://tigervnc.org/) for high-performance and automatic resolution scaling.
    - Supports password for VNC access
- `xfce4-terminal`, `curl`, `git` and `nano` installed by default.
- Single Browser (Firefox).
- Faster initialization and termination of created containers.
- User `developer` as default (rootless, but in `sudo`ers group).
- Add desktop icons by mounting (or copying) files to /`home/developer/Desktop`, or `/root/prepare/Desktop`.
    - `.desktop` can be made executable to avoid [`Untrusted Application`](https://askubuntu.com/questions/10395/untrusted-application-launcher) warning

### Environment Variables (Optional)
- `UID` and `GID`: Linux users are encouraged to provide their real user and group ids to avoid file ownership issues on mounted volumes.
- `VNC_PASSWORD`: Password to establish a connection via a VNC client.
    - If password is not **between 6 and 8 characters**, you may get an error such as `password:getpassword error: Inappropriate ioctl for device`
- `SUDO_PASSWORD`: Password for running `sudo` commands.
- `ON_USER_CREATE`: Script that can be run after `developer` user is created. Will be `eval`uated as `root`, before the graphical interface starts.
    - E.g.: `ON_USER_CREATE=echo "user created"`
- `ON_NEW_SESSION`: Script that will run on desktop autostart. Useful for loading items that depend on the display manager.
    - E.g.: `ON_NEW_SESSION="firefox https://www.awwwards.com"`
- `DESKTOP_THEME`: Choose a name for your theme. Default is `Greybird-dark`, for light colors you may use `Greybird`.
- `DESKTOP_WALLPAPER`: Choose a wallpaper for your workspace. Default is `/usr/share/backgrounds/greybird.svg`.

### Example
`docker run -p 6080:6080 -e UID=$(id -u) -e GID=$(id -g) -e VNC_PASSWORD=pass1234 -e SUDO_PASSWORD=mysudo -v $(pwd):/mapped dev-container-base`
Wait for `Navigate to this URL:` and then navigate to `http://localhost:6080` instead (same port used in `-p` command above).

### Known Issues
- Getting black screen when accessing noVNC on a Linux `amd64` host.
    - Very likely related to `startxfce4 &` in `xstartup-config` not finding the server (`X server already running on display :1`). It works with `usr/bin/firefox` instead.
    - It might be trying to connect to the host display.

## Web

### Caddy
- Built-in Reverse proxy and file server.
- Built-in certificate authority.

### Environment Variables (Optional)
- `REVERSE_PROXIES`: Create a SSL reverse proxy with Caddy. Separate proxies with `|`, the first port will be the port used by HTTPS, followed by the url to be proxied
    - E.g.: `localhost:443 localhost:8080|`
    - You can proxy other containers on the same docker network by providing their name. E.g.: `9999 my-container-name:7654` 
- `FILE_SERVERS`: Create a SSL file server with Caddy. Separate servers with `|`, the first port will be used by HTTPS, followed by the path to be served
    - E.g.: `7777 /mounted/directory`
- `EXTRA_CERT_HOSTS`: Extra hosts for which the certificate will be issued. Defaults for `CERT_HOSTS` are `localhost 127.0.0.1 192.168.1.109 172.18.0.1 ::1`
    - **Tip** If you want to add custom domains, e.g.: `local.mylocal.org`, also add them to [`extra_hosts`](https://docs.docker.com/compose/compose-file/compose-file-v3/#extra_hosts) on docker-compose or `--add-host` and to `REVERSE_PROXIES`/`FILE_SERVERS`    
- `EXTRA_CADDY_CONFIG`: Append extra config to Caddyfile.

## Using from Stackomate Registry (Recommended)

- Simple example:

```
docker run \
-p 6080:6080 \
-e UID=$(id -u) \
-e GID=$(id -g) \
gt.rcr.is/stackomate/dev-container-web
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
gt.rcr.is/stackomate/dev-container-web
```

## Build Locally And Run `dev-container-web` - Example
Change `TARGETPLATFORM` accordingly below:
- With many options:
```
TARGETPLATFORM=linux/amd64 
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
-v $(pwd):/mapped gt.rcr.is/stackomate/dev-container-web
```