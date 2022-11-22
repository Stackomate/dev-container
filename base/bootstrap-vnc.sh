# Provide password to vncserver, see: https://askubuntu.com/a/568188

if [ -z ${VNC_PASSWORD+x} ]; 
    then echo "VNC_PASSWORD was not provided"; 
    else 
        # Suppressing output, see https://askubuntu.com/a/474566
        printf "${VNC_PASSWORD}\n${VNC_PASSWORD}\n\n" | vncpasswd > /dev/null 2>&1 && \
        echo "VNC_PASSWORD has been set"; 
fi

# Call reconfigure to change desktop settings, see https://unix.stackexchange.com/a/267238
mkdir -p  ~/.config/xfce4 && \
# Append reconfigure to xinitrc
echo "~/.prepare/reconfigure.sh; . /etc/xdg/xfce4/xinitrc" >> ~/.config/xfce4/xinitrc

# Not using -localhost because container will expose ports to host
# -alwaysshared will allow multiple users at the same time
# process, see https://linux.die.net/man/1/vncserver
# tigerVNC seems to use -localhost yes by default
# Toggle security based on VNC_PASSWORD value
# see: https://serverfault.com/a/580859

if [ -z ${VNC_PASSWORD+x} ]; 
    then SEC_TYPE="None"; 
    else 
        SEC_TYPE="VncAuth";
fi

USER=developer vncserver -alwaysshared -SecurityTypes $SEC_TYPE