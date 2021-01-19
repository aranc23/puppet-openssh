# @summary installs ssh host key pairs
#
# installs ssh host key pairs onto a system, possibly include a cert
#
# @param keytype
#   ssh key type, rsa, ecdsa, etc.
# @param private_key
#   private key as a string for the given keytype
#   do not store this in puppet without encryption, or use some other form of secret injection
# @param public_key
#   public key as a string, with or without the leading keytype and trailing comment
# @param public_cert
#   complete public cert, a signed version of the matching public key
# @param mode
#   mode to create the private key with, defaults to private_key_mode from module
# @param group
#   group to use on the private key, defaults to private_key_group from module
# @param owner
#   owner of the private key file, defaults to private_key_owner
# @param ssh_etc
#   directory to put keys in, defaults to module default (/etc/ssh, most likely)
#
# @example
#   openssh::keypair { 'my rsa key':
#     keytype => 'rsa',
#     private_key => $some_key,
#     public_key => 'ssh-rsa ...',
#   }
#
define openssh::keypair
(
  Enum['rsa','dsa','ecdsa','ed25519'] $keytype,
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
    if($public_key =~ '^(ssh|ecdsa)-') {
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
      owner        => $owner,
      mode         => '0644',
      group        => $group,
      content      => "${public_cert}\n",
      validate_cmd => "${ssh_etc}/validate_public_cert.sh ${ssh_etc}/${key}.pub %",
    }
  }
}
