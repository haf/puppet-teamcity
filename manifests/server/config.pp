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

  file { "/etc/init.d/$teamcity::server::service":
    ensure  => present,
    content => $content,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    notify  => Service[$teamcity::server::service],
  }
}