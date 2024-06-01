#!/bin/bash
# 
# SecurePTT provisioning script
# Copyright (C) 2024  Resilience Theatre
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
# --------
# 
# This script will create parameters for FOUR entities of SecurePTT.
# It is currently hardcoded to use 10.0.0.80 - 10.0.0.83 addresses for
# nodes, please change that as you like.
#
# NOTE: THIS SCRIPT USES /dev/urandom WHICH IS INSECURE FOR OTP USE!
#       ADOPT /dev/urandom TO PROPER TRNG SOURCE BEFORE USING THIS
# 
# If you're using thinklight (on PC), remember this:
#  sudo chmod o+w /sys/class/leds/tpacpi::thinklight/brightness
#
# Set also network capture permissions
#  sudo setcap cap_net_raw,cap_net_admin+eip /usr/local/bin/netmon
#

#
# Proxy IN service file
#
function create_proxy_in_service_file()  {
echo "# proxy-in-$NODE.service " > $CREATE_PATH/proxy-in-$NODE.service
echo "[Unit]" >> $CREATE_PATH/proxy-in-$NODE.service
echo "Description=udpproxy in from 10.0.0.8$NODE" >> $CREATE_PATH/proxy-in-$NODE.service
echo "After=sys-devices-virtual-net-wg0.device" >> $CREATE_PATH/proxy-in-$NODE.service
echo " " >> $CREATE_PATH/proxy-in-$NODE.service
echo "[Service]" >> $CREATE_PATH/proxy-in-$NODE.service
echo "WorkingDirectory=/opt/boot" >> $CREATE_PATH/proxy-in-$NODE.service
echo "ExecStart=/usr/bin/udpproxy -i proxy-in-$NODE.ini" >> $CREATE_PATH/proxy-in-$NODE.service
echo "Type=simple" >> $CREATE_PATH/proxy-in-$NODE.service
echo "Restart=always" >> $CREATE_PATH/proxy-in-$NODE.service
echo "RestartSec=5" >> $CREATE_PATH/proxy-in-$NODE.service
}

#
# Proxy OUT service file
#
function create_proxy_out_service_file()  {
echo "[Unit]" > $CREATE_PATH/proxy-out-$NODE.service
echo "Description=udpproxy to 10.0.0.8$NODE" >> $CREATE_PATH/proxy-out-$NODE.service
echo "After=sys-devices-virtual-net-wg0.device" >> $CREATE_PATH/proxy-out-$NODE.service
echo " " >> $CREATE_PATH/proxy-out-$NODE.service
echo "[Service]" >> $CREATE_PATH/proxy-out-$NODE.service
echo "WorkingDirectory=/opt/boot" >> $CREATE_PATH/proxy-out-$NODE.service
echo "ExecStart=/usr/bin/udpproxy -i proxy-out-$NODE.ini" >> $CREATE_PATH/proxy-out-$NODE.service
echo "Type=simple" >> $CREATE_PATH/proxy-out-$NODE.service
echo "Restart=always" >> $CREATE_PATH/proxy-out-$NODE.service
echo "RestartSec=5" >> $CREATE_PATH/proxy-out-$NODE.service
}

#
# Proxy IN service file PC
#
function create_proxy_in_service_file_pc()  {
echo "# proxy-in-$NODE.service.pc " > $CREATE_PATH/proxy-in-$NODE.service.pc
echo "[Unit]" >> $CREATE_PATH/proxy-in-$NODE.service.pc
echo "Description=udpproxy in from 10.0.0.8$NODE" >> $CREATE_PATH/proxy-in-$NODE.service.pc
echo "PartOf=ptt.service" >> $CREATE_PATH/proxy-in-$NODE.service.pc
echo "After=sys-devices-virtual-net-wg0.device" >> $CREATE_PATH/proxy-in-$NODE.service.pc
echo " " >> $CREATE_PATH/proxy-in-$NODE.service.pc
echo "[Service]" >> $CREATE_PATH/proxy-in-$NODE.service.pc
echo "WorkingDirectory=/opt/boot" >> $CREATE_PATH/proxy-in-$NODE.service.pc
echo "ExecStart=/usr/local/bin/udpproxy -i proxy-in-$NODE.ini" >> $CREATE_PATH/proxy-in-$NODE.service.pc
echo "Type=simple" >> $CREATE_PATH/proxy-in-$NODE.service.pc
echo "Restart=always" >> $CREATE_PATH/proxy-in-$NODE.service.pc
echo "RestartSec=5" >> $CREATE_PATH/proxy-in-$NODE.service.pc
echo " " >> $CREATE_PATH/proxy-in-$NODE.service.pc
echo "[Install]" >> $CREATE_PATH/proxy-in-$NODE.service.pc
echo "WantedBy=ptt.service.pc" >> $CREATE_PATH/proxy-in-$NODE.service.pc
}

#
# Proxy OUT service file PC
#
function create_proxy_out_service_file_pc()  {
echo "[Unit]" > $CREATE_PATH/proxy-out-$NODE.service.pc
echo "Description=udpproxy to 10.0.0.8$NODE" >> $CREATE_PATH/proxy-out-$NODE.service.pc
echo "PartOf=ptt.service" >> $CREATE_PATH/proxy-out-$NODE.service.pc
echo "After=sys-devices-virtual-net-wg0.device ptt.service" >> $CREATE_PATH/proxy-out-$NODE.service.pc
echo " " >> $CREATE_PATH/proxy-out-$NODE.service.pc
echo "[Service]" >> $CREATE_PATH/proxy-out-$NODE.service.pc
echo "WorkingDirectory=/opt/boot" >> $CREATE_PATH/proxy-out-$NODE.service.pc
echo "ExecStart=/usr/local/bin/udpproxy -i proxy-out-$NODE.ini" >> $CREATE_PATH/proxy-out-$NODE.service.pc
echo "Type=simple" >> $CREATE_PATH/proxy-out-$NODE.service.pc
echo "Restart=always" >> $CREATE_PATH/proxy-out-$NODE.service.pc
echo "RestartSec=5" >> $CREATE_PATH/proxy-out-$NODE.service.pc
}

