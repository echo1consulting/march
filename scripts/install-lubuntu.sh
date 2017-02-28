# Check if the script has executed 

if [ -f /home/vagrant/.lubuntu ]
then
    echo "Lubuntu is already installed."
    exit 0
fi

touch /home/vagrant/.lubuntu

sudo apt-get install lubuntu-desktop -y > /dev/null 2>&1
echo "Complete Lubuntu Install."
sudo reboot