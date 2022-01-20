#!/bin/bash

function help
{
    echo
    echo "Usage: sudo ./p2p.sh <mode> <ip> <mask> <freq>  <country> <interface> <phyname>"
    echo "Parameters:"
    echo "	<mode>"
    echo "	<ip>"
    echo "	<mask>"
    echo "	<freq>"
    echo "	<txpower>"
    echo "	<country>"
    echo "	<interface>" - optional
    echo "	<phyname>"   - optional
    echo
    echo "example:"
    echo "sudo ./p2p.sh p2p_go 192.168.1.2 255.255.255.0  5220 30 fi wlan0 phy0"
    exit
}

# 1      2    3      4        5          6       7      8
# <mode> <ip> <mask> <freq> <txpower> <country> <interface>

# check if p2p mode is supported

wifidev=${7}
phyname=${8}

case "$1" in

p2p_go)

echo "sudo p2p $1 $2 $3 $4 $5 $6 $7 $8"
      if [[ -z "$1" || -z "$2" || -z "$3" || -z "$4" || -z "$5" || -z "$6" ]]
        then
          echo "check arguments..."
        help
      fi

cat <<EOF >/var/run/wpa_supplicant-p2p.conf
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=AE
device_name=COMMS-SLEEVE

# Modify group owner intent, 0-15, the higher
# number indicates preference to become the GO.
p2p_go_intent=15

# Enable HT40(802.11n) for the p2p Group Owner
p2p_go_ht40=1

# Device type
#   1-0050F204-1 (Computer / PC)
#   1-0050F204-2 (Computer / Server)
#   5-0050F204-1 (Storage / NAS)
#   6-0050F204-1 (Network Infrastructure / AP)
device_type=6-0050F204-1
driver_param=p2p_device=6
EOF

echo "Killing wpa_supplicant..."
      pkill -f "/var/run/wpa_supplicant-" 2>/dev/null
      rm -fr /var/run/wpa_supplicant/"$wifidev"

      echo "$wifidev up.."
      ip link set "$wifidev" up

      sleep 2
      wpa_supplicant -i "$wifidev" -c /var/run/wpa_supplicant-p2p.conf -D nl80211 -C /var/run/wpa_supplicant/ -B -f /tmp/wpa_supplicant_p2p.log

      sleep 2
      status=$(wpa_cli -i p2p-dev-wlan0 set config_methods virtual_push_button)
      echo $status
      status=$(wpa_cli -i p2p-dev-wlan0 p2p_find)
      echo $status
      sleep 10
      mac_address=$(wpa_cli -i p2p-dev-wlan0 p2p_peers)
      # Fix Me: handle multiple peer
      echo "found peer:" $mac_address
      sleep 1
      status=$(wpa_cli -i p2p-dev-wlan0 p2p_connect $mac_address pbc)
      echo "Connection status:" $status
      ;;
off)
      # service off
      pkill -f "/var/run/wpa_supplicant-" 2>/dev/null
      rm -fr /var/run/wpa_supplicant/"$wifidev"
      ;;
*)
      help
      ;;
esac
