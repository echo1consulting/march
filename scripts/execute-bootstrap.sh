# Check if the machine has been bootstrapped

if [ -f /home/vagrant/.bootstrapped ]
then
    echo "Virtual machine has been bootstrapped."
    exit 0
fi

touch /home/vagrant/.bootstrapped

# Update repositories
sudo apt-get update -y > /dev/null 2>&1
echo "Updated package repositories."

# Install default packages
sudo apt-get install autoconf build-essential cmake daemon debconf-utils devscripts docbook-xsl libc-ares-dev libssl-dev make python python-pip python-setuptools python-software-properties quilt software-properties-common uuid-dev xsltproc -y > /dev/null 2>&1
echo "Installed default packages."

# Install Java
sudo add-apt-repository -y ppa:git-core/ppa -y > /dev/null 2>&1
sudo add-apt-repository -y ppa:webupd8team/java -y > /dev/null 2>&1
sudo apt-get update -y > /dev/null 2>&1
echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections
sudo apt-get install -y oracle-java8-installer -y > /dev/null 2>&1
echo "Installed Java 1.8.0_121."
