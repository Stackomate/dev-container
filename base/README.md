# dev-container-base

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
- Add desktop icons by mounting (or copying) files to `/home/developer/Desktop`, or `/root/prepare/Desktop`.
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

- Minimal configuration:
```
docker run \
-p 6080:6080 \
-e UID=$(id -u) \
-e GID=$(id -g) \
dev-container-base
```

- Customizable configuration:
```
docker run \
-p 6080:6080 \
-e UID=$(id -u) \
-e GID=$(id -g) \
-e VNC_PASSWORD=pass1234 \
-e SUDO_PASSWORD=mysudo \
-v $(pwd):/mapped/directory dev-container-base
```

Wait for `Navigate to this URL:` and then navigate to `http://localhost:6080` instead (same port used in `-p` command above).

### Known Issues
- Getting black screen when accessing noVNC on Linux Mint hosts.
    - Very likely related to `startxfce4 &` in `xstartup-config` not finding the server (`X server already running on display :1`). It works with `usr/bin/firefox` instead.
    - It might be trying to connect to the host display.