#
# Proxy IN ini file (RX) 
#
function create_proxy_in_ini_file() {
ADDRESS_DIGIT=$NODE
INCOMING_ADDRESS=$CREATE_PATH
echo "# RX proxy from $INCOMING_ADDRESS:600$NODE to 127.0.0.1:2010 " > $CREATE_PATH/proxy-in-$NODE.ini
echo "[proxy]" >> $CREATE_PATH/proxy-in-$NODE.ini
echo "incoming_address=$INCOMING_ADDRESS" >> $CREATE_PATH/proxy-in-$NODE.ini
echo "incoming_port=600$NODE" >> $CREATE_PATH/proxy-in-$NODE.ini
echo "outgoing_address=127.0.0.1" >> $CREATE_PATH/proxy-in-$NODE.ini
echo "outgoing_port=2010" >> $CREATE_PATH/proxy-in-$NODE.ini
echo "outbound_key=/dev/null" >> $CREATE_PATH/proxy-in-$NODE.ini
echo "inbound_key=/opt/boot/in-$NODE.key" >> $CREATE_PATH/proxy-in-$NODE.ini
echo "outbound_counter_file=/dev/null" >> $CREATE_PATH/proxy-in-$NODE.ini
echo "inbound_counter_file=/opt/boot/in-$NODE.count" >> $CREATE_PATH/proxy-in-$NODE.ini
}

#
# Proxy OUT ini file (TX) 
#
function create_proxy_out_ini_file() {
ADDRESS_DIGIT=$NODE
OUTGOING_ADDRESS=10.0.0.8$ADDRESS_DIGIT
OUTGOING_PORT="600$LOOP"
echo "# TX proxy from 127.0.0.1:600$NODE to $OUTGOING_ADDRESS:6000" > $CREATE_PATH/proxy-out-$NODE.ini
echo "[proxy]" >> $CREATE_PATH/proxy-out-$NODE.ini
echo "incoming_address=127.0.0.1" >> $CREATE_PATH/proxy-out-$NODE.ini
echo "incoming_port=600$NODE" >> $CREATE_PATH/proxy-out-$NODE.ini
echo "outgoing_address=$OUTGOING_ADDRESS" >> $CREATE_PATH/proxy-out-$NODE.ini
echo "outgoing_port=$OUTGOING_PORT" >> $CREATE_PATH/proxy-out-$NODE.ini
echo "outbound_key=/opt/boot/out-$NODE.key" >> $CREATE_PATH/proxy-out-$NODE.ini
echo "inbound_key=/dev/null" >> $CREATE_PATH/proxy-out-$NODE.ini
echo "outbound_counter_file=/opt/boot/out-$NODE.count" >> $CREATE_PATH/proxy-out-$NODE.ini
echo "inbound_counter_file=/dev/null" >> $CREATE_PATH/proxy-out-$NODE.ini
}

#
# Create bootstrap.sh 
#
function create_bootstrap_file() {
echo "#!/bin/sh" > $CREATE_PATH/bootstrap.sh
echo "/bin/blinkstick-cli --color 0 0 200" >> $CREATE_PATH/bootstrap.sh
echo "cp /opt/boot/wg0.* /etc/systemd/network/" >> $CREATE_PATH/bootstrap.sh
echo " " >> $CREATE_PATH/bootstrap.sh
echo "mkdir /opt/wgcap/" >> $CREATE_PATH/bootstrap.sh
echo "cp /opt/boot/wgcap_service.conf /opt/wgcap" >> $CREATE_PATH/bootstrap.sh
echo "cp /opt/boot/rtptun.service /etc/systemd/system/" >> $CREATE_PATH/bootstrap.sh
echo "cp /opt/boot/udp2raw.service /etc/systemd/system/" >> $CREATE_PATH/bootstrap.sh
echo "cp /opt/boot/proxy*service /etc/systemd/system/" >> $CREATE_PATH/bootstrap.sh
echo "cp /opt/boot/asound.conf /etc/" >> $CREATE_PATH/bootstrap.sh
echo "cp /opt/boot/pttcomm.service /etc/systemd/system/" >> $CREATE_PATH/bootstrap.sh
echo "cp /opt/boot/samplicator.service /etc/systemd/system/" >> $CREATE_PATH/bootstrap.sh
echo "cp /opt/boot/netmon.service /etc/systemd/system/" >> $CREATE_PATH/bootstrap.sh
echo "cp /opt/boot/netmon-tx.service /etc/systemd/system/" >> $CREATE_PATH/bootstrap.sh
echo " " >> $CREATE_PATH/bootstrap.sh
echo "systemctl daemon-reload" >> $CREATE_PATH/bootstrap.sh
# sleep 5
# iwctl --passphrase [PASSWORD] station wlan0 connect [SSID]
# sleep 15
echo "systemctl restart udp2raw" >> $CREATE_PATH/bootstrap.sh
echo "systemctl restart systemd-networkd" >> $CREATE_PATH/bootstrap.sh
echo "systemctl restart proxy-out-*.service" >> $CREATE_PATH/bootstrap.sh
echo "systemctl restart proxy-in-*.service " >> $CREATE_PATH/bootstrap.sh  
echo "systemctl restart pttcomm" >> $CREATE_PATH/bootstrap.sh
echo "systemctl restart samplicator.service" >> $CREATE_PATH/bootstrap.sh
echo "systemctl restart netmon" >> $CREATE_PATH/bootstrap.sh
echo "systemctl restart netmon-tx" >> $CREATE_PATH/bootstrap.sh
echo "# Comment this out if not using Raspberry Pi Codec Zero:" >> $CREATE_PATH/bootstrap.sh
echo "/sbin/alsactl restore -f /opt/boot/Codec_Zero_OnboardMIC_record_and_SPK_playback.state" >> $CREATE_PATH/bootstrap.sh
echo "sleep 1" >> $CREATE_PATH/bootstrap.sh
echo "aplay /opt/boot/notify.wav" >> $CREATE_PATH/bootstrap.sh
echo "/bin/blinkstick-cli --color 0 0 0" >> $CREATE_PATH/bootstrap.sh
echo "exit 0" >> $CREATE_PATH/bootstrap.sh
chmod +x $CREATE_PATH/bootstrap.sh
}

