# Check if the script has executed 

if [ -f /home/vagrant/.mosquitto ]
then
    echo "Mosquitto already installed."
    exit 0
fi

touch /home/vagrant/.mosquitto

# Set the home directory
HOME_DIR=/home/vagrant

################################################################################
# Install the Mosquitto Client
################################################################################
sudo apt-get install mosquitto-clients -y > /dev/null 2>&1

################################################################################
# Download, Extract and Build libwebsockets
################################################################################
wget https://launchpad.net/ubuntu/+archive/primary/+files/libwebsockets_2.0.3.orig.tar.gz > /dev/null 2>&1
echo "Downloaded libwebsockets v2.0.3"
tar zxvf libwebsockets_2.0.3.orig.tar.gz > /dev/null 2>&1
echo "Extracted libwebsockets v2.0.3"
cd libwebsockets-2.0.3
sudo mkdir build
cd build
sudo cmake .. > /dev/null 2>&1
sudo make install > /dev/null 2>&1
cd ~
echo "Complete libwebsockets v2.0.3 build."

################################################################################
# Download, Extract and Build Mosquitto
################################################################################
wget https://mosquitto.org/files/source/mosquitto-1.4.9.tar.gz --no-check-certificate > /dev/null 2>&1
echo "Downloaded Mosquitto v1.4.9"
tar zxvf mosquitto-1.4.9.tar.gz > /dev/null 2>&1
echo "Extracted Mosquitto v1.4.9"
cd mosquitto-1.4.9
# Find and replace a line in the config to build with websockets support
sudo sed -i -e 's/WITH_WEBSOCKETS:=no/WITH_WEBSOCKETS:=yes/g' config.mk
sudo make install > /dev/null 2>&1
# Append configuration lines to enable websockets
sudo cp /etc/mosquitto/mosquitto.conf.example /etc/mosquitto/mosquitto.conf
sudo sed -i '$ a port 1883' /etc/mosquitto/mosquitto.conf
sudo sed -i '$ a listener 9001' /etc/mosquitto/mosquitto.conf
sudo sed -i '$ a protocol websockets' /etc/mosquitto/mosquitto.conf
sudo sed -i '$ a user root' /etc/mosquitto/mosquitto.conf
sudo /sbin/ldconfig
echo "Complete Mosquitto v1.4.9 build."

# Start the Mosquitto process
sudo /usr/local/sbin/mosquitto -c /etc/mosquitto/mosquitto.conf > /dev/null 2>&1 &

# Test Subscribe
# mosquitto_sub -h localhost -t "mqtt" -v

# Test Publish
# mosquitto_pub -h localhost -t "mqtt" -m "Hello MQTT"

################################################################################
# Install MQTT-SN CLI tools
################################################################################
function install_mqtt_sn_tools()
{
	cd ${HOME_DIR}
    wget https://github.com/njh/mqtt-sn-tools/archive/master.tar.gz --no-check-certificate > /dev/null 2>&1
	tar xzf master.tar.gz
	rm master.tar.gz
	cd mqtt-sn-tools-master/
	make
	echo "export PATH=\${PATH}:${HOME_DIR}/mqtt-sn-tools-master/" >> ${HOME_DIR}/.bashrc
    echo "Complete MQTT-SN CLI Tools."
    cd ~
}

################################################################################
# Main
################################################################################
install_mqtt_sn_tools
