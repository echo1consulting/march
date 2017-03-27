include apt

class java {
    
    apt::ppa { 'ppa:webupd8team/java': 
        ensure => present,
    }

    exec { 'apt-get update prejava':
        command => 'apt-get update',
        require => [
          Apt::Ppa['ppa:webupd8team/java']
        ],
    }
      
    exec { 'accept_oracle_java_license':
        command   => 'echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections && echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections',
        logoutput => true,
    }

    package {['oracle-java8-installer',]:
        ensure  => 'installed',
        require => [ Exec['apt-get update prejava'], Apt::Ppa['ppa:webupd8team/java'], Exec['accept_oracle_java_license'], ]
    }
    
}