#
# PC bootstrap
#
function create_bootstrap_file_pc {
echo "#!/bin/bash" > $CREATE_PATH/bootstrap-pc.sh
echo "#" >> $CREATE_PATH/bootstrap-pc.sh
echo "# Bootstrap my x220 just to speed up dev" >> $CREATE_PATH/bootstrap-pc.sh
echo "#" >> $CREATE_PATH/bootstrap-pc.sh
echo " " >> $CREATE_PATH/bootstrap-pc.sh
echo "if [ \"\$EUID\" -ne 0 ]" >> $CREATE_PATH/bootstrap-pc.sh
echo "  then echo \"Please run with sudo. Exiting.\" " >> $CREATE_PATH/bootstrap-pc.sh
echo "  exit" >> $CREATE_PATH/bootstrap-pc.sh
echo "fi" >> $CREATE_PATH/bootstrap-pc.sh
echo " " >> $CREATE_PATH/bootstrap-pc.sh
echo "for file in *.service.pc;" >> $CREATE_PATH/bootstrap-pc.sh
echo "do" >> $CREATE_PATH/bootstrap-pc.sh
echo "# Drop .pc and move service files in place" >> $CREATE_PATH/bootstrap-pc.sh
echo "TARGET_FILE=`echo \"/etc/systemd/system/${file}\" | cut -d"." -f1-2`" >> $CREATE_PATH/bootstrap-pc.sh
echo "sudo cp \$file \$TARGET_FILE" >> $CREATE_PATH/bootstrap-pc.sh
echo "done" >> $CREATE_PATH/bootstrap-pc.sh
echo " " >> $CREATE_PATH/bootstrap-pc.sh
echo "cp /opt/boot/pttkey.ini.pc /opt/boot/pttkey.ini " >> $CREATE_PATH/bootstrap-pc.sh
echo " " >> $CREATE_PATH/bootstrap-pc.sh
echo "# Copy WG" >> $CREATE_PATH/bootstrap-pc.sh
echo "sudo cp wg0.net* /etc/systemd/network/" >> $CREATE_PATH/bootstrap-pc.sh
echo " " >> $CREATE_PATH/bootstrap-pc.sh
echo "sudo systemctl daemon-reload" >> $CREATE_PATH/bootstrap-pc.sh
echo "sudo systemctl restart systemd-networkd" >> $CREATE_PATH/bootstrap-pc.sh
}

#
# pttkey.ini 
#
function create_pttkey_ini_file {
echo "[pttkey]" > $CREATE_PATH/pttkey.ini
echo "keyboard_device=/dev/input/by-path/platform-ptt_keys-event" >> $CREATE_PATH/pttkey.ini
echo "ptt_down_command=/opt/pttkey/audio-on.sh" >> $CREATE_PATH/pttkey.ini
echo "ptt_up_command=/opt/pttkey/audio-off.sh" >> $CREATE_PATH/pttkey.ini
echo "# audio" >> $CREATE_PATH/pttkey.ini
echo "audiosource=alsasrc" >> $CREATE_PATH/pttkey.ini
echo "audiosink=alsasink" >> $CREATE_PATH/pttkey.ini
echo "# opus" >> $CREATE_PATH/pttkey.ini
echo "dtx_active=0" >> $CREATE_PATH/pttkey.ini
echo "# RX" >> $CREATE_PATH/pttkey.ini
echo "rxport_1=2010" >> $CREATE_PATH/pttkey.ini
echo "rxport_2=2011" >> $CREATE_PATH/pttkey.ini
echo "rxport_3=2012" >> $CREATE_PATH/pttkey.ini
echo "rxport_4=2013" >> $CREATE_PATH/pttkey.ini
echo "rxaddress=127.0.0.1" >> $CREATE_PATH/pttkey.ini
echo "rx_timeout_ns=500000000" >> $CREATE_PATH/pttkey.ini
echo "multicastmode=0" >> $CREATE_PATH/pttkey.ini
echo "# TX: ptt stream destinations" >> $CREATE_PATH/pttkey.ini
echo "destination_ip_1 = 127.0.0.1" >> $CREATE_PATH/pttkey.ini
echo "destination_ip_2 = 127.0.0.1" >> $CREATE_PATH/pttkey.ini
echo "destination_ip_3 = 127.0.0.1" >> $CREATE_PATH/pttkey.ini
echo "destination_ip_4 = 127.0.0.1" >> $CREATE_PATH/pttkey.ini
echo "# Ports 2,3,4 are not used in our use case" >> $CREATE_PATH/pttkey.ini
echo "destination_port_1=2000" >> $CREATE_PATH/pttkey.ini
echo "destination_port_2=2001" >> $CREATE_PATH/pttkey.ini
echo "destination_port_3=2002" >> $CREATE_PATH/pttkey.ini
echo "destination_port_4=2003" >> $CREATE_PATH/pttkey.ini
echo "# Scan codes for four PTT keys on keyboard" >> $CREATE_PATH/pttkey.ini
echo "# First PTT key " >> $CREATE_PATH/pttkey.ini
echo "# * For GPIO button, use ptt_down_code_0 = 108 " >> $CREATE_PATH/pttkey.ini
echo "# * For Codec zero button button, use ptt_down_code_0 = 28 " >> $CREATE_PATH/pttkey.ini
echo "ptt_down_type_0 = 1 " >> $CREATE_PATH/pttkey.ini
echo "ptt_down_code_0 = 28 " >> $CREATE_PATH/pttkey.ini
echo "ptt_down_value_0 = 1" >> $CREATE_PATH/pttkey.ini
echo "ptt_up_type_0 = 1 " >> $CREATE_PATH/pttkey.ini
echo "ptt_up_code_0 = 28 " >> $CREATE_PATH/pttkey.ini
echo "ptt_up_value_0 = 0" >> $CREATE_PATH/pttkey.ini
echo "# Second PTT key (TODO)" >> $CREATE_PATH/pttkey.ini
echo "ptt_down_type_1 = 1 " >> $CREATE_PATH/pttkey.ini
echo "ptt_down_code_1 = 2 " >> $CREATE_PATH/pttkey.ini
echo "ptt_down_value_1 = 0 " >> $CREATE_PATH/pttkey.ini
echo "ptt_up_type_1 = 1 " >> $CREATE_PATH/pttkey.ini
echo "ptt_up_code_1 = 3 " >> $CREATE_PATH/pttkey.ini
echo "ptt_up_value_1 = 1 " >> $CREATE_PATH/pttkey.ini
echo "# Third PTT key (TODO)" >> $CREATE_PATH/pttkey.ini
echo "ptt_down_type_2 = 1 " >> $CREATE_PATH/pttkey.ini
echo "ptt_down_code_2 = 3 " >> $CREATE_PATH/pttkey.ini
echo "ptt_down_value_2 = 0 " >> $CREATE_PATH/pttkey.ini
echo "ptt_up_type_2 = 1 " >> $CREATE_PATH/pttkey.ini
echo "ptt_up_code_2 = 4 " >> $CREATE_PATH/pttkey.ini
echo "ptt_up_value_2 = 1 " >> $CREATE_PATH/pttkey.ini
echo "# Fourth PTT key (TODO)" >> $CREATE_PATH/pttkey.ini
echo "ptt_down_type_3 = 1 " >> $CREATE_PATH/pttkey.ini
echo "ptt_down_code_3 = 4 " >> $CREATE_PATH/pttkey.ini
echo "ptt_down_value_3 = 0 " >> $CREATE_PATH/pttkey.ini
echo "ptt_up_type_3 = 1 " >> $CREATE_PATH/pttkey.ini
echo "ptt_up_code_3 = 5 " >> $CREATE_PATH/pttkey.ini
echo "ptt_up_value_3 = 1 " >> $CREATE_PATH/pttkey.ini    
}

