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

  if ('rsa' in $openssh::supported_key_types and $openssh::rsa_private_key and $openssh::rsa_public_key) {
    openssh::keypair { "${trusted['certname']} rsa key":
      keytype     => 'rsa',
      private_key => $openssh::rsa_private_key,
      public_key  => $openssh::rsa_public_key,
      public_cert => $openssh::rsa_public_cert,
    }
  }
  if ('dsa' in $openssh::supported_key_types and $openssh::dsa_private_key and $openssh::dsa_public_key) {
    openssh::keypair { "${trusted['certname']} dsa key":
      keytype     => 'dsa',
      private_key => $openssh::dsa_private_key,
      public_key  => $openssh::dsa_public_key,
      public_cert => $openssh::dsa_public_cert,
    }
  }
  if ('ecdsa' in $openssh::supported_key_types and $openssh::ecdsa_private_key and $openssh::ecdsa_public_key) {
    openssh::keypair { "${trusted['certname']} ecdsa key":
      keytype     => 'ecdsa',
      private_key => $openssh::ecdsa_private_key,
      public_key  => $openssh::ecdsa_public_key,
      public_cert => $openssh::ecdsa_public_cert,
    }
  }
  if ('ed25519' in $openssh::supported_key_types and $openssh::ed25519_private_key and $openssh::ed25519_public_key) {
    openssh::keypair { "${trusted['certname']} ed25519 key":
      keytype     => 'ed25519',
      private_key => $openssh::ed25519_private_key,
      public_key  => $openssh::ed25519_public_key,
      public_cert => $openssh::ed25519_public_cert,
    }
  }
  $openssh::keypairs.each |String $t,Hash $kp| {
    if $t in $openssh::supported_key_types {
      openssh::keypair { "${trusted['certname']} ${t} key":
        keytype => $t,
        *       => $kp,
      }
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
