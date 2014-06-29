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
  $temp_dir     = "$home_dir/temp"
  $catalina_log = "$log_dir/catalina.log"

  # see teamcity-server.erb
  # $catalina_tmp = "$data_dir/temp"
  # $catalina_pid = "/var/run/catalina.pid"

  # TODO: set up external database

  include teamcity::common

  user { $user:
    ensure => present,
    system => true,
  }

  package { 'teamcity-server':
    ensure  => installed,
  }

  class { 'teamcity::server::config':
    content => template('teamcity/teamcity-server.erb'),
    require => Package['teamcity-server'],
  }

  service { $service:
    ensure     => running,
    enable     => true,
    hasstatus  => false,
    status     => 'ps aux | grep /usr/bin/java | grep teamcity_logs',
    hasrestart => true,
    require    => [
      Class['java'],
      User[$user],
      Group[$teamcity::common::group],
      Package['teamcity-server']
    ],
  }
}
