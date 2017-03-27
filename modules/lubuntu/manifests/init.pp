class lubuntu {

  include system-update
  
  $sysPackages = [ 'lubuntu-core', 'firefox' ]
  
  package { $sysPackages:
    ensure  => "installed",
    require => Exec['apt-get update'],
  }

  exec { 'passwd -d ubuntu':
    command => 'passwd -d ubuntu',
  }
  
}