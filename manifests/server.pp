# http://confluence.jetbrains.com/display/TCD8/TeamCity+Specific+Directories#TeamCitySpecificDirectories-tcHomeDir
#
# Database types for 'db_type'
#  - 'postgresql'
#  - 'hsqldb' (default)
class teamcity::server(
  $user            = 'teamcity-server',
  $home_dir        = '/opt/teamcity-server',
  $data_dir        = '/var/lib/teamcity-server',
  $log_dir         = '/var/log/teamcity-server',
  $conf_dir        = '/opt/teamcity-server/conf',
  $port            = 8111,
  $server_opts     = '',
  $server_mem_opts = '-Xms750m -Xmx750m -XX:MaxPermSize=270m',
  $db_type         = 'hsqldb'
) {
  $service      = 'teamcity-server'
  $bin_dir      = "${home_dir}/bin"
  $temp_dir     = "${home_dir}/temp"
  $catalina_log = "${log_dir}/catalina.log"

  # see teamcity-server.erb
  # $catalina_tmp = "$data_dir/temp"
  # $catalina_pid = "/var/run/catalina.pid"

  include teamcity::common

  user { $user:
    ensure => present,
    home   => $home_dir,
    system => true,
  }

  include teamcity::db
  contain teamcity::db

  package { 'teamcity-server':
    ensure  => installed,
  }

  class { 'teamcity::server::config':
    content => template('teamcity/teamcity-server.erb'),
    require => Package['teamcity-server'],
  }

  contain teamcity::server::config

  service { $service:
    ensure     => running,
    enable     => true,
    hasstatus  => false,
    status     => 'ps aux | grep /usr/bin/java | grep teamcity_logs',
    hasrestart => true,
    require    => [
      Class[java],
      User[$user],
      Group[$teamcity::common::group],
      Package['teamcity-server']
    ],
  }
}