#
# PC version
#
function create_pttkey_ini_file_pc {
echo "[pttkey]" > $CREATE_PATH/pttkey.ini.pc
echo "keyboard_device=/dev/input/event0" >> $CREATE_PATH/pttkey.ini.pc
echo "ptt_down_command=/opt/pttkey/audio-on.sh" >> $CREATE_PATH/pttkey.ini.pc
echo "ptt_up_command=/opt/pttkey/audio-off.sh" >> $CREATE_PATH/pttkey.ini.pc
echo "# audio" >> $CREATE_PATH/pttkey.ini.pc
echo "audiosource=pulsesrc" >> $CREATE_PATH/pttkey.ini.pc
echo "audiosink=pulsesink" >> $CREATE_PATH/pttkey.ini.pc
echo "# opus" >> $CREATE_PATH/pttkey.ini.pc
echo "dtx_active=0" >> $CREATE_PATH/pttkey.ini.pc
echo "# RX" >> $CREATE_PATH/pttkey.ini.pc
echo "rxport_1=2010" >> $CREATE_PATH/pttkey.ini.pc
echo "rxport_2=2011" >> $CREATE_PATH/pttkey.ini.pc
echo "rxport_3=2012" >> $CREATE_PATH/pttkey.ini.pc
echo "rxport_4=2013" >> $CREATE_PATH/pttkey.ini.pc
echo "rxaddress=127.0.0.1" >> $CREATE_PATH/pttkey.ini.pc
echo "rx_timeout_ns=500000000" >> $CREATE_PATH/pttkey.ini.pc
echo "multicastmode=0" >> $CREATE_PATH/pttkey.ini.pc
echo "# TX: ptt stream destinations" >> $CREATE_PATH/pttkey.ini.pc
echo "destination_ip_1 = 127.0.0.1" >> $CREATE_PATH/pttkey.ini.pc
echo "destination_ip_2 = 127.0.0.1" >> $CREATE_PATH/pttkey.ini.pc
echo "destination_ip_3 = 127.0.0.1" >> $CREATE_PATH/pttkey.ini.pc
echo "destination_ip_4 = 127.0.0.1" >> $CREATE_PATH/pttkey.ini.pc
echo "# Ports 2,3,4 are not used in our use case" >> $CREATE_PATH/pttkey.ini.pc
echo "destination_port_1=2000" >> $CREATE_PATH/pttkey.ini.pc
echo "destination_port_2=2001" >> $CREATE_PATH/pttkey.ini.pc
echo "destination_port_3=2002" >> $CREATE_PATH/pttkey.ini.pc
echo "destination_port_4=2003" >> $CREATE_PATH/pttkey.ini.pc
echo "# Scan codes for four PTT keys on keyboard" >> $CREATE_PATH/pttkey.ini.pc
echo "# First PTT key " >> $CREATE_PATH/pttkey.ini.pc
echo "# * For GPIO button, use ptt_down_code_0 = 108 " >> $CREATE_PATH/pttkey.ini.pc
echo "# * For Codec zero button button, use ptt_down_code_0 = 28 " >> $CREATE_PATH/pttkey.ini.pc
echo "ptt_down_type_0 = 1 " >> $CREATE_PATH/pttkey.ini.pc
echo "ptt_down_code_0 = 60 " >> $CREATE_PATH/pttkey.ini.pc
echo "ptt_down_value_0 = 1" >> $CREATE_PATH/pttkey.ini.pc
echo "ptt_up_type_0 = 1 " >> $CREATE_PATH/pttkey.ini.pc
echo "ptt_up_code_0 = 60 " >> $CREATE_PATH/pttkey.ini.pc
echo "ptt_up_value_0 = 0" >> $CREATE_PATH/pttkey.ini.pc
echo "# Second PTT key (TODO)" >> $CREATE_PATH/pttkey.ini.pc
echo "ptt_down_type_1 = 1 " >> $CREATE_PATH/pttkey.ini.pc
echo "ptt_down_code_1 = 2 " >> $CREATE_PATH/pttkey.ini.pc
echo "ptt_down_value_1 = 0 " >> $CREATE_PATH/pttkey.ini.pc
echo "ptt_up_type_1 = 1 " >> $CREATE_PATH/pttkey.ini.pc
echo "ptt_up_code_1 = 3 " >> $CREATE_PATH/pttkey.ini.pc
echo "ptt_up_value_1 = 1 " >> $CREATE_PATH/pttkey.ini.pc
echo "# Third PTT key (TODO)" >> $CREATE_PATH/pttkey.ini.pc
echo "ptt_down_type_2 = 1 " >> $CREATE_PATH/pttkey.ini.pc
echo "ptt_down_code_2 = 3 " >> $CREATE_PATH/pttkey.ini.pc
echo "ptt_down_value_2 = 0 " >> $CREATE_PATH/pttkey.ini.pc
echo "ptt_up_type_2 = 1 " >> $CREATE_PATH/pttkey.ini.pc
echo "ptt_up_code_2 = 4 " >> $CREATE_PATH/pttkey.ini.pc
echo "ptt_up_value_2 = 1 " >> $CREATE_PATH/pttkey.ini.pc
echo "# Fourth PTT key (TODO)" >> $CREATE_PATH/pttkey.ini.pc
echo "ptt_down_type_3 = 1 " >> $CREATE_PATH/pttkey.ini.pc
echo "ptt_down_code_3 = 4 " >> $CREATE_PATH/pttkey.ini.pc
echo "ptt_down_value_3 = 0 " >> $CREATE_PATH/pttkey.ini.pc
echo "ptt_up_type_3 = 1 " >> $CREATE_PATH/pttkey.ini.pc
echo "ptt_up_code_3 = 5 " >> $CREATE_PATH/pttkey.ini.pc
echo "ptt_up_value_3 = 1 " >> $CREATE_PATH/pttkey.ini.pc    
}

