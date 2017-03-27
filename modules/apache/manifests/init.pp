class apache {
  
    include system-update

    package { ['apache2']:
        ensure  => 'installed',
        require => Exec['apt-get update'],
    }

    file { '/var/www' :
        ensure    => directory,
        owner     => 'www-data',
        group     => 'www-data',
        require   => [ Package['apache2'], ],
        recurse   => true,
    }
   
    service { 'apache2':
        ensure  => 'running',
        enable  => true,
        require => Package['apache2'],
    }
  
    exec { 'Enable apache headers module':
        command => 'a2enmod headers',
        notify  => Service["apache2"],
        require => [ Package['apache2'], ],
    }
  
}