class teamcity::server::config(
  $content
) {
  file { $teamcity::server::home_dir:
    ensure  => directory,
    owner   => $teamcity::server::user,
    group   => $teamcity::common::group,
    mode    => '0644',
  }

  file { $teamcity::server::bin_dir:
    ensure => directory,
    owner   => $teamcity::server::user,
    group   => $teamcity::common::group,
    mode    => '0755',
    recurse => true,
    require => File[$teamcity::server::home_dir],
  }

  file { [
    $teamcity::server::log_dir,
    $teamcity::server::data_dir,
    "$teamcity::server::home_dir/webapps/ROOT/WEB-INF"
    ]:
    ensure  => directory,
    owner   => $teamcity::server::user,
    group   => $teamcity::common::group,
    mode    => '0644',
    recurse => true,
  }

  file { "/etc/init.d/$teamcity::server::service":
    ensure  => present,
    content => $content,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
  }
}