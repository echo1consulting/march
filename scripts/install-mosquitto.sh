# Set the home directory
HOME_DIR=/home/vagrant


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
	make > /dev/null 2>&1
    # export PATH=${PATH}:~/mqtt-sn-tools-master/
	sudo echo "PATH=${PATH}:${HOME_DIR}/mqtt-sn-tools-master/" >> ~/.bashrc
    source .bashrc
    echo "Complete MQTT-SN CLI Tools."
    cd ~
}

################################################################################
# Main
################################################################################
install_mqtt_sn_tools
