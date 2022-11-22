# Install mkcert using non-root user (developer)
mkcert -install && \
# Create auxiliary folder for keeping ssl certificates
mkdir /home/developer/.prepare/ssl-certs && \
# Add local.mylocal.org to certicate and then append generated SSL cert to angular server,
# see https://dev.to/shunyuan/use-angular-cli-to-serve-https-locally-3n2o
mkcert -cert-file /home/developer/.prepare/ssl-certs/local-cert.pem \
       -key-file /home/developer/.prepare/ssl-certs/local-key.pem \
        $CERT_HOSTS $EXTRA_CERT_HOSTS