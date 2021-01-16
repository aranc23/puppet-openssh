# @summary manage hashed known hosts file
#
# use a template to create a non-hashed known hosts file
# use a shell script to create a hashed version
class openssh::known_hosts
(
)
{
  if($::openssh::manage_known_hosts == true) {
    file { $::openssh::known_hosts_path:
      owner   => 'root',
      group   => 0,
      mode    => '0644',
      replace => false,
      content => "#managed by puppet\n"
    }
    $keys = $openssh::sshkeys
    file { "${::openssh::known_hosts_path}.unhashed":
      owner     => 'root',
      group     => 0,
      mode      => '0600',
      content   => template('openssh/known_hosts.erb'),
      notify    => Exec['hash_known_hosts'],
      show_diff => false,
    }
    $hash_known_hosts_template = @(HASHTEMPLATE)
    #! /bin/bash -e
    known_hosts=<%= scope['openssh::known_hosts_path'] %>
    cp -f "${known_hosts}.unhashed" $known_hosts
    ssh-keygen -H -f $known_hosts
    rm -f "${known_hosts}.old"
    chmod 0644 $known_hosts
    | HASHTEMPLATE
    $hash_script = "${::openssh::known_hosts_path}.sh"
    file { $hash_script:
      owner   => root,
      mode    => '0700',
      group   => 0,
      content => inline_template($hash_known_hosts_template),
    }
    exec { $hash_script:
      require     => File[$hash_script],
      alias       => 'hash_known_hosts',
      refreshonly => true,
    }
  }
}
