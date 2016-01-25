# http://confluence.jetbrains.com/display/TCD8/TeamCity+Specific+Directories#TeamCitySpecificDirectories-tcHomeDir
#
# Database types for 'db_type'
#  - 'postgresql'
#  - 'hsqldb' (default)
class teamcity::server(
  $user              = 'teamcity-server',
  $install_dir       = '/opt',
  $home_dir          = '/opt/TeamCity',
  $data_dir          = '/var/lib/teamcity-server',
  $plugin_dir        = '/var/lib/teamcity-server/plugins',
  $log_dir           = '/var/log/teamcity-server',
  $conf_dir          = '/opt/TeamCity/conf',
  $team_city_version = '8.1.4',
  $port              = 8111,
  $address           = '0.0.0.0',
  $wget_opts         = '',
  $server_opts       = '',
  $server_mem_opts   = '-Xms750m -Xmx750m -XX:MaxPermSize=270m',
  $db_type           = 'hsqldb',
  $http_proxy_host   = '',
  $http_proxy_port   = '',
  $https_proxy_host  = '',
  $https_proxy_port  = '',
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
    ensure  => present,
    home    => $home_dir,
    system  => true,
    gid     => $teamcity::common::group,
    require => Class['teamcity::common']
  }

  exec { 'create teamcity data directories':
    command => "mkdir -p ${data_dir}/config/projects   ${data_dir}/lib/jdbc",
    timeout => 0,
    require => User[$user],
  }

  exec { 'chown teamcity data directories':
    command => "chown -R ${user}:${teamcity::common::group}  ${data_dir}/config  ${data_dir}/lib",
    timeout => 0,
    require => Exec['create teamcity data directories'],
  }

  include teamcity::db
  contain teamcity::db

  class { 'teamcity::server::install':
    wget_opts => $wget_opts,
    require   => Exec['chown teamcity data directories'],
  }

  class { 'teamcity::server::config':
    content => template('teamcity/teamcity-server.erb'),
    require => Class['teamcity::server::install'],
  }
  
  contain teamcity::server::config

  service { $service:
    ensure     => running,
    enable     => true,
    hasstatus  => false,
    provider   => 'init',
    status     => 'ps aux | grep /usr/bin/java | grep teamcity_logs',
    hasrestart => true,
    require    => [
      User[$user],
      Group[$teamcity::common::group],
      Class['teamcity::server::config'],
    ],
  }
}
