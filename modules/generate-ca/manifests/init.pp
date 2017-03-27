class generate-ca {

    include system-update
  
    file { [ '/etc/ssl/march' ]:
      ensure => 'directory',
    }
    ~>
    wget::fetch { 'Download Generate CA':
      source      => 'https://raw.githubusercontent.com/owntracks/tools/master/TLS/generate-CA.sh',
      destination => '/tmp/',
      timeout     => 0,
      verbose     => false,
      mode        => '0755',
    }
    ~>
    file { '/tmp/generate-CA.sh':
      mode   => 755,
      notify => Exec['generate_ca'],
    }
    ~>
    exec { 'generate_ca':
      command     => '/tmp/generate-CA.sh',
      refreshonly => true,
      cwd         => '/etc/ssl/march',
    }

}