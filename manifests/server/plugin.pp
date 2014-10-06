class teamcity::server::plugin(
    $plugin_url  = '',
    $plugin_zip_file  = '',
) {

  exec { 'download teamcity plugin':
   command     => "wget \"$plugin_url\"",
   creates     => "$teamcity::server::plugin_dir/$plugin_zip_file",
   cwd         => "$teamcity::server::plugin_dir",
   notify      => Exec['restart teamcity service'],
   timeout     => 0
  } 
  
 exec { 'set ownership teamcity plugin':
   command     => "chown $teamcity::server::user:$teamcity::common::group \"$teamcity::server::plugin_dir/$plugin_zip_file\"",
   cwd         => "$teamcity::server::plugin_dir",
   require     => Exec['download teamcity plugin'],
   timeout     => 0
  }   
  
 exec { 'restart teamcity service':
   command     => "service $teamcity::server::service restart",
   cwd         => "$teamcity::server::home_dir",
   refreshonly => true,
   timeout     => 0
  }   
  

}  
  