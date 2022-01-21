#!/bin/bash
#Device Provisioning Protocol (also known as Wi-Fi Easy Connect) allows
#enrolling of head-less devices in a secure Wi-Fi network using many
#methods like QR code/NAN/BLE based authentication, PKEX based
#authentication (password with in-band provisioning), etc. In DPP a
#configurator is used to provide network credentials to the devices. The
#three phases of DPP connection are authentication, configuration and
#network connection.
#More information about Wi-Fi Easy Connect is available from the Wi-Fi
#Alliance web page:
#https://www.wi-fi.org/discover-wi-fi/wi-fi-easy-connect
#WPA_SUPPLICANT required configs are as given below.
#CONFIG_INTERWORKING=y
#CONFIG_DPP=y
#CONFIG_IEEE80211W=y

function help
{
    echo
    echo "Usage: sudo ./dpp_onboarding.sh <mode> <ip> <mask>  <country> <interface> <phyname> <key>"
    echo "Parameters:"
    echo "	<mode>"
    echo "	<ip>"
    echo "	<mask>"
    echo "	<country>"
    echo "	<interface>" - optional
    echo "	<phyname>"   - optional
    echo "      <key>"
    echo
    echo "example:"
    echo "sudo ./dpp_onboarding.sh dpp_enrolee 192.168.1.2 255.255.255.0 AE wlan0 phy0 DPP_CONFIGURATOR_KEY"
    exit
}

# 1      2       3      4          5          6       7
# <mode> <ip> <mask>  <country> <interface> <phyname><dpp_configurator_key>

# ToDo: check if dpp is supported

wifidev=${5}
phyname=${6}
mac_addr=$(ifconfig $wifidev | grep ether | awk '{ print $2 }')
dpp_config_key=${7}
echo $mac_addr $dpp_config_key
# Initialize global operating classes; e.g., 81/1 is the 2.4
#GHz channel 1 on 2412 MHz.)
dpp_channel="81/1"

case "$1" in

dpp_enrolee)

echo "sudo DPP $1 $2 $3 $4 $5 $6"
      if [[ -z "$1" || -z "$2" || -z "$3" || -z "$4" || -z "$5" || -z "$6" ]]
        then
          echo "check arguments..."
        help
      fi

cat <<EOF >/var/run/wpa_supplicant-dpp.conf
ctrl_interface=DIR=/var/run/wpa_supplicant
ctrl_interface_group=0
update_config=1
pmf=2
dpp_config_processing=2
EOF

echo "Killing wpa_supplicant..."
      pkill -f "/var/run/wpa_supplicant-" 2>/dev/null
      rm -fr /var/run/wpa_supplicant/"$wifidev"

      echo "$wifidev up.."
      ip link set "$wifidev" up

      sleep 2
      wpa_supplicant -i "$wifidev" -c /var/run/wpa_supplicant-dpp.conf -D nl80211 -C /var/run/wpa_supplicant/ -B -f /tmp/wpa_supplicant_dpp.log

      sleep 2
      #Generate QR code for the device. Store the QR code id returned by the command.
      bootstrapping_info_id=$(wpa_cli dpp_bootstrap_gen type=qrcode mac=$mac_addr chan=$dpp_channel key=$dpp_config_key)
      echo "bootstrapping_info_id:" $bootstrapping_info_id


      bootstrapping_uri=$(wpa_cli dpp_bootstrap_get_uri $bootstrapping_info_id)
      echo "bootstrapping_uri:" $bootstrapping_uri

      status=$(wpa_cli dpp_listen 2412)
      echo "dpp listen status:" $status

      #wait for configurator object
      #To Do: Synchronization with DPP initiator configurator
      status=$(wpa_cli save_config)
      echo "DPP configurator object status:" $status

      #reload with DPP configuration
      status=$(wpa_cli reconfigure)
      echo "DPP reconfigure status:" $status
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
