#!/usr/bin/env bash

interrupt() {
  echo
  echo "Caught ^C, exiting."
  exit 1
}

trap interrupt SIGINT

if [ -n "${ACCEPT_CA_TERMS:-}" ]; then
  DEHYDRATED_CMD="/dehydrated --accept-terms"
else
  DEHYDRATED_CMD="/dehydrated"
fi

if [ ! -e /letsencrypt/well-known ]; then
  mkdir -p /letsencrypt/well-known
  chmod 755 /letsencrypt/well-known
fi;

while true; do
  $DEHYDRATED_CMD --cron --keep-going --challenge http-01
  $DEHYDRATED_CMD --cleanup
  inotifywait --timeout 86400 /letsencrypt/domains.txt
  sleep 60
done

