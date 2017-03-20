# Install Wireshark
sudo add-apt-repository ppa:wireshark-dev/stable -y;
sudo apt-get update -y;
echo "wireshark-common wireshark-common/install-setuid select true" | sudo debconf-set-selections;
sudo apt-get install wireshark -y;
echo "Complete Wireshark Install.";

# Configure Wireshark
sudo groupadd wireshark;
sudo usermod -a -G wireshark ubuntu;
sudo usermod -a -G wireshark root;
sudo gpasswd -a ubuntu wireshark; 
sudo gpasswd -a root wireshark; 
sudo chgrp wireshark /usr/bin/dumpcap;
sudo chmod 775 /usr/bin/dumpcap;
sudo setcap cap_net_raw,cap_net_admin=eip /usr/bin/dumpcap;
sudo getcap /usr/bin/dumpcap;