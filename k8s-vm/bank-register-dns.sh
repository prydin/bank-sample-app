#!/bin/sh
# Self-register this VM's A record in the bank.local zone.
#
# Runs once at first boot (invoked from each VM's cloud-init runcmd). Reads the
# DNS server VIP from the systemd-resolved drop-in that cloud-init wrote, so the
# VIP only has to be configured in one place per VM (the bank.conf write_files
# entry), not duplicated here.
#
# Requires: nsupdate (bind9-dnsutils) and the TSIG key at /etc/bank/tsig.key.
set -eu

TSIG_KEY=/etc/bank/tsig.key
ZONE=bank.local
RESOLV_DROPIN=/etc/systemd/resolved.conf.d/bank.conf

DNS_SERVER=$(awk -F= '/^DNS=/ { print $2 }' "$RESOLV_DROPIN" | awk '{ print $1 }')
MYIP=$(hostname -I | awk '{ print $1 }')
HOST=$(hostname -s)

nsupdate -k "$TSIG_KEY" <<EOF
server $DNS_SERVER
zone $ZONE.
update delete $HOST.$ZONE. A
update add $HOST.$ZONE. 60 A $MYIP
send
EOF
