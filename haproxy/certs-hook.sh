#!/bin/sh
# Writes the agent certificate Traefik issued as one PEM for HAProxy.
DIR=/dump/agent.doligence.dozzle.dev
[ -s "$DIR/certificate.crt" ] && [ -s "$DIR/privatekey.key" ] || exit 0
# Blank lines end a multi-line payload on the HAProxy socket, and Let's Encrypt
# chains contain one between certificates.
cat "$DIR/certificate.crt" "$DIR/privatekey.key" | grep -v '^$' > /certs/agent.pem.tmp
chown 99:99 /certs/agent.pem.tmp
chmod 600 /certs/agent.pem.tmp
mv /certs/agent.pem.tmp /certs/agent.pem
