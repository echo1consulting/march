# Check if the machine has been bootstrapped

if [ -f /home/ubuntu/.bootstrapped ]
then
    echo "Virtual machine has been bootstrapped."
    exit 0
fi

touch /home/ubuntu/.bootstrapped

################################################################################
# Update repositories
################################################################################
function update_package_repositories()
{
    sudo apt-get update -y
    echo "Updated package repositories."
}

################################################################################
# Install Packages
################################################################################
function install_default_packages()
{
    sudo apt-get install autoconf build-essential cmake daemon debconf-utils devscripts docbook-xsl firefox libc-ares-dev libssl-dev make python python-pip python-setuptools python-software-properties quilt software-properties-common uuid-dev xsltproc -y 
    echo "Installed default packages."
}

################################################################################
# Install Java
################################################################################
function install_latest_java()
{
    sudo add-apt-repository ppa:webupd8team/java -y > /dev/null 2>&1
    sudo apt update -y 
    echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections
    sudo apt install oracle-java8-installer -y > /dev/null 2>&1
    echo "Installed Java 1.8"
}

################################################################################
# Install Wireshark
################################################################################
function install_wireshark()
{
    # Install Wireshark
    sudo add-apt-repository ppa:wireshark-dev/stable -y > /dev/null 2>&1
    # sudo apt-get update -y
    # echo "wireshark-common wireshark-common/install-setuid select true" | sudo debconf-set-selections
    #sudo apt-get install wireshark -y > /dev/null 2>&1
    #echo "Complete Wireshark Install."
    
    # Configure Wireshark
    #sudo groupadd wireshark;
    #sudo usermod -a -G wireshark ubuntu;
    #sudo usermod -a -G wireshark root;
    #sudo gpasswd -a ubuntu wireshark; 
    #sudo gpasswd -a root wireshark; 
    #sudo chgrp wireshark /usr/bin/dumpcap;
    #sudo chmod 775 /usr/bin/dumpcap;
    #sudo setcap cap_net_raw,cap_net_admin=eip /usr/bin/dumpcap;
    #sudo getcap /usr/bin/dumpcap > /dev/null 2>&1;
}

################################################################################
# Install Mosquitto Client
################################################################################
function install_mosquitto_client()
{
    sudo apt-get install mosquitto-clients -y 
    echo "Complete Mosquitto Client Install."
}

################################################################################
# Install Mosquitto Server
################################################################################
function install_mosquitto_server()
{

    wget http://launchpadlibrarian.net/141030801/libwebsockets3_1.2.2-1_amd64.deb -O /tmp/libwebsockets.deb
    sudo dpkg -i /tmp/libwebsockets.deb
    sudo apt-add-repository ppa:mosquitto-dev/mosquitto-ppa -y > /dev/null 2>&1
    sudo apt-get update
    sudo apt-get install mosquitto -y
    sudo chown ubuntu:ubuntu /var/log/mosquitto/mosquitto.log
    sudo sed -i '$ a port 1883' /etc/mosquitto/mosquitto.conf
    sudo sed -i '$ a listener 9001' /etc/mosquitto/mosquitto.conf
    sudo sed -i '$ a protocol websockets' /etc/mosquitto/mosquitto.conf
    sudo sed -i '$ a user root' /etc/mosquitto/mosquitto.conf
    sudo service mosquitto restart > /dev/null 2>&1

    # Test Subscribe
    # mosquitto_sub -h localhost -t "mqtt" -v

    # Test Publish
    # mosquitto_pub -h localhost -t "mqtt" -m "Hello MQTT"   
}

################################################################################
# Install Lubuntu Core
################################################################################
function install_lubuntu_core()
{
    sudo apt-get install lubuntu-core -y
    sudo passwd -d ubuntu
    echo "Complete Lubuntu Install."
}

################################################################################
# Install EK
################################################################################
function install_ek()
{
    # Add the repository and install elasticsearch
    wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
    sudo apt-get install apt-transport-https
    echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-5.x.list
    sudo apt-get update -y
    sudo apt-get install elasticsearch -y
    
    # Add a config line to not use too much memory
    sudo sed -i '$ a ES_JAVA_OPTS= -Xms512m -Xmx512m' /etc/default/elasticsearch 

    # Allow elasticsearch access from outside
    sudo sed -i '$ a network.host: 0.0.0.0' /etc/elasticsearch/elasticsearch.yml 
    
    # Add elasticsearch to the startup and start the service
    sudo /bin/systemctl daemon-reload
    sudo /bin/systemctl enable elasticsearch.service
    
    # Install Kibana
    sudo apt-get install kibana -y
    
    # Allow outside connections to kibana
    sudo sed -i '$ a server.host: "0.0.0.0"' /etc/kibana/kibana.yml 
    
    # Add Kibana to the startup and start the service
    sudo /bin/systemctl daemon-reload
    sudo /bin/systemctl enable kibana.service
}
    
################################################################################
# Execute Cleanup
################################################################################
function execute_cleanup()
{
    sudo reboot
}

update_package_repositories
install_default_packages
install_latest_java
#install_wireshark
install_mosquitto_client
install_mosquitto_server
install_lubuntu_core
install_ek
execute_cleanup