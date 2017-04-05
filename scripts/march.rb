    class March
  def March.configure(config, settings)
    # Set The VM Provider
    ENV['VAGRANT_DEFAULT_PROVIDER'] = settings["provider"] ||= "virtualbox"

    # Configure Local Variable To Access Scripts From Remote Location
    scriptDir = File.dirname(__FILE__)

    # Prevent TTY Errors
    config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

    # Allow SSH Agent Forward from The Box
    config.ssh.forward_agent = true
    
    # Keep ssh connection alive
    config.ssh.keep_alive = true

    # Configure The Box
    config.vm.box = settings["box"] ||= "ubuntu/xenial64"
    config.vm.hostname = settings["hostname"] ||= "march"

    # Configure A Private Network IP
    config.vm.network :private_network, ip: settings["ip"] ||= "192.168.10.10"

    # Configure Additional Networks
    if settings.has_key?("networks")
      settings["networks"].each do |network|
        config.vm.network network["type"], ip: network["ip"], bridge: network["bridge"] ||= nil
      end
    end

    # Configure A Few VirtualBox Settings
    config.vm.provider "virtualbox" do |vb|
      vb.gui = false
      vb.name = settings["name"] ||= "march-1"
      vb.customize ["modifyvm", :id, "--memory", settings["memory"] ||= "4048"]
      vb.customize ["modifyvm", :id, "--cpus", settings["cpus"] ||= "2"]
      vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vb.customize ["modifyvm", :id, "--ostype", "Ubuntu_64"]
      vb.customize [ "modifyvm", :id, "--uart1", "0x3F8", "4" ]
      vb.customize [ "modifyvm", :id, "--uartmode1", "file", "console.log" ]
    end

    # Configure A Few VMware Settings
    ["vmware_fusion", "vmware_workstation"].each do |vmware|
      config.vm.provider vmware do |v|
        v.vmx["displayName"] = settings["name"] ||= "march-1"
        v.vmx["memsize"] = settings["memory"] ||= 4048
        v.vmx["numvcpus"] = settings["cpus"] ||= 1
        v.vmx["guestOS"] = "ubuntu-64"
      end
    end

    # Configure A Few Parallels Settings
    config.vm.provider "parallels" do |v|
      v.update_guest_tools = true
      v.memory = settings["memory"] ||= 4048
      v.cpus = settings["cpus"] ||= 1
    end

    # Standardize Ports Naming Schema
    if (settings.has_key?("ports"))
      settings["ports"].each do |port|
        port["guest"] ||= port["to"]
        port["host"] ||= port["send"]
        port["protocol"] ||= "tcp"
      end
    else
      settings["ports"] = []
    end

    # Default Port Forwarding
    default_ports = {
      21     => 21,
      80     => 80,
      1883   => 1883,
      8883   => 8883,
      9001   => 9001,
      9200   => 9200,
      9883   => 9883,
      5601   => 5601
    }

    # Use Default Port Forwarding Unless Overridden
    unless settings.has_key?("default_ports") && settings["default_ports"] == false
      default_ports.each do |guest, host|
        unless settings["ports"].any? { |mapping| mapping["guest"] == guest }
          config.vm.network "forwarded_port", guest: guest, host: host, host_ip: "127.0.0.1", auto_correct: true
        end
      end
    end

    # Add Custom Ports From Configuration
    if settings.has_key?("ports")
      settings["ports"].each do |port|
        config.vm.network "forwarded_port", guest: port["guest"], host: port["host"], host_ip: "127.0.0.1", protocol: port["protocol"], auto_correct: true
      end
    end

    # Configure The Public Key For SSH Access
    if settings.include? 'authorize'
      if File.exists? File.expand_path(settings["authorize"])
        config.vm.provision "shell" do |s|
          s.inline = "echo $1 | grep -xq \"$1\" /home/ubuntu/.ssh/authorized_keys || echo \"\n$1\" | tee -a /home/ubuntu/.ssh/authorized_keys"
          s.args = [File.read(File.expand_path(settings["authorize"]))]
        end
      end
    end

    # Copy The SSH Private Keys To The Box
    if settings.include? 'keys'
      settings["keys"].each do |key|
        config.vm.provision "shell" do |s|
          s.privileged = false
          s.inline = "echo \"$1\" > /home/ubuntu/.ssh/$2 && chmod 600 /home/ubuntu/.ssh/$2"
          s.args = [File.read(File.expand_path(key)), key.split('/').last]
        end
      end
    end

    # Copy User Files Over to VM
    if settings.include? 'copy'
      settings["copy"].each do |file|
        config.vm.provision "file" do |f|
          f.source = File.expand_path(file["from"])
          f.destination = file["to"].chomp('/') + "/" + file["from"].split('/').last
        end
      end
    end

    # Register All Of The Configured Shared Folders
    if settings.include? 'folders'
      settings["folders"].each do |folder|
        mount_opts = []

        if (folder["type"] == "nfs")
            mount_opts = folder["mount_options"] ? folder["mount_options"] : ['actimeo=1', 'nolock']
        elsif (folder["type"] == "smb")
            mount_opts = folder["mount_options"] ? folder["mount_options"] : ['vers=3.02', 'mfsymlinks']
        end

        # For b/w compatibility keep separate 'mount_opts', but merge with options
        options = (folder["options"] || {}).merge({ mount_options: mount_opts })

        # Double-splat (**) operator only works with symbol keys, so convert
        options.keys.each{|k| options[k.to_sym] = options.delete(k) }

        config.vm.synced_folder folder["map"], folder["to"], type: folder["type"] ||= nil, **options

        # Bindfs support to fix shared folder (NFS) permission issue on Mac
        if Vagrant.has_plugin?("vagrant-bindfs")
          config.bindfs.bind_folder folder["to"], folder["to"]
        end
      end
    end

    # Execute Bootstrap Scripts
    config.vm.provision "shell" do |s|
        s.name = "Execute Bootstrap Scripts"
        s.path = scriptDir + "/execute-bootstrap.sh"
    end
    
    # Execute Pre-Puppet Scripts
    config.vm.provision "shell", inline: "sudo apt-get install puppet -y"
    config.vm.provision "shell", inline: "sudo touch /etc/puppet/hiera.yaml" 
    config.vm.provision "shell", inline: "sudo mkdir -p /home/ubuntu/.puppet/" 
    config.vm.provision "shell", inline: "sudo touch /home/ubuntu/.puppet/hiera.yaml" 
    config.vm.provision "shell", inline: "sudo puppet module install maestrodev-wget --version 1.7.3"
    config.vm.provision "shell", inline: "sudo puppet module install puppetlabs-apt --version 2.3.0"

    # Execute Puppet Scripts
    config.vm.provision "puppet" do |puppet|
        puppet.module_path = "modules"
    end
      
  end
end
