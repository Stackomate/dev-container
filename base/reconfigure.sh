# Configure xfce4 to use a single workspace, to avoid switching workspaces 
# when using the scrollwheel, see: http://www.both.org/?p=1769
xfconf-query -c xfwm4 -p /general/workspace_count --create -t int -s 1
# Use dark-theme, see: https://unix.stackexchange.com/a/64377
xfconf-query -c xsettings -p /Net/ThemeName --create -t string -s $DESKTOP_THEME
# Set default wallpaper, see: https://unix.stackexchange.com/a/596112
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorVNC-0/workspace0/last-image --create -t string -s $DESKTOP_WALLPAPER
# Disable screensaver
xfconf-query -c xfce4-screensaver -p /saver/enabled -t bool -s false --create
# Disable locking desktop
xfconf-query -c xfce4-screensaver -p /lock/enabled -t bool -s false --create