FROM ${BASE_URL}

ARG TARGETPLATFORM

    # TODO: Use nvm directly (or add a shortcut on the desktop)

    # Install node, see: https://github.com/nodesource/distributions/blob/master/README.md#using-ubuntu-4
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - &&\
    sudo apt-get install -y nodejs && \
    # Verify node and npm are working
    node --version && \
    npm --version && \
    # Update npm, install pnpm and verify it's working
    npm i -g npm pnpm && \
    pnpm -v && \
    # Install mkcert to ignore SSL errors for local servers
    # Firefox requires certificates installed from non-root directory,
    # see https://github.com/FiloSottile/mkcert/issues/120
    apt-get install libnss3-tools && \
    # Target multiple builds with TARGETPLATFORM argument from buildx, see:
    # https://stackoverflow.com/a/58225906
    curl -JLO "https://dl.filippo.io/mkcert/latest?for=${TARGETPLATFORM}" && \
    chmod +x mkcert-v*-* && \ 
    cp mkcert-v*-* /usr/local/bin/mkcert && \
    # Avoid "the public key is not available" for caddy
    # https://github.com/caddyserver/dist/issues/83#issuecomment-1128964076
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg && \
    # Install caddy, see https://caddyserver.com/docs/install#debian-ubuntu-raspbian
    apt-get install -y apt-transport-https && \
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list && \
    apt-get update && \
    apt-get install caddy && \      
    # TODO: Check if still necessary
    # libpci missing after upgrade, see https://askubuntu.com/a/1334253
    apt-get install -y \
    libpci-dev \
    # Install NSS (Network Security Libraries)
    libnss3-tools

# Copy certificate and caddy server configuration script to be executed after user creation
COPY ./configure-server.sh $PREPARE_FOLDER/configure-server.sh
COPY ./Caddyfile $PREPARE_FOLDER/Caddyfile
COPY ./create-firefox-cert-db.sh $PREPARE_FOLDER/create-firefox-cert-db.sh
COPY ./generate-certs.sh $PREPARE_FOLDER/generate-certs.sh
COPY ./generate-caddy-config.js $PREPARE_FOLDER/generate-caddy-config.js

ENV ON_USER_CREATE=". $PREPARE_FOLDER/configure-server.sh"
ENV CERT_HOSTS="localhost 127.0.0.1 192.168.1.109 172.18.0.1 ::1"