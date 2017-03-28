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
