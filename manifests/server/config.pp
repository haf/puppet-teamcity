class teamcity::server::config(
  $content
) {

  File {
    owner   => $teamcity::server::user,
    group   => $teamcity::common::group,
    mode    => '0755',
  }

  file {
    $teamcity::server::home_dir:
      ensure => directory;
    $teamcity::server::log_dir:
      ensure => directory;
    $teamcity::server::data_dir:
      ensure => directory;
    $teamcity::server::plugin_dir:
      ensure => directory,
  }
  
  file { "${teamcity::server::home_dir}/conf/server.xml":
    ensure  => present,
    content => template('teamcity/server.xml.erb'),
    mode    => '0644',
    owner   => $teamcity::server::user,
    group   => $teamcity::common::group,
  }

  file { "/etc/init.d/${teamcity::server::service}":
    ensure  => present,
    content => $content,
    mode    => '0755',
    owner   => root,
    group   => root,
    notify  => Service[$teamcity::server::service],
    require => File["${teamcity::server::home_dir}/conf/server.xml"],
  }
}
