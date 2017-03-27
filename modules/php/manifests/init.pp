class php {

    include system-update
    include apache
  
    package { ['php']:
        ensure  => 'installed',
        require => Exec['apt-get update'],
    }
    
    package { ['libapache2-mod-php']:
        ensure  => 'installed',
        require => Package['php'],
    }
  
    $sysPackages = [ 'php-apcu', 'php7.0-cli', 'php7.0-curl', 'php7.0-gd', 'php7.0-json', 'php7.0-mysql', 'php7.0-odbc', 'php7.0-opcache', 'php7.0-pgsql', 'php7.0-sqlite3', 'php7.0-xml', 'php7.0-mbstring', 'php7.0-mcrypt', 'php7.0-zip']
  
    package { $sysPackages:
        ensure => 'installed',
        require => [ Exec['apt-get update'], Package['php']],
    }

}