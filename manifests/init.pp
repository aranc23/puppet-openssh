# @summary install and configure openssh
#
# Install openssh server and client packages, optionally configure the
# server and client, and start the service.
# Module will optionally manage the following:
# * ssh_known_hosts
# * authorized_keys
# * host key pairs
# * signed ssh host certs (ie: /etc/ssh/ssh_host_ecdsa-cert.pub)
#
# @param ssh_config
#   ssh_config resources from augeasproviders_ssh (merged using hash deep)
# @param sshd_config
#   sshd_config resources from augeasproviders_ssh (merged using hash deep)
# @param ssh_etc
#   where to put ssh configuration files, including the known hosts and ssh key pairs
# @param sshd_config_path
#   full path to the sshd_config file, if undefined let the augeas provider decide
# @param ssh_config_path
#   full path to the ssh_config file, if undefined let the augeas provider decide
# @param manage_known_hosts
#   manage the known hosts file, or not
# @param known_hosts_path
#   full path to the known hosts files
# @param banner_path
#   path to banner file
# @param banner
#   string to put into the banner path, will not create the banner if this is left undefined
# @param private_key_mode
#   the mode to use on private keys
# @param private_key_owner
#   probably root, some systems use odd owner/groups on private keys
# @param private_key_group
#   probably root, some systems use odd owner/groups on private keys
# @param rsa_private_key
#   rsa private key
# @param rsa_public_key
#   rsa public key
# @param rsa_public_cert
#   rsa public cert (signed public key)
# @param dsa_private_key
#   dsa private key
# @param dsa_public_key
#   dsa public key
# @param dsa_public_cert
#   dsa public cert (signed public key)
# @param ecdsa_private_key
#   ecdsa private key
# @param ecdsa_public_key
#   ecdsa public key
# @param ecdsa_public_cert
#   ecdsa public cert (signed public key)
# @param ed25519_private_key
#   legacy host key management
# @param ed25519_public_key
#   ed25519 public key
# @param ed25519_public_cert
#   ed25519 public cert (signed public key)
# @param ssh_authorized_keys
#   hash of ssh_authorized_key resources to create
# @param sshkeys
#   ssh public keys to place in known hosts file, similar in structure to sshkey resource but supports markers
# @param supported_key_types
#   list of key types supported (or desired) for host keys and known hosts
# @param services
#   list of services to start, enable, etc.
# @param packages
#   list of packages to install for the openssh server and client
# @param service_ensure
#   running, stopped or undefined
# @param service_enable
#   enable the service or not
# @param type_to_type
#   map used to turn full ssh key types into short names (ssh-rsa => rsa), used internally do not modify
# @example
#   include openssh
# @example README
#   see the README for more complete examples
class openssh
(
  # internal use only, defined in global.yaml
  Hash[String,String] $type_to_type,
  # hash of ssh_config resources
  Hash $ssh_config = {},
  # hash of sshd_config resources
  Hash $sshd_config= {},
  Stdlib::Absolutepath $ssh_etc = '/etc/ssh',
  Optional[Stdlib::Absolutepath] $sshd_config_path = undef,
  Optional[Stdlib::Absolutepath] $ssh_config_path = undef,
  Boolean $manage_known_hosts = false,
  Stdlib::Absolutepath $known_hosts_path = '/etc/ssh/ssh_known_hosts',
  Optional[Array[String]] $packages,
  # mode and group for ssh private keys
  Stdlib::Filemode $private_key_mode = '0600',
  Variant[String,Integer] $private_key_owner = 'root',
  Variant[String,Integer] $private_key_group = 0,
  Stdlib::Absolutepath $banner_path = '/etc/banner',
  Optional[String] $banner = undef,
  # private and public keys
  Variant[String,Undef] $rsa_private_key = undef,
  Variant[String,Undef] $rsa_public_cert = undef,
  Variant[String,Undef] $rsa_public_key = undef,
  Variant[String,Undef] $dsa_private_key = undef,
  Variant[String,Undef] $dsa_public_key = undef,
  Variant[String,Undef] $dsa_public_cert = undef,
  Variant[String,Undef] $ecdsa_private_key = undef,
  Variant[String,Undef] $ecdsa_public_key = undef,
  Variant[String,Undef] $ecdsa_public_cert = undef,
  Variant[String,Undef] $ed25519_private_key = undef,
  Variant[String,Undef] $ed25519_public_key = undef,
  Variant[String,Undef] $ed25519_public_cert = undef,
  Hash $ssh_authorized_keys = {},
  Hash[String,Struct[{
    'host_aliases' => Optional[Array[String]],
    'type'         => Enum[
      'ssh-dss',
      'ssh-rsa',
      'ecdsa-sha2-nistp256',
      'ecdsa-sha2-nistp384',
      'ecdsa-sha2-nistp521',
      'ssh-ed25519',
    ],
    'tag'          => Optional[
      Enum[
        'ssh-dss',
        'ssh-rsa',
        'ecdsa-sha2-nistp256',
        'ecdsa-sha2-nistp384',
        'ecdsa-sha2-nistp521',
        'ssh-ed25519',
      ]
    ],
    'key'          => String,
    'ensure'       => Optional[Enum['present','absent']],
    'marker'       => Optional[Enum['cert-authority','revoked']],
  }]] $sshkeys = {},
  Array[Enum[
    'rsa',
    'dsa',
    'ecdsa',
    'ed25519',
  ]] $supported_key_types = ['rsa','dsa','ecdsa','ed25519'],
  Array[String] $services = ['sshd'],
  Variant[Enum['running','stopped'],Undef] $service_ensure = 'running',
  Variant[Boolean,Undef] $service_enable = true,
)
{
  contain openssh::install
  contain openssh::config
  contain openssh::service
  contain openssh::known_hosts
  contain openssh::ssh_config
  contain openssh::authorized_keys
  Class['::openssh::install']
  -> Class['::openssh::known_hosts']
  -> Class['::openssh::config']
  ~> Class['::openssh::service']
  include openssh::ssh_config
  include openssh::authorized_keys
}
