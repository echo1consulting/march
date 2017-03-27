Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/opt/puppetlabs/bin/" ] }

include apache
include generate-ca
include java
include lubuntu
include mosquitto
include php
include system-update

class { 'apt':
    update => {
        frequency => 'daily',
    },
}

# sudo mysql -uroot -p
class { "mysql":
    root_password => '',
}