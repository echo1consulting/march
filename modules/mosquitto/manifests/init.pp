class mosquitto {

    include system-update
    include generate-ca

    $sysPackages = ['cmake', 'daemon', 'libc-ares-dev', 'libcurl4-openssl-dev', 'libssl-dev', 'libwebsockets-dev', 'libwrap0-dev', 'make', 'python-distutils-extra', 'uuid-dev']
  
    package { $sysPackages:
        ensure => 'installed',
        require => [ Exec['apt-get update']],
    }
    
    package { ['mosquitto-clients']:
        ensure  => 'installed',
        require => Exec['apt-get update'],
    }
        
    wget::fetch { 'Download Mosquitto Source':
      source      => 'http://mosquitto.org/files/source/mosquitto-1.4.9.tar.gz',
      destination => '/tmp/mosquitto-1.4.9.tar.gz',
      timeout     => 0,
      verbose     => false,
      mode        => '0755',
      require     => Package[$sysPackages],
    }
        
    exec {'unpack_mosquitto_source':
      cwd     => '/tmp',
      command => 'tar zxvf mosquitto-1.4.9.tar.gz',
      require => Wget::Fetch['Download Mosquitto Source']
    }
    ~>
    exec {'enable_mosquitto_websockets':
      cwd     => '/tmp/mosquitto-1.4.9',
      command => "sed -ie 's/WITH_WEBSOCKETS:=no/WITH_WEBSOCKETS:=yes/g' config.mk",
    }
    ~>
    exec {'clean_make_mosquitto':
      cwd     => '/tmp/mosquitto-1.4.9',
      command => 'make clean',
    }
    ~>
    exec {'make_mosquitto':
      cwd     => '/tmp/mosquitto-1.4.9',
      command => 'make',
    }
    ~>
    exec {'make_mosquitto_install':
      cwd     => '/tmp/mosquitto-1.4.9',
      command => 'make install',
    }
    ~>
    file { [ '/etc/mosquitto', '/var/log/mosquitto' ]:
      ensure    => 'directory',
      recurse   => true,
      owner     => 'ubuntu',
      group     => 'ubuntu',
    }
    ~>
    file { [ '/var/log/mosquitto/mosquitto.log' ]:
      ensure    => 'present',
      replace   => 'no',
      content   => ' ',
      owner     => 'ubuntu',
      group     => 'ubuntu',
      mode      => '0644',
    }
    ~>
    file { '/etc/mosquitto/mosquitto.conf':
      ensure  => file,
      content => template('mosquitto/mosquitto.conf.erb'),
      # Loads /mosquitto/templates/mosquitto.conf.erb
    }
    ~>
    file { '/etc/systemd/system/mosquitto.service':
      ensure  => file,
      content => template('mosquitto/mosquitto.service.erb'),
      # Loads /mosquitto/templates/mosquitto.service.erb
    }
    ~>
    exec {'execute_mosquitto_on_start':
      command => 'systemctl enable mosquitto',
    }
    
    service { 'mosquitto':
        ensure  => 'running',
        enable  => true,
        require => Exec['execute_mosquitto_on_start'],
    }
    
}

    # Test Subscribe
    # mosquitto_sub -h localhost -t "mqtt" -v

    # Test Publish
    # mosquitto_pub -h localhost -t "mqtt" -m "Hello MQTT"   