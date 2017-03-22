# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

# Require a minimum vagrant version
Vagrant.require_version '>= 1.8.4'

# Set the path to the march directory in the user profile
confDir = $confDir ||= File.expand_path("~/.march")

# Require the march ruby script
require File.expand_path(File.dirname(__FILE__) + '/scripts/march.rb')

# Configure the virtual machine
Vagrant.configure("2") do |config|
    
    # Copy mosquitto configuration to temp directory
    config.vm.provision :file do |file|
        file.source = File.dirname(__FILE__) + "/conf/mosquitto.conf"
        file.destination =  "/tmp/mosquitto.conf"
    end
    
    # Copy generateCA to temp directory
    config.vm.provision :file do |file|
        file.source = File.dirname(__FILE__) + "/conf/generateCA.sh"
        file.destination =  "/tmp/generateCA.sh"
    end    
    
    # Set the path to the aliases file
    aliasesPath = confDir + "/aliases"

    if File.exist? aliasesPath then
        config.vm.provision "file", source: aliasesPath, destination: "~/.bash_aliases"
    end

    # Set the path to the yaml configuration file
    marchYamlPath = confDir + "/March.yaml"

    if File.exist? marchYamlPath then
        settings = YAML::load(File.read(marchYamlPath))
    end

    # Instantiate the configuration settings
    March.configure(config, settings)
    
    # Set the path to the scripts to run after provision
    afterScriptPath = confDir + "/after.sh"

    if File.exist? afterScriptPath then
        config.vm.provision "shell", path: afterScriptPath, privileged: false
    end

end
