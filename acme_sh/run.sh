#!/usr/bin/with-contenv bashio

ACCOUNT=$(bashio::config 'account')
SERVER=$(bashio::config 'server')
DOMAINS=$(bashio::config 'domains')
KEYFILE=$(bashio::config 'keyfile')
CERTFILE=$(bashio::config 'certfile')
DNS_PROVIDER=$(bashio::config 'dns.provider')
DNS_ENVS=$(bashio::config 'dns.env')
DOMAIN_ALIAS=$(bashio::config 'domain_alias')
ACME_HOME=$(bashio::config 'data_folder' '/data')

export ACME_HOME=$ACME_HOME

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

/root/.acme.sh/acme.sh --register-account -m ${ACCOUNT} $SERVER_ARG

/root/.acme.sh/acme.sh --issue "${DOMAIN_ARR[@]}" \
--dns "$DNS_PROVIDER" \
$SERVER_ARG \
$DOMAIN_ALIAS_ARG

/root/.acme.sh/acme.sh --install-cert "${DOMAIN_ARR[@]}" \
--fullchain-file "/ssl/${CERTFILE}" \
--key-file "/ssl/${KEYFILE}" \