#
# samplicator
#
function create_samplicator_targets {
echo -n "127.0.0.1/600$NODE " >> $CREATE_PATH/targets.txt
}

function create_samplicator_conf {
    echo -n "127.0.0.1/255.255.255.255: " > $CREATE_PATH/samplicator.conf
    cat $CREATE_PATH/targets.txt >> $CREATE_PATH/samplicator.conf
}

function create_samplicator_service {
echo "[Unit]" > $CREATE_PATH/samplicator.service
echo "Description=Samplicator" >> $CREATE_PATH/samplicator.service
echo "After=network.target" >> $CREATE_PATH/samplicator.service
echo " " >> $CREATE_PATH/samplicator.service
echo "[Service]" >> $CREATE_PATH/samplicator.service
echo "Type=forking" >> $CREATE_PATH/samplicator.service
echo "Restart=always" >> $CREATE_PATH/samplicator.service
echo "RestartSec=10" >> $CREATE_PATH/samplicator.service
echo "TimeoutStartSec=5" >> $CREATE_PATH/samplicator.service
echo "ExecStart=/bin/samplicate -c /opt/boot/samplicator.conf -d 0 -f" >> $CREATE_PATH/samplicator.service
}

#
# PC samplicator
#
function create_samplicator_service_pc {
echo "[Unit]" > $CREATE_PATH/samplicator.service.pc
echo "Description=Samplicator" >> $CREATE_PATH/samplicator.service.pc
echo "PartOf=ptt.service" >> $CREATE_PATH/samplicator.service.pc
echo "After=network.target ptt.service" >> $CREATE_PATH/samplicator.service.pc
echo " " >> $CREATE_PATH/samplicator.service.pc
echo "[Service]" >> $CREATE_PATH/samplicator.service.pc
echo "Type=forking" >> $CREATE_PATH/samplicator.service.pc
echo "Restart=always" >> $CREATE_PATH/samplicator.service.pc
echo "RestartSec=10" >> $CREATE_PATH/samplicator.service.pc
echo "TimeoutStartSec=5" >> $CREATE_PATH/samplicator.service.pc
echo "ExecStart=/usr/local/bin/samplicate -c /opt/boot/samplicator.conf -d 0 -f" >> $CREATE_PATH/samplicator.service.pc
echo " " >> $CREATE_PATH/samplicator.service.pc
echo "[Install]" >> $CREATE_PATH/samplicator.service.pc
echo "WantedBy=ptt.service" >> $CREATE_PATH/samplicator.service.pc
}

#
# pttcomm service
#
function create_pttcomm_service {
echo "# $CREATE_PATH/pttcomm.service " > $CREATE_PATH/pttcomm.service
echo "[Unit]" >> $CREATE_PATH/pttcomm.service
echo "Description=pttcomm service" >> $CREATE_PATH/pttcomm.service
echo "After=sys-devices-virtual-net-wg0.device" >> $CREATE_PATH/pttcomm.service
echo " " >> $CREATE_PATH/pttcomm.service
echo "[Service]" >> $CREATE_PATH/pttcomm.service
echo "WorkingDirectory=/opt/boot" >> $CREATE_PATH/pttcomm.service
echo "ExecStart=/usr/bin/pttcomm -l" >> $CREATE_PATH/pttcomm.service
echo "Type=simple" >> $CREATE_PATH/pttcomm.service
echo "Restart=always" >> $CREATE_PATH/pttcomm.service
echo "RestartSec=5" >> $CREATE_PATH/pttcomm.service
}

#
# PC pttcomm service
#
function create_pttcomm_service_pc {
echo "# $CREATE_PATH/pttcomm.service.pc " > $CREATE_PATH/pttcomm.service.pc
echo "[Unit]" >> $CREATE_PATH/pttcomm.service.pc
echo "Description=pttcomm service" >> $CREATE_PATH/pttcomm.service.pc
echo "PartOf=ptt.service" >> $CREATE_PATH/pttcomm.service.pc
echo "After=sys-devices-virtual-net-wg0.device ptt.service" >> $CREATE_PATH/pttcomm.service.pc
echo " " >> $CREATE_PATH/pttcomm.service.pc
echo "[Service]" >> $CREATE_PATH/pttcomm.service.pc
echo "User=tech" >> $CREATE_PATH/pttcomm.service.pc
echo "Environment=\"XDG_RUNTIME_DIR=/run/user/1000\"" >> $CREATE_PATH/pttcomm.service.pc
echo "Environment=\"PULSE_RUNTIME_PATH=/run/user/1000/pulse/\"" >> $CREATE_PATH/pttcomm.service.pc
echo "WorkingDirectory=/opt/boot" >> $CREATE_PATH/pttcomm.service.pc
echo "ExecStart=/usr/local/bin/pttcomm -l" >> $CREATE_PATH/pttcomm.service.pc
echo "Type=simple" >> $CREATE_PATH/pttcomm.service.pc
echo "Restart=always" >> $CREATE_PATH/pttcomm.service.pc
echo "RestartSec=5" >> $CREATE_PATH/pttcomm.service.pc
echo " " >> $CREATE_PATH/pttcomm.service.pc
echo "[Install]" >> $CREATE_PATH/pttcomm.service.pc
echo "WantedBy=ptt.service" >> $CREATE_PATH/pttcomm.service.pc
}

