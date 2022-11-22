echo "Configuring certificates and Caddy server"

mv $PREPARE_FOLDER/create-firefox-cert-db.sh /home/developer/.prepare/create-firefox-cert-db.sh
mv $PREPARE_FOLDER/generate-certs.sh /home/developer/.prepare/generate-certs.sh

# Start headless firefox to create database
su developer -c '. /home/developer/.prepare/create-firefox-cert-db.sh';
# Temporarily disable need for sudo, since mkcert -install requires it while running as developer user,
# TODO: check https://askubuntu.com/a/425762
echo 'developer ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
su developer -c '. /home/developer/.prepare/generate-certs.sh' && \
# Revert password sudo requirement for developer user by
# erasing the last line of /etc/sudoers file
sed -i '$ d' /etc/sudoers && \

mv $PREPARE_FOLDER/Caddyfile /home/developer/.prepare/Caddyfile && \
mv $PREPARE_FOLDER/generate-caddy-config.js /home/developer/.prepare/generate-caddy-config.js && \

# If there was a chance that caddy had been running,
# we would also need caddy stop here, but that's not 
# necessary during startup 
# Suppressing logs
su developer -c '
mkdir -p /home/developer/.prepare/generated/ && \
node /home/developer/.prepare/generate-caddy-config.js >> /home/developer/.prepare/generated/Caddyfile && \
/usr/bin/caddy start --config /home/developer/.prepare/Caddyfile
';