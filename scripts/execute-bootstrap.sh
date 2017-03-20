# Check if the machine has been bootstrapped

if [ -f /home/ubuntu/.bootstrapped ]
then
    echo "Virtual machine has been bootstrapped."
    exit 0
fi

touch /home/ubuntu/.bootstrapped


################################################################################
# Setup Certificates
################################################################################
function setup_certificates()
{
    wget https://raw.githubusercontent.com/owntracks/tools/master/TLS/generate-CA.sh -O /tmp/generateCA.sh
    sudo chmod 755 /tmp/generateCA.sh
}

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
    sudo apt-get install autoconf build-essential cmake daemon debconf-utils devscripts docbook-xsl firefox libc-ares-dev libssl-dev make protobuf-compiler python python-pip python-setuptools python-software-properties quilt software-properties-common uuid-dev xsltproc -y 
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
    sudo cp /tmp/ca.* /etc/mosquitto/ca_certificates/
    sudo cp /tmp/march.* /etc/mosquitto/ca_certificates/
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
# Execute Cleanup
################################################################################
function execute_cleanup()
{
    sudo reboot
}

setup_certificates
update_package_repositories
install_default_packages
install_latest_java
install_mosquitto_client
install_mosquitto_server
install_lubuntu_core
execute_cleanup