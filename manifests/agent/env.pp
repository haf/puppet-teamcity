class teamcity::agent::env {
  $bash_profile       = "${teamcity::agent::home}/.bash_profile"

  concat { $bash_profile:
    owner => $teamcity::agent::user,
    group => $teamcity::common::group,
    mode  => '0644',
  }

  concat::fragment { 'bash_profile_frag':
    target  => $bash_profile,
    content =>
"# ~/.bash_profile managed by puppet/teamcity::agent::env\n\
# Use ~/.bash_profile.local to append into .bash_profile 'snowflakey'\n",
    order   => 01,
  }

  # ensure there's a .bash_profile.local should
  # we want to use it on the agent.
  file { "${bash_profile}.local":
    ensure  => file,
    content => '',
    replace => false,
    owner   => $teamcity::agent::user,
    group   => $teamcity::common::group,
  }

  # local users on the machine can append to motd by just creating
  # ~/.bash_profile.local
  concat::fragment { 'bash_profile_frag-local':
    target  => $bash_profile,
    source  => "${bash_profile}.local",
    order   => 15,
    require => File["${bash_profile}.local"],
  }
}

# used by other modules to register themselves in the agent profile
define teamcity::agent::env::bash_profile(
  $content = '',
  $order = 10
) {
  $body = $content ? {
    ''      => $name,
    undef   => $name,
    default => $content,
  }

  concat::fragment { "bash_profile_frag-${name}":
    target  => $teamcity::agent::env::bash_profile,
    content => "${body}\n",
  }
}