#
# ptt.service is only used on PC
#
function create_ptt_service_pc {
echo "[Unit]" > $CREATE_PATH/ptt.service.pc
echo "Description=push-to-talk" >> $CREATE_PATH/ptt.service.pc
echo " " >> $CREATE_PATH/ptt.service.pc
echo "[Service]" >> $CREATE_PATH/ptt.service.pc
echo "# The dummy program will exit" >> $CREATE_PATH/ptt.service.pc
echo "Type=oneshot" >> $CREATE_PATH/ptt.service.pc
echo "# Execute a dummy program" >> $CREATE_PATH/ptt.service.pc
echo "ExecStart=/bin/true" >> $CREATE_PATH/ptt.service.pc
echo "# This service shall be considered active after start" >> $CREATE_PATH/ptt.service.pc
echo "RemainAfterExit=yes" >> $CREATE_PATH/ptt.service.pc
echo " " >> $CREATE_PATH/ptt.service.pc
echo "[Install]" >> $CREATE_PATH/ptt.service.pc
echo "# Components of this application should be started at boot time" >> $CREATE_PATH/ptt.service.pc
echo "WantedBy=multi-user.target" >> $CREATE_PATH/ptt.service.pc
}

#
# asound.conf
#
function create_asound_conf_file {
echo "pcm.!default {" > $CREATE_PATH/asound.conf
echo " type asym" >> $CREATE_PATH/asound.conf
echo " playback.pcm \"dmixer\"" >> $CREATE_PATH/asound.conf
echo " capture.pcm { " >> $CREATE_PATH/asound.conf
echo " type plug" >> $CREATE_PATH/asound.conf
echo "   slave.pcm \"hw:0,0\"" >> $CREATE_PATH/asound.conf
echo "  }" >> $CREATE_PATH/asound.conf
echo "}" >> $CREATE_PATH/asound.conf
echo "pcm.dmixer  {" >> $CREATE_PATH/asound.conf
echo "        type dmix" >> $CREATE_PATH/asound.conf
echo "        ipc_key 1024" >> $CREATE_PATH/asound.conf
echo "        slave {" >> $CREATE_PATH/asound.conf
echo "          pcm \"hw:0,0\" " >> $CREATE_PATH/asound.conf
echo "          period_time 0" >> $CREATE_PATH/asound.conf
echo "              period_size 1024" >> $CREATE_PATH/asound.conf
echo "          buffer_size 4096" >> $CREATE_PATH/asound.conf
echo "          # rate 44100" >> $CREATE_PATH/asound.conf
echo "        }" >> $CREATE_PATH/asound.conf
echo "        bindings {" >> $CREATE_PATH/asound.conf
echo "          0 0" >> $CREATE_PATH/asound.conf
echo "          1 1" >> $CREATE_PATH/asound.conf
echo "        }" >> $CREATE_PATH/asound.conf
echo "}" >> $CREATE_PATH/asound.conf
echo "ctl.dmixer {" >> $CREATE_PATH/asound.conf
echo "       type hw" >> $CREATE_PATH/asound.conf
echo "       card 0" >> $CREATE_PATH/asound.conf
echo "}" >> $CREATE_PATH/asound.conf
}

#
# netmon.ini for RX indication
#
function create_netmon_rx_ini {
echo "[netmon]" > $CREATE_PATH/netmon.ini
echo "network_device=lo" >> $CREATE_PATH/netmon.ini
echo "capturefilter=\"port 2010 or port 2011 or port 2012\"" >> $CREATE_PATH/netmon.ini # TODO
echo "rx_start_command=/opt/boot/rx-on.sh" >> $CREATE_PATH/netmon.ini
echo "rx_end_command=/opt/boot/rx-off.sh" >> $CREATE_PATH/netmon.ini
echo "trigger_port=2010" >> $CREATE_PATH/netmon.ini
}

#
# netmon indication scripts for blinkstick (or thinklight) on RX
#
function create_rx_shell_sciprts {
echo "#!/bin/sh" > $CREATE_PATH/rx-on.sh
echo "blinkstick-cli --color 200 0 0" >> $CREATE_PATH/rx-on.sh
echo "# echo 1 > /sys/class/leds/tpacpi::thinklight/brightness" >> $CREATE_PATH/rx-on.sh
echo "exit 0" >> $CREATE_PATH/rx-on.sh
echo "#!/bin/sh" > $CREATE_PATH/rx-off.sh
echo "blinkstick-cli --color 0 0 0" >> $CREATE_PATH/rx-off.sh
echo "# echo 0 > /sys/class/leds/tpacpi::thinklight/brightness" >> $CREATE_PATH/rx-off.sh
echo "exit 0" >> $CREATE_PATH/rx-off.sh
}

#
# netmon.ini for TX indication
#
function create_netmon_tx_ini {
echo "[netmon]" > $CREATE_PATH/netmon-tx.ini
echo "network_device=lo" >> $CREATE_PATH/netmon-tx.ini
echo "capturefilter=\"port 2000\"" >> $CREATE_PATH/netmon-tx.ini # TODO
echo "rx_start_command=/opt/boot/tx-on.sh" >> $CREATE_PATH/netmon-tx.ini
echo "rx_end_command=/opt/boot/tx-off.sh" >> $CREATE_PATH/netmon-tx.ini
echo "trigger_port=2010" >> $CREATE_PATH/netmon-tx.ini
}

