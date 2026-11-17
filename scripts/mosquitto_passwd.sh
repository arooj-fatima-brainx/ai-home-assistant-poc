#!/usr/bin/env bash
# Creates mosquitto/config/passwd with one user for the simulator and one for Home Assistant.
# Reads credentials from .env. Run once before the first `docker compose up`.
#
# Credentials are passed to the container as environment variables (never interpolated
# into the shell command) and hashed with `mosquitto_passwd -U`, so passwords never
# appear in a command line or the process list.
set -euo pipefail
cd "$(dirname "$0")/.."
set -a; source .env; set +a

: "${MQTT_USERNAME:?set MQTT_USERNAME in .env}"
: "${MQTT_PASSWORD:?set MQTT_PASSWORD in .env}"
: "${HA_MQTT_USERNAME:?set HA_MQTT_USERNAME in .env}"
: "${HA_MQTT_PASSWORD:?set HA_MQTT_PASSWORD in .env}"

docker run --rm \
  -e MQTT_USERNAME -e MQTT_PASSWORD -e HA_MQTT_USERNAME -e HA_MQTT_PASSWORD \
  -v "$PWD/mosquitto/config:/mosquitto/config" \
  eclipse-mosquitto:2.0.22 sh -c '
    set -e
    umask 077
    f=/mosquitto/config/passwd
    printf "%s:%s\n%s:%s\n" \
      "$MQTT_USERNAME" "$MQTT_PASSWORD" "$HA_MQTT_USERNAME" "$HA_MQTT_PASSWORD" > "$f"
    mosquitto_passwd -U "$f"
    chmod 0700 "$f"'
echo "Wrote mosquitto/config/passwd"
