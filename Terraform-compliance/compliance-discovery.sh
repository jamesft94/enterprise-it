#!/usr/bin/env bash

if lsblk -f | grep -q "crypto_LUKS"; then
  LUKS_ENCRYPTED=true
else
  LUKS_ENCRYPTED=false
fi

if systemctl is-active --quiet mdatp || systemctl is-active --quiet falcon-sensor; then
  EDR_RUNNING=true
else
  EDR_RUNNING=false
fi

cat <<EOF
{
  "luks_encryption_enabled": $LUKS_ENCRYPTED,
  "edr_sensor_active": $EDR_RUNNING
}
EOF