#
# netmon indication scripts for blinkstick (or thinklight) on TX
#
function create_tx_shell_sciprts {
echo "#!/bin/sh" > $CREATE_PATH/tx-on.sh
echo "blinkstick-cli --color 0 200 0 --index 1" >> $CREATE_PATH/tx-on.sh
echo "# echo 1 > /sys/class/leds/tpacpi::thinklight/brightness" >> $CREATE_PATH/tx-on.sh
echo "exit 0" >> $CREATE_PATH/tx-on.sh
echo "#!/bin/sh" > $CREATE_PATH/tx-off.sh
echo "blinkstick-cli --color 0 0 0 --index 1" >> $CREATE_PATH/tx-off.sh
echo "# echo 0 > /sys/class/leds/tpacpi::thinklight/brightness" >> $CREATE_PATH/tx-off.sh
echo "exit 0" >> $CREATE_PATH/tx-off.sh
}

#
# netmon service for RX
#
function create_netmon_rx_service_file {
echo "# $CREATE_PATH/netmon.service " > $CREATE_PATH/netmon.service
echo "[Unit]" >> $CREATE_PATH/netmon.service
echo "Description=netmon service" >> $CREATE_PATH/netmon.service
echo "After=sys-devices-virtual-net-wg0.device" >> $CREATE_PATH/netmon.service
echo " " >> $CREATE_PATH/netmon.service
echo "[Service]" >> $CREATE_PATH/netmon.service
echo "WorkingDirectory=/opt/boot" >> $CREATE_PATH/netmon.service
echo "ExecStart=/bin/netmon -i netmon.ini" >> $CREATE_PATH/netmon.service
echo "Type=simple" >> $CREATE_PATH/netmon.service
echo "Restart=always" >> $CREATE_PATH/netmon.service
echo "RestartSec=5" >> $CREATE_PATH/netmon.service
}

#
# PC netmon service for RX
#
function create_netmon_rx_service_file_pc {
echo "# $CREATE_PATH/netmon.service.pc " > $CREATE_PATH/netmon.service.pc
echo "[Unit]" >> $CREATE_PATH/netmon.service.pc
echo "Description=netmon service" >> $CREATE_PATH/netmon.service.pc
echo "After=sys-devices-virtual-net-wg0.device" >> $CREATE_PATH/netmon.service.pc
echo " " >> $CREATE_PATH/netmon.service.pc
echo "[Service]" >> $CREATE_PATH/netmon.service.pc
echo "WorkingDirectory=/opt/boot" >> $CREATE_PATH/netmon.service.pc
echo "ExecStart=/usr/local/bin/netmon -i netmon.ini" >> $CREATE_PATH/netmon.service.pc
echo "Type=simple" >> $CREATE_PATH/netmon.service.pc
echo "Restart=always" >> $CREATE_PATH/netmon.service.pc
echo "RestartSec=5" >> $CREATE_PATH/netmon.service.pc
}

#
# netmon service for TX
#
function create_netmon_tx_service_file {
echo "# $CREATE_PATH/netmon-tx.service " > $CREATE_PATH/netmon-tx.service
echo "[Unit]" >> $CREATE_PATH/netmon-tx.service
echo "Description=netmon tx service" >> $CREATE_PATH/netmon-tx.service
echo "After=sys-devices-virtual-net-wg0.device" >> $CREATE_PATH/netmon-tx.service
echo " " >> $CREATE_PATH/netmon-tx.service
echo "[Service]" >> $CREATE_PATH/netmon-tx.service
echo "WorkingDirectory=/opt/boot" >> $CREATE_PATH/netmon-tx.service
echo "ExecStart=/bin/netmon -i netmon-tx.ini" >> $CREATE_PATH/netmon-tx.service
echo "Type=simple" >> $CREATE_PATH/netmon-tx.service
echo "Restart=always" >> $CREATE_PATH/netmon-tx.service
echo "RestartSec=5" >> $CREATE_PATH/netmon-tx.service
}

#
# PC netmon service for TX
#
function create_netmon_tx_service_file_pc {
echo "# $CREATE_PATH/netmon-tx.service.pc " > $CREATE_PATH/netmon-tx.service.pc
echo "[Unit]" >> $CREATE_PATH/netmon-tx.service.pc
echo "Description=netmon tx service" >> $CREATE_PATH/netmon-tx.service.pc
echo "After=sys-devices-virtual-net-wg0.device" >> $CREATE_PATH/netmon-tx.service.pc
echo " " >> $CREATE_PATH/netmon-tx.service.pc
echo "[Service]" >> $CREATE_PATH/netmon-tx.service.pc
echo "WorkingDirectory=/opt/boot" >> $CREATE_PATH/netmon-tx.service.pc
echo "ExecStart=/usr/local/bin/netmon -i netmon-tx.ini" >> $CREATE_PATH/netmon-tx.service.pc
echo "Type=simple" >> $CREATE_PATH/netmon-tx.service.pc
echo "Restart=always" >> $CREATE_PATH/netmon-tx.service.pc
echo "RestartSec=5" >> $CREATE_PATH/netmon-tx.service.pc
}

#
# Create out key file and counter for it
#
# NOTE: After everything works, adopt this to real TRNG source!
#
function create_evaluation_out_key_files {
dd if=/dev/urandom bs=1M count=10 of=$CREATE_PATH/out-$NODE.key >/dev/null 2>&1
echo 1 > $CREATE_PATH/out-$NODE.count
cp $CREATE_PATH/out-$NODE.key 10.0.0.8$NODE/in-$LOOP.key
echo 1 > 10.0.0.8$NODE/in-$LOOP.count
}

