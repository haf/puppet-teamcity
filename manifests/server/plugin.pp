class teamcity::server::plugin(
    $plugin_url  = '',
    $plugin_zip_file  = '',
) {

  exec { 'install teamcity plugin':
   command     => "wget \"$plugin_url\"",
   creates     => "$teamcity::server::data_dir/plugins/$plugin_zip_file",
   cwd         => "$teamcity::server::data_dir/plugins",
#   notify      => Service[$teamcity::server::service],
   timeout     => 0
  } 

}  
  