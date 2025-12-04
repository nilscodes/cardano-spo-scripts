#!/bin/bash

#  __                      _ _                               _            _             
# / _\ ___  ___ _   _ _ __(_) |_ _   _    /\  /\__ _ _ __ __| | ___ _ __ (_)_ __   __ _ 
# \ \ / _ \/ __| | | | '__| | __| | | |  / /_/ / _` | '__/ _` |/ _ \ '_ \| | '_ \ / _` |
# _\ \  __/ (__| |_| | |  | | |_| |_| | / __  / (_| | | | (_| |  __/ | | | | | | | (_| |
# \__/\___|\___|\__,_|_|  |_|\__|\__, | \/ /_/ \__,_|_|  \__,_|\___|_| |_|_|_| |_|\__, |
#                                |___/                                            |___/ 

# Get the latest updates
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get autoremove -y
sudo apt-get autoclean -y

# Ensure Unattended upgrades is configured
sudo apt-get install unattended-upgrades -y
sudo dpkg-reconfigure -plow unattended-upgrades

# Install UFW
sudo apt-get install ufw

# Disable root user
sudo passwd -l root

echo "Please perform the manual steps:"
echo " - Change default SSH port to SSH_PORT other than 22"
echo " - Configure UFW (execute in this order)"
echo "   - Add '-A ufw-before-input -p icmp --icmp-type echo-request -j DROP' to /etc/ufw/before.rules to prevent ping"
echo "   - sudo ufw allow SSH_PORT"
echo "   - sudo ufw allow CARDANO_NODE_PORT"
echo "   - IF connecting from block producer for a mithril relay"
echo "   - sudo ufw allow from BP_IP to any port MITHRIL_PORT proto tcp"
echo "   - sudo ufw default allow outgoing"
echo "   - sudo ufw default deny incoming"
echo "   - sudo ufw enable"
