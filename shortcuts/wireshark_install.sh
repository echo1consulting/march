################################################################################
# Install Wireshark
################################################################################
function install_wireshark()
{
    # Install Wireshark
    sudo add-apt-repository ppa:wireshark-dev/stable -y > /dev/null 2>&1
    sudo apt-get update -y
    echo "wireshark-common wireshark-common/install-setuid select true" | sudo debconf-set-selections
    sudo apt-get install wireshark -y > /dev/null 2>&1
    echo "Complete Wireshark Install."
    
    # Configure Wireshark
    sudo groupadd wireshark;
    sudo usermod -a -G wireshark ubuntu;
    sudo usermod -a -G wireshark root;
    sudo gpasswd -a ubuntu wireshark; 
    sudo gpasswd -a root wireshark; 
    sudo chgrp wireshark /usr/bin/dumpcap;
    sudo chmod 775 /usr/bin/dumpcap;
    sudo setcap cap_net_raw,cap_net_admin=eip /usr/bin/dumpcap;
    sudo getcap /usr/bin/dumpcap > /dev/null 2>&1;
}

install_wireshark