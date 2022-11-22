const SSL_CERTS_FOLDER = `/home/developer/.prepare/ssl-certs`;
const ITEM_SEPARATOR = `|`;
const PORT_SEPARATOR = ` `;
const LOCAL_CERT_PATH = `${SSL_CERTS_FOLDER}/local-cert.pem`;
const LOCAL_KEY_PATH = `${SSL_CERTS_FOLDER}/local-key.pem`;

let proxyTemplate = (port, target) => `
${port} {
    tls ${LOCAL_CERT_PATH} ${LOCAL_KEY_PATH}
    reverse_proxy ${target}
}
`

/* See: https://caddyserver.com/docs/caddyfile/directives/file_server */
let fileServerTemplate = (port, root) => `
${port} {
    tls ${LOCAL_CERT_PATH} ${LOCAL_KEY_PATH}
    root * ${root}
    file_server {
        hide .git
    }
}
`

let generatedConfig = ``;

let proxiesString = process.env['REVERSE_PROXIES'] ?? '';
let proxiesList = proxiesString.split(ITEM_SEPARATOR);

for (let proxy of proxiesList) {
    let [port, ...target] = proxy.trim().split(PORT_SEPARATOR);
    target = target.join(PORT_SEPARATOR);
    if (!port || !target) continue;

    generatedConfig+= proxyTemplate(port, target);
}

let serversString = process.env['FILE_SERVERS'] ?? '';
let serversList = serversString.split(ITEM_SEPARATOR);

for (let server of serversList) {
    let [port, ...root] = server.trim().split(PORT_SEPARATOR);
    root = root.join(PORT_SEPARATOR);
    if (!port || !root) continue;

    generatedConfig+= fileServerTemplate(port, root);
}

/* Output result to be used by >> append on shell */
console.log(generatedConfig);

return generatedConfig;