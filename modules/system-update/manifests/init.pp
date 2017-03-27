class system-update {

    exec { 'apt-get update':
        command => 'apt-get update',
        timeout => 60,
        tries   => 3,
    }

    package { ['python-software-properties', 'virtualbox-guest-additions-iso']:
        ensure  => 'installed',
        require => Exec['apt-get update'],
    }

    $sysPackages = [ 'build-essential', 'git', 'curl']
    package { $sysPackages:
        ensure => "installed",
        require => Exec['apt-get update'],
    }

}