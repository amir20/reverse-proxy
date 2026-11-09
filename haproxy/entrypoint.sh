#!/bin/sh
# Starts HAProxy once the agent certificate exists, then swaps in renewals
# over the runtime socket so connected Dozzle instances are not dropped.
PEM=/certs/agent.pem
SOCK=/tmp/haproxy.sock
INTERVAL=${CERT_CHECK_SECONDS:-300}

until [ -s "$PEM" ]; do
  echo "waiting for $PEM"
  sleep 2
done
cp "$PEM" /tmp/loaded.pem

(
  while sleep "$INTERVAL"; do
    cmp -s "$PEM" /tmp/loaded.pem && continue
    set_out=$( { printf 'set ssl cert %s <<\n' "$PEM"; cat "$PEM"; printf '\n'; } | socat -t 2 - "UNIX-CONNECT:$SOCK")
    commit_out=$(echo "commit ssl cert $PEM" | socat -t 2 - "UNIX-CONNECT:$SOCK")
    case "$commit_out" in
      *Success*) cp "$PEM" /tmp/loaded.pem; echo "reloaded $PEM" ;;
      *) echo "certificate update failed: $set_out $commit_out"
         echo "abort ssl cert $PEM" | socat -t 2 - "UNIX-CONNECT:$SOCK" >/dev/null ;;
    esac
  done
) &

exec haproxy -W -db -f /usr/local/etc/haproxy/haproxy.cfg
