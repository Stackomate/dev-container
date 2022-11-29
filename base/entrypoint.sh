#!/bin/bash

# Setup a non-root account for regular usage
# Used to represent group id and user id, respectively 
# Setting defaults as 1024, see: https://stackoverflow.com/a/2013589
GID="${GID:-1024}"
UID="${UID:-1024}"

echo "User UID: ${UID}, GID: ${GID}"
# Create a new user called "developer"
# Password for sudo command does not exist by default, see:
# https://askubuntu.com/q/695701 
groupadd -g $GID -o developer && \
# Avoid linux permission issues
useradd -o -u $UID -g $GID -ms /bin/bash developer && \
# Grant sudo priviledges to new user
usermod -aG sudo developer && \
# First, remove password for developer, see: https://askubuntu.com/a/1310583
# Suppressing output, see: https://stackoverflow.com/a/617184
passwd -d developer >/dev/null && \
# Autostart programs and commands, see: https://askubuntu.com/a/1244565,
# https://forum.xfce.org/viewtopic.php?pid=20119#p20119,
# https://specifications.freedesktop.org/desktop-entry-spec/desktop-entry-spec-latest.html#value-types
mkdir -p /home/developer/.config/autostart/ && \
mv $PREPARE_FOLDER/autostart.desktop /home/developer/.config/autostart/autostart.desktop && \
# Chown files, required for mounted volumes on linux
# Fix "useradd: Not copying any file from skel directory into it."
# Investigate solution https://askubuntu.com/a/983656
# Copy /etc/skel into developer's home directory, see:
# https://www.dba-db2.com/2013/07/useradd-in-linux-not-copying-any-file-from-skel-directory-into-it.html
cp -r /etc/skel/. /home/developer && \
echo "Manually copied skel files to /home/developer" && \
chown -R developer /home/developer && \
# Add sudo password, if provided
if [ -z ${SUDO_PASSWORD+x} ]; then
    echo "SUDO_PASSWORD was not provided";
    else 
    # Suppressing output, see: https://stackoverflow.com/a/32729736,
    # using chpasswd instead of passwd, see: https://stackoverflow.com/a/25479559
    # and https://unix.stackexchange.com/a/223975
    su developer -c '
    echo "developer:${SUDO_PASSWORD}" | sudo chpasswd
    ' && \
    echo "SUDO_PASSWORD has been set";
fi

# Create .vnc and .prepare folders to move xstartup file and scripts next
su developer -c 'mkdir ~/.vnc ~/.prepare'
# Overwrite default configuration for vnc
# must be performed by root
mv $PREPARE_FOLDER/xstartup-config /home/developer/.vnc/xstartup
# Move reconfigure.sh from root to developer's folder
mv $PREPARE_FOLDER/reconfigure.sh /home/developer/.prepare/reconfigure.sh
# Move desktop files, see: https://askubuntu.com/a/86891
mkdir -p /home/developer/Desktop
mv $PREPARE_FOLDER/Desktop/* /home/developer/Desktop
# Change ownership of moved files to developer user
chown -R developer /home/developer/Desktop
chown developer /home/developer/.prepare/reconfigure.sh

# Add correct locale to avoid question marks in xfce4-terminal
# See https://forum.xfce.org/viewtopic.php?id=11392 and
# https://wiki.archlinux.org/title/locale
# TODO: Did not have any impact, investigate
echo "LANG=C.utf8" >> /etc/locale.conf

# See https://unix.stackexchange.com/a/561455
# Change encoding directly in the terminal
# TODO: Revisit once LANG issue has been addressed
mkdir -p /home/developer/.config/xfce4/terminal
echo "[Configuration]" >> /home/developer/.config/xfce4/terminal/terminalrc
echo "Encoding=UTF-8" >> /home/developer/.config/xfce4/terminal/terminalrc
chown -R developer /home/developer/.config

# Environment variable that allows for a script to run after user creation
eval $ON_USER_CREATE

# Move bootstrap-vnc.sh from root to developer's folder
mv $PREPARE_FOLDER/bootstrap-vnc.sh /home/developer/.prepare/bootstrap-vnc.sh
# Bootstrap vnc
su developer -c '. /home/developer/.prepare/bootstrap-vnc.sh' 


# start noVNC (web interface), see: https://github.com/novnc/noVNC#quick-start
$PREPARE_FOLDER/noVNC/utils/novnc_proxy --vnc localhost:5901 --listen 6080