#
# Copy template files
#
function copy_templates_in_place {
    cp templates/* $CREATE_PATH/
}

#
# Erase @ start
#
for ERASE_LOOP in 0 1 2 3
do
 CREATE_PATH="10.0.0.8$ERASE_LOOP"
 # Create directory for entity files
 if [ ! -d $CREATE_PATH ]; then
  mkdir $CREATE_PATH
 else
  rm $CREATE_PATH/*
 fi
done

#
# Main loop
#
for LOOP in 0 1 2 3
do
 CREATE_PATH="10.0.0.8$LOOP"

 for INNER in 0 1 2 3
 do
    if [ "$LOOP" != "$INNER" ];
    then
        NODE=$INNER
        create_proxy_in_service_file
        create_proxy_in_service_file_pc
        create_proxy_out_service_file
        create_proxy_out_service_file_pc
        create_proxy_in_ini_file
        create_proxy_out_ini_file
        create_pttkey_ini_file
        create_pttkey_ini_file_pc
        create_samplicator_targets
        create_evaluation_out_key_files
    fi
 done
 create_bootstrap_file
 create_bootstrap_file_pc
 create_samplicator_conf
 create_samplicator_service
 create_samplicator_service_pc
 create_pttcomm_service
 create_pttcomm_service_pc
 create_asound_conf_file
 create_ptt_service_pc
 create_netmon_rx_ini
 create_rx_shell_sciprts
 create_netmon_tx_ini
 create_tx_shell_sciprts
 create_netmon_rx_service_file
 create_netmon_rx_service_file_pc
 create_netmon_tx_service_file
 create_netmon_tx_service_file_pc
 copy_templates_in_place
done

#
# Create connectivity files for node. 
#

if [ -f server_entry.txt ];
then
rm server_entry.txt
fi

#
# Source server connection primitives
#
# GEN_SERVER_ADDRESS=[IP]
# GEN_RTPTUN_KEY=[BASE64_ENCODED_KEY]
# GEN_UDP2RAW_PASSWORD=[TXT_STRING_PASSWORD]
# SERVER_PUBKEY=[SERVER_PUBKEY]
#
# /opt/wgcap/wgcap_service.conf
#
source initparams.txt

#
# Set here last digit of client address, NOTE: these has to match above!
#
for LOOP in 80 81 82 83
do

ENTRY=10.0.0.$LOOP

#
# Set unique wg0 ip address
#
PEER_IP_ADDRESS=$ENTRY

#
# Set unique port (50xx)
#
GEN_SERVER_PORT=50$LOOP

#
# NOTE: 127.0.0.1:3333 is tunnel destination
#
SERVER_ENDPOINT_ADDRESS="127.0.0.1:3333"

#
# Peer key, public key and PSK
#
PEER_KEY=`wg genkey`
PEER_PUBKEY=`echo $PEER_KEY | wg pubkey`
PEER_PSKKEY=`wg genpsk`

#
# Server entry
#
echo "#" >> server_entry.txt
echo "# Entry IP: $PEER_IP_ADDRESS rtptun port: $GEN_SERVER_PORT " >> server_entry.txt
echo "# " >> server_entry.txt
echo "[WireGuardPeer]" >> server_entry.txt
echo "PublicKey=${PEER_PUBKEY}" >> server_entry.txt
echo "PresharedKey=${PEER_PSKKEY}" >> server_entry.txt
echo "AllowedIPs=${PEER_IP_ADDRESS}/32" >> server_entry.txt
echo "PersistentKeepalive=25" >> server_entry.txt

#
# Peer files
#
echo "[NetDev]
Name=wg0
Kind=wireguard
Description=WireGuard tunnel wg0

[WireGuard]
ListenPort=51871
PrivateKey=$PEER_KEY

[WireGuardPeer]
PublicKey=$SERVER_PUBKEY
PresharedKey=$PEER_PSKKEY
AllowedIPs=10.0.0.0/24, 0.0.0.0/0
Endpoint=$SERVER_ENDPOINT_ADDRESS
PersistentKeepalive=30
" > $ENTRY/wg0.netdev

echo "[Match]
Name=wg0

[Link]
MTUBytes=1200

[Network]
Address=$PEER_IP_ADDRESS/24
" > $ENTRY/wg0.network


#
# wgcap_service.conf
#
echo "# /opt/wgcap/wgcap_service.conf
SERVER_IP=$GEN_SERVER_ADDRESS
SERVER_PORT=$GEN_SERVER_PORT
RTPTUN_KEY=$GEN_RTPTUN_KEY
UDP2RAW_PSK=\"$GEN_UDP2RAW_PASSWORD\"
WG_GATEWAY=10.0.0.1
" > $ENTRY/wgcap_service.conf

#
# systemd service files for client
#
echo "# /etc/systemd/system/rtptun.service
[Unit]
Description=rtptun for wireguard
Before=sys-devices-virtual-net-wg0.device
After=network.target auditd.service
Conflicts=udp2raw.service

[Service]
EnvironmentFile=/opt/wgcap/wgcap_service.conf
WorkingDirectory=/tmp
ExecStart=rtptun client -v -k \${RTPTUN_KEY} -l 3333 -d \${SERVER_IP} -p \${SERVER_PORT}
Type=simple
Restart=always
RestartSec=5" > $ENTRY/rtptun.service

echo "# /etc/systemd/system/udp2raw.service
[Unit]
Description=udp2raw for wireguard
Before=sys-devices-virtual-net-wg0.device
After=network.target
Conflicts=rtptun.service

[Service]
WorkingDirectory=/tmp
EnvironmentFile=/opt/wgcap/wgcap_service.conf
ExecStart=udp2raw -c -l0.0.0.0:3333 -r\${SERVER_IP}:5005 -k \${UDP2RAW_PSK} --raw-mode faketcp -a
Type=simple
Restart=always
RestartSec=5" > $ENTRY/udp2raw.service

#
# rtptun_[port].service for server
#

echo "# /etc/systemd/system/rtptun_$GEN_SERVER_PORT.service
[Unit]
Description=rtptun for $PEER_IP_ADDRESS port $GEN_SERVER_PORT
After=network.target

[Service]
User=tech
WorkingDirectory=/tmp
ExecStart=rtptun server -k \${RTPTUN_KEY} -l $GEN_SERVER_PORT -p 51871
Type=simple
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target" > $ENTRY/rtptun_$GEN_SERVER_PORT.service

done
exit

