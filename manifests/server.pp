# http://confluence.jetbrains.com/display/TCD8/TeamCity+Specific+Directories#TeamCitySpecificDirectories-tcHomeDir
class teamcity::server(
  $user            = 'teamcity-server',
  $home_dir        = '/opt/teamcity-server',
  $data_dir        = '/var/lib/teamcity-server',
  $log_dir         = '/var/log/teamcity-server',
  $conf_dir        = '/opt/teamcity-server/conf',
  $port            = 8111,
  $server_opts     = '',
  $server_mem_opts = '-Xms750m -Xmx750m -XX:MaxPermSize=270m'
) {
  $service      = 'teamcity-server'
  $bin_dir      = "$home_dir/bin"
  $catalina_log = "$log_dir/catalina.log"

  # see teamcity-server.erb
  # $catalina_tmp = "$data_dir/temp"
  # $catalina_pid = "/var/run/catalina.pid"

  # TODO: set up external database
  # TODO: Catalina wants to write:
  #  - SEVERE: Unable to create directory for deployment: /opt/teamcity-server/conf/Catalina/localhost   
  #  - INFO: Deploying web application directory /opt/teamcity-server/webapps/ROOT 
  # TODO: setting up logging:
  #  - log4j:ERROR Could not parse url [file:/etc/teamcity-server/teamcity-server-log4j.xml].

  anchor { 'teamcity::server::start': }

  include teamcity::common

  user { $user:
    ensure => present,
    system => true,
    require => Anchor['teamcity::server::start'],
    before  => Anchor['teamcity::server::end'],
  }

  package { 'teamcity-server':
    ensure  => installed,
    require => [
      Anchor['teamcity::server::start'],
      Class['java']
    ],
    before  => Anchor['teamcity::server::end'],
  }

  class { 'teamcity::server::config':
    content => template('teamcity/teamcity-server.erb'),
    require => Package['teamcity-server'],
    notify  => Service[$service],
  }

  service { $service:
    ensure     => running,
    enable     => true,
    hasstatus  => false,
    status     => 'ps aux | grep /usr/bin/java | grep teamcity_logs',
    hasrestart => true,
    require    => [
      Anchor['teamcity::server::start'],
      User[$user],
      Group[$teamcity::common::group],
      Package['teamcity-server']
    ],
    before     => Anchor['teamcity::server::end'],
  }

  firewall { "101 allow tc-connections:8111":
    proto   => 'tcp',
    state   => ['NEW'],
    dport   => 8111,
    action  => 'accept',
  }

  anchor { 'teamcity::server::end': }
}