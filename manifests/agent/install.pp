# A class for installing the agent from a TeamCity Server
#
class teamcity::agent::install(
    $download_dir       = "/tmp",
) {

  exec { 'download teamcity agent':
   command     => "wget \"${teamcity::agent::server_url}/update/buildAgent.zip\"",
   creates     => "$download_dir/buildAgent.zip",
   cwd         => "$download_dir",
   timeout     => 0
  } 

  exec { 'unzip teamcity agent':
    command => "/usr/bin/unzip buildAgent.zip -d ${teamcity::agent::home}",
    cwd     => $download_dir,
    creates => $teamcity::agent::home,
    require => [
      User[$teamcity::agent::user],
      Exec['download teamcity agent']
    ],
    user    => 'root',
  }

  file { $teamcity::agent::home:
    ensure  => directory,
    owner   => $teamcity::agent::user,
    group   => $teamcity::common::group,
    mode    => '0644',
    replace => false,
    require => Exec['unzip teamcity agent'],
  }
}
