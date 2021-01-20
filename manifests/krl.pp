# @summary create a kernel revocation list, configure openssh to use it
#
# @example
#   include openssh::krl
class openssh::krl {
  if($openssh::manage_krl) {
    $krl = $openssh::krl
    sshd_config { 'RevokedKeys':
      value => $openssh::krl_path,
    }
    file { "${openssh::krl_path}.txt":
      owner        => 'root',
      group        => 0,
      mode         => '0644',
      content      => template('openssh/krl.erb'),
      validate_cmd => 'ssh-keygen -k -f /dev/null %',
    }
    ~> exec { "ssh-keygen -k -f ${openssh::krl_path} ${openssh::krl_path}.txt":
      path        => ['/bin','/usr/bin'],
      refreshonly => true,
    }
    file { $openssh::krl_path:
      ensure  => present,
      owner   => 'root',
      group   => 0,
      mode    => '0644',
      replace => false,
    }
  }
}
