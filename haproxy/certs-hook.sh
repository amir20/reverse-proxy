#!/bin/sh
# Writes the agent certificate Traefik issued as one PEM for HAProxy.
# Runs can overlap, and a non-zero exit crashes the dumper, so each run uses its
# own temp file and skips a dump it caught half-written.
DIR=/dump/agent.doligence.dozzle.dev
TMP=/certs/agent.pem.$$
[ -s "$DIR/certificate.crt" ] && [ -s "$DIR/privatekey.key" ] || exit 0
# Blank lines end a multi-line payload on the HAProxy socket, and Let's Encrypt
# chains contain one between certificates.
cat "$DIR/certificate.crt" "$DIR/privatekey.key" | grep -v '^$' > "$TMP"
if grep -q 'END CERTIFICATE' "$TMP" && grep -q 'END.*PRIVATE KEY' "$TMP"; then
  chown 99:99 "$TMP"
  chmod 600 "$TMP"
  mv "$TMP" /certs/agent.pem
else
  rm -f "$TMP"
fi
exit 0
