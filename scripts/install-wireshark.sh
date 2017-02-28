# Check if the script has executed 

if [ -f /home/vagrant/.wireshark ]
then
    echo "Wireshark already installed."
    exit 0
fi

touch /home/vagrant/.wireshark

# Install Wireshark
sudo apt-get install wireshark -y > /dev/null 2>&1

# COnfigure Wireshark
sudo groupadd wireshark
sudo usermod -a -G wireshark vagrant
sudo usermod -a -G wireshark root
sudo gpasswd -a vagrant wireshark
sudo gpasswd -a root wireshark
sudo chgrp wireshark /usr/bin/dumpcap
sudo chmod 750 /usr/bin/dumpcap
sudo setcap cap_net_raw,cap_net_admin=eip /usr/bin/dumpcap
sudo getcap /usr/bin/dumpcap

