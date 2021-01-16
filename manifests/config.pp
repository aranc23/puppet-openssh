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
    $private_key = lookup("openssh::${keytype}_private_key",Variant[String,Undef],'first',undef)
    $public_key = lookup("openssh::${keytype}_public_key",Variant[String,Undef],'first',undef)
    $public_cert = lookup("openssh::${keytype}_public_cert",Variant[String,Undef],'first',undef)

    openssh::keypair { "${::fqdn} ${keytype} key":
      keytype     => $keytype,
      private_key => $private_key,
      public_key  => $public_key,
      public_cert => $public_cert,
    }
  }
}
