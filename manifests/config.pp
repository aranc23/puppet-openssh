# @summary configure openssh, install ssh keys, etc.
#
class openssh::config
(
)
{
  create_resources(
    'sshd_config',
    $openssh::sshd_config,
    { target => $openssh::sshd_config_path },
  )
  # if a banner is specified, then create and configure it
  if($openssh::banner and length($openssh::banner) > 0) {
    file { $openssh::banner_path:
      owner   => 'root',
      group   => 0,
      mode    => '0644',
      content => $openssh::banner,
    }
    sshd_config { 'Banner':
      value => $openssh::banner_path,
    }
  }

  $::openssh::supported_key_types.each |String $keytype| {
    openssh::keypair { "${::fqdn} ${keytype} key":
      keytype     => $keytype,
      private_key => lookup("openssh::${keytype}_private_key",Variant[String,Undef],'first',undef),
      public_key  => lookup("openssh::${keytype}_public_key",Variant[String,Undef],'first',undef),
      public_cert => lookup("openssh::${keytype}_public_cert",Variant[String,Undef],'first',undef),
    }
  }
  if($openssh::manage_krl) {
    sshd_config { 'RevokedKeys':
      value => $openssh::krl_path,
    }
    $_krl = $openssh::process_krl ? {
      true  => "${openssh::krl_path}.in",
      false => $openssh::krl_path,
    }
    if($openssh::krl_source) {
      file { $_krl:
        owner  => 'root',
        group  => 0,
        mode   => '0644',
        source => $openssh::krl_source,
        notify => $openssh::process_krl ? {
          true    => Exec['ssh-keygen-krl'],
          default => undef,
        }
      }
    }
    else {
      create_resources(
        'ssh_authorized_key',
        $openssh::krl,
        {
          user => 'root',
          target => $_krl,
          notify => $openssh::process_krl ? {
            true    => Exec['ssh-keygen-krl'],
            default => undef,
          },
        }
      )
    }
    if $openssh::process_krl {
      exec { "/usr/bin/ssh-keygen -k -f ${openssh::krl_path} ${_krl}":
        alias       => 'ssh-keygen-krl',
        refreshonly => true,
      }
    }
  }
  if($openssh::manage_trusted_user_ca_keys) {
    sshd_config { 'TrustedUserCAKeys':
      value => $openssh::trusted_user_ca_keys_path,
    }
    create_resources(
      'ssh_authorized_key',
      $openssh::trusted_user_ca_keys,
      { user => 'root', target => $openssh::trusted_user_ca_keys_path },
    )
  }
}
