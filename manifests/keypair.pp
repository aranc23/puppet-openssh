# keypair.pp for openssh::keypair

define openssh::keypair
(
  Enum['rsa1','rsa','dsa','ecdsa','ed25519'] $keytype,
  Variant[String,Undef] $private_key,
  Variant[String,Undef] $public_key,
  Variant[String,Undef] $public_cert = undef,
  Stdlib::Filemode $mode = $::openssh::private_key_mode,
  Variant[String,Integer] $group = $::openssh::private_key_group,
  Variant[String,Integer] $owner = $::openssh::private_key_owner,
  Stdlib::Absolutepath $ssh_etc = $::openssh::ssh_etc,
)
{
  $string = $keytype ? {
    'rsa1'    => '',
    'rsa'     => 'rsa_',
    'dsa'     => 'dsa_',
    'ecdsa'   => 'ecdsa_',
    'ed25519' => 'ed25519_',
  }
  $ident = $keytype ? {
    'rsa'     => 'ssh-rsa',
    'dsa'     => 'ssh-dss',
    'ecdsa'   => 'ecdsa-sha2-nistp256',
    'ed25519' => 'ssh-ed25519',
  }
  $key="ssh_host_${string}key"
  if($private_key) {
    file { "${ssh_etc}/${key}":
      owner     => $owner,
      mode      => $mode,
      group     => $group,
      content   => $private_key,
      show_diff => false,
    }
  }
  if($public_key) {
    # if the key is the full string, use it as is
    if($public_key =~ "^(ssh|ecdsa)-") {
      $public_key_string = "${public_key}\n"
    }
    else {
      # if not prepend the ident string as above and the hostname at the end
      $public_key_string = "${ident} ${public_key} ${::fqdn}\n"
    }
    file { "${ssh_etc}/${key}.pub":
      owner   => $owner,
      mode    => '0644',
      group   => $group,
      content => $public_key_string,
    }
  }
  if($public_cert) {
    file { "${ssh_etc}/${key}-cert.pub":
      owner   => $owner,
      mode    => '0644',
      group   => $group,
      content => "${public_cert}\n",
    }
  }    
}
