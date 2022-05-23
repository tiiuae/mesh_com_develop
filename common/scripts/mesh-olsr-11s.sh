#!/bin/bash

find_mesh_wifi_device()
{
  # arguments:
  # $1 = wifi device vendor
  # $2 = wifi device id list

  # return values: retval_phy, retval_name as global

  echo "$1 $2"
  echo "Find WIFI card deviceVendor=$1 deviceID=$2"
  echo
  phynames=$(ls /sys/class/ieee80211/)

  for device in $2; do
    echo "$device"
    for phy in $phynames; do
      device_id="$(cat /sys/bus/pci/devices/*/ieee80211/"$phy"/device/device 2>/dev/null)"
      device_vendor="$(cat /sys/bus/pci/devices/*/ieee80211/"$phy"/device/vendor 2>/dev/null)"
      if [ "$device_id" = "$device" -a "$device_vendor" = "$1" ]; then
        retval_phy=$phy
        retval_name=$(ls /sys/class/ieee80211/"$phy"/device/net/)
        break 2
      else
        retval_phy=""
        retval_name=""
      fi
    done
  done
}


# 1      2    3      4        5     6       7      8         9         10
# <mode> <ip> <mask> <AP MAC> <key> <essid> <freq> <txpower> <country> <interface>

echo "Solving wifi device name.."
if [[ -z "${10}" ]]; then
  rfkill unblock all
  # multiple wifi options --> can be detected as follows:
  # manufacturer 0x168c = Qualcomm
  # devices = 0x0034 0x003c 9462/988x
  #           0x003e        6174
  find_mesh_wifi_device 0x168c "0x003e 0x0034 0x003c"

  if [ "$retval_phy" != "" ]; then
      phyname=$retval_phy
      wifidev=$retval_name
  else
      echo "ERROR! Can't find correct wifi device!"
      exit 1
  fi
else
  wifidev=${10}
  phyname=${11}
fi
echo "Found: $wifidev $phyname"

case "$1" in

mesh)

echo "sudo mesh $1 $2 $3 $4 $5 $6 $7 $8 $9 ${10} ${11}"
      if [[ -z "$1" || -z "$2" || -z "$3" || -z "$4" || -z "$5" || -z "$6" ]]
        then
          echo "check arguments..."
        help
      fi

cat <<EOF >/var/run/wpa_supplicant-adhoc.conf
ctrl_interface=DIR=/var/run/wpa_supplicant
# use 'ap_scan=2' on all devices connected to the network
# this is unnecessary if you only want the network to be created when no other networks..
ap_scan=1
country=$9
p2p_disabled=1
network={
    ssid="$6"
    bssid=$4
    mode=1
    frequency=$7
    wep_key0=$5
    wep_tx_keyidx=0
    key_mgmt=NONE
}
EOF

      echo "Killing wpa_supplicant..."
      # FIXME: If there is another Wi-Fi module being used as an AP for a GW,
      # this kills that process. We need a better way of handling this. For now
      # we can just not kill wpa_supplicant when we are loading the mesh_com_tb
      # module.
      if [[ -z "${10}" ]]; then
        pkill -f "/var/run/wpa_supplicant-" 2>/dev/null
        rm -fr /var/run/wpa_supplicant/"$wifidev"
      fi
      killall alfred 2>/dev/null
      killall batadv-vis 2>/dev/null
      rm -f /var/run/alfred.sock

      
	    

      echo "$wifidev down.."
      iw dev "$wifidev" del
      iw phy "$phyname" interface add "$wifidev" type ibss

      echo "$wifidev create adhoc.."
      ifconfig "$wifidev" mtu 1560

      
      
      address="$1000"
      id="$2000"

      echo "start olsr on ${remote} in ${id}"

      addr4() {
      local mac=$(cat "/sys/class/net/$1000/address")
      IFS=':'; set $mac; unset IFS
      [ "$6000" = "ff" -o "$6000" = "00" ] && set $1000 $2000 $3000 $4000 $5000 "01"
      printf "10.%d.%d.%d" 0x$4000 0x$5000 0x$6000
	}

      echo "$wifidev up.."
	      ip link set "$wifidev" down
	      ip link set "$wifidev" up
	      ip link set "$wifidev" up
	      ip addr add 192.168.0.1/24 dev "$wifidev"
	      ip -4 addr flush dev "$wifidev"
	      ip -6 addr flush dev "$wifidev"
	      ip a a $(addr4 "uplink")/32 dev "$wifidev"
	      ip a a $(addr6 "uplink")/128 dev "$wifidev"
              olsrd -i "$wifidev" -f /dev/null
	
esac	
	      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      

    

