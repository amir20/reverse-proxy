#!/bin/sh
# Writes the agent certificate Traefik issued as one PEM for HAProxy.
DIR=/dump/agent.doligence.dozzle.dev
[ -s "$DIR/certificate.crt" ] && [ -s "$DIR/privatekey.key" ] || exit 0
cat "$DIR/certificate.crt" "$DIR/privatekey.key" > /certs/agent.pem.tmp
chown 99:99 /certs/agent.pem.tmp
chmod 600 /certs/agent.pem.tmp
mv /certs/agent.pem.tmp /certs/agent.pem
