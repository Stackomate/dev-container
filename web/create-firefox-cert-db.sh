cd ~ && \
# Suppress output and errors
# Wait until the certificate DB is created for firefox, then kill the process gracefully,
# see https://superuser.com/a/878745,
# https://docs.oracle.com/cd/E19120-01/open.solaris/819-2380/spprocess-95930/index.html,
# https://stackoverflow.com/questions/6363441/check-if-a-file-exists-with-a-wildcard-in-a-shell-script
# Start firefox headless on the background too
echo "Begin creating certificate db"
(firefox https://google.com/ -headless > /dev/null 2>&1) &
until compgen -G ~/.mozilla/firefox/*/cert9.db  > /dev/null;
do
    sleep 1
done
echo "Found certificate db for Firefox"
# -15 stands for SIGTERM
pkill -15 firefox
echo "Finish creating certificate db"