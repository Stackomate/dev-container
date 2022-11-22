# Helper build to clone novnc from git
FROM ubuntu:latest as novnc-build
WORKDIR root
RUN apt-get update && apt-get install -y git && \
    mkdir essentials && \
    git clone https://github.com/novnc/noVNC
WORKDIR noVNC
    # Copy files and folders into essentials, see: https://unix.stackexchange.com/a/68456
RUN cp -r vnc.html app core vendor utils ../essentials/


# Main build, adds graphical interface, vncserver and noVNC, inspired by dorowu/ubuntu-desktop-lxde-vnc and
# https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-vnc-on-ubuntu-20-04
FROM ubuntu:latest

ENV PREPARE_FOLDER=/root/prepare
ENV DESKTOP_THEME="Greybird-dark" 
ENV DESKTOP_WALLPAPER="/usr/share/backgrounds/greybird.svg"

COPY ./firefox-repository-config $PREPARE_FOLDER/firefox-repository-config

RUN apt-get update && \
    # Using DEBIAN_FRONTEND=noninteractive to avoid prompts (e.g. "country of origin for the keyboard"), 
    # see: https://askubuntu.com/a/1006187. Not installing xfce4-goodies to save some space
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    xfce4 \
    # Install the vnc server
    # Instead of tightvnc, install tigervnc as it supports remote resizing and seems to be faster, 
    # see: https://unix.stackexchange.com/a/628754 and https://tigervnc.org/
    tigervnc-standalone-server tigervnc-common \
    # Install curl, git and nano
    curl \
    git \
    nano \
    # Used to forward signals to our sh script in CMD for Docker, see: https://github.com/Yelp/dumb-init
    # and also https://engineeringblog.yelp.com/2016/01/dumb-init-an-init-for-docker.html
    dumb-init \
    # Install a default terminal, see: https://askubuntu.com/a/1118319
    xfce4-terminal \
    # Install websockify, a dependency of noVNC, requires python3
    # python3-numpy is used to improve performance of websockify     
    python3-numpy websockify \
    # Install software-properties-common for later use of add-apt-repository, 
    # see: https://itsfoss.com/add-apt-repository-command-not-found/,
    # used by firefox install below
    software-properties-common \
    # Install sudo for later use with developer user, 
    # see: https://unix.stackexchange.com/a/425664
    sudo && \    
    # Assign default terminal, see: https://askubuntu.com/a/1118319
    printf "2\n" | update-alternatives --config x-terminal-emulator && \
    # Install Firefox, see: https://www.omgubuntu.co.uk/2022/04/how-to-install-firefox-deb-apt-ubuntu-22-04
    add-apt-repository ppa:mozillateam/ppa && \
    cat $PREPARE_FOLDER/firefox-repository-config >> /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:${distro_codename}";' | tee /etc/apt/apt.conf.d/51unattended-upgrades-firefox && \
    apt-get install -y firefox

    # Only copy necessary files, see: https://github.com/novnc/noVNC/blob/master/docs/EMBEDDING.md#files
COPY --from=novnc-build /root/essentials $PREPARE_FOLDER/noVNC

COPY ./entrypoint.sh $PREPARE_FOLDER/entrypoint.sh
COPY ./xstartup-config $PREPARE_FOLDER/xstartup-config
COPY ./reconfigure.sh $PREPARE_FOLDER/reconfigure.sh
COPY ./autostart.desktop $PREPARE_FOLDER/autostart.desktop
    # Redirect index.html to vnc.html with redirect tag 
COPY ./index.html $PREPARE_FOLDER/noVNC/index.html
COPY ./bootstrap-vnc.sh $PREPARE_FOLDER/bootstrap-vnc.sh

    # Make files executable
RUN chmod +x $PREPARE_FOLDER/xstartup-config $PREPARE_FOLDER/entrypoint.sh $PREPARE_FOLDER/reconfigure.sh && \
    # Make Desktop directory for icons
    mkdir -p $PREPARE_FOLDER/Desktop

# See dumb-init explanation above
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

# start noVNC (web interface), see: https://github.com/novnc/noVNC#quick-start
# Use string to access bash variable, see: https://stackoverflow.com/a/40454758
CMD $PREPARE_FOLDER/entrypoint.sh
