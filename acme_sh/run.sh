#!/usr/bin/with-contenv bashio

ACCOUNT=$(bashio::config 'account')
SERVER=$(bashio::config 'server')
DOMAINS=$(bashio::config 'domains')
KEYFILE=$(bashio::config 'keyfile')
CERTFILE=$(bashio::config 'certfile')
DNS_PROVIDER=$(bashio::config 'dns.provider')
DNS_ENVS=$(bashio::config 'dns.env')
DOMAIN_ALIAS=$(bashio::config 'domain_alias')
ACME_HOME=$(bashio::config 'data_folder' '/data/acme.sh')

if [ ! -d "$ACME_HOME" ]; then
    bashio::log.info "Creating $ACME_HOME folder to store certificate configuration data"
    mkdir -p $ACME_HOME
fi
bashio::log.info "Certificate configuration data written to $ACME_HOME"

for env in $DNS_ENVS; do
    export $env
done

DOMAIN_ARR=()
for domain in $DOMAINS; do
    DOMAIN_ARR+=(--domain "$domain")
done

SERVER_ARG="zerossl"
if bashio::config.has_value 'server'; then
    SERVER_ARG="--server $SERVER"
fi

DOMAIN_ALIAS_ARG=""
if bashio::config.has_value 'domain_alias'; then
    DOMAIN_ALIAS_ARG="--domain-alias $DOMAIN_ALIAS"
fi

/root/.acme.sh/acme.sh --register-account --home $ACME_HOME -m ${ACCOUNT} $SERVER_ARG

/root/.acme.sh/acme.sh --issue --home $ACME_HOME "${DOMAIN_ARR[@]}" \
--dns "$DNS_PROVIDER" \
$SERVER_ARG \
$DOMAIN_ALIAS_ARG

/root/.acme.sh/acme.sh --install-cert --home $ACME_HOME "${DOMAIN_ARR[@]}" \
--fullchain-file "/ssl/${CERTFILE}" \
--key-file "/ssl/${KEYFILE}" \

[ $? -eq 0 ] && bashio::log.info "New certificate installed to /ssl/${CERTFILE}"
