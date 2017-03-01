# Check if the machine has been bootstrapped

if [ -f /home/vagrant/.bootstrapped ]
then
    echo "Virtual machine has been bootstrapped."
    exit 0
fi

touch /home/vagrant/.bootstrapped

################################################################################
# Update repositories
################################################################################
function update_package_repositories()
{
    sudo apt-get update -y > /dev/null 2>&1
    echo "Updated package repositories."
}

################################################################################
# Install Packages
################################################################################
function install_default_packages()
{
    sudo apt-get install autoconf build-essential cmake daemon debconf-utils devscripts docbook-xsl firefox libc-ares-dev libssl-dev make python python-pip python-setuptools python-software-properties quilt software-properties-common uuid-dev xsltproc -y > /dev/null 2>&1
    echo "Installed default packages."
}

################################################################################
# Install Java
################################################################################
function install_latest_java()
{
    sudo add-apt-repository -y ppa:git-core/ppa -y > /dev/null 2>&1
    sudo add-apt-repository -y ppa:webupd8team/java -y > /dev/null 2>&1
    sudo apt-get update -y > /dev/null 2>&1
    echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections
    sudo apt-get install -y oracle-java8-installer -y > /dev/null 2>&1
    echo "Installed Java 1.8.0_121."
}

################################################################################
# Install Lubuntu Core
################################################################################
function install_lubuntu_core()
{
    sudo apt-get install lubuntu-core -y > /dev/null 2>&1
    # Remove vagrant password
    sudo passwd -d vagrant
    echo "Complete Lubuntu Install."
}

################################################################################
# Install Wireshark
################################################################################
function install_wireshark()
{
    # Install Wireshark
    sudo apt-get install wireshark -y > /dev/null 2>&1
    echo "Complete Wireshark Install."
    
    # Configure Wireshark
    sudo groupadd wireshark > /dev/null 2>&1
    sudo usermod -a -G wireshark vagrant > /dev/null 2>&1
    sudo usermod -a -G wireshark root > /dev/null 2>&1
    sudo gpasswd -a vagrant wireshark > /dev/null 2>&1
    sudo gpasswd -a root wireshark > /dev/null 2>&1
    sudo chgrp wireshark /usr/bin/dumpcap > /dev/null 2>&1
    sudo chmod 750 /usr/bin/dumpcap > /dev/null 2>&1
    sudo setcap cap_net_raw,cap_net_admin=eip /usr/bin/dumpcap > /dev/null 2>&1
    sudo getcap /usr/bin/dumpcap > /dev/null 2>&1
}

################################################################################
# Install Mosquitto Client
################################################################################
function install_mosquitto_client()
{
    sudo apt-get install mosquitto-clients -y > /dev/null 2>&1
    echo "Complete Mosquitto Client Install."
}

################################################################################
# Install Mosquitto Server
################################################################################
function install_mosquitto_server()
{
    wget https://mosquitto.org/files/source/mosquitto-1.4.9.tar.gz --no-check-certificate -O /tmp/mosquitto.tar.gz > /dev/null 2>&1
    sudo tar zxvf /tmp/mosquitto.tar.gz -C /tmp/ > /dev/null 2>&1
    # Find and replace a line in the config to build with websockets support
    sudo sed -i -e 's/WITH_WEBSOCKETS:=no/WITH_WEBSOCKETS:=yes/g' /tmp/mosquitto-1.4.9/config.mk
    cd /tmp/mosquitto-1.4.9/
    sudo make install > /dev/null 2>&1
    cd ~
    sudo cp /etc/mosquitto/mosquitto.conf.example /etc/mosquitto/mosquitto.conf
    sudo sed -i '$ a port 1883' /etc/mosquitto/mosquitto.conf
    sudo sed -i '$ a listener 9001' /etc/mosquitto/mosquitto.conf
    sudo sed -i '$ a protocol websockets' /etc/mosquitto/mosquitto.conf
    sudo sed -i '$ a user vagrant' /etc/mosquitto/mosquitto.conf
    sudo /sbin/ldconfig
    cd ~

    # Start the Mosquitto process
    # sudo /usr/local/sbin/mosquitto -c /etc/mosquitto/mosquitto.conf > /dev/null 2>&1 &

    # Test Subscribe
    # mosquitto_sub -h localhost -t "mqtt" -v

    # Test Publish
    # mosquitto_pub -h localhost -t "mqtt" -m "Hello MQTT"   
}

################################################################################
# Install Websockets Library
################################################################################
function install_websockets_library()
{
    cd ~
    wget https://launchpad.net/ubuntu/+archive/primary/+files/libwebsockets_2.0.3.orig.tar.gz -O /tmp/libwebsockets.tar.gz > /dev/null 2>&1
    sudo tar zxvf /tmp/libwebsockets.tar.gz -C /tmp/ > /dev/null 2>&1
    sudo mkdir -p /tmp/libwebsockets-2.0.3/build
    cd /tmp/libwebsockets-2.0.3/build/
    sudo cmake .. > /dev/null 2>&1
    sudo make install > /dev/null 2>&1
    cd ~
    echo "Complete Libwebsockets Install."
}

################################################################################
# Execute Cleanup
################################################################################
function execute_cleanup()
{
    sudo apt-get autoclean
    sudo rm /var/cache/apt/archives/*.deb
    sudo reboot
}

update_package_repositories
install_default_packages
install_latest_java
install_wireshark
install_websockets_library
install_mosquitto_client
install_mosquitto_server
install_lubuntu_core
execute_cleanup