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
#   where to put ssh configuration files (/etc/ssh)
# @param sshd_config_path
#   pull path to the sshs_config file, if undefined let the augeas provider decide
# @param ssh_config_path
#   pull path to the ssh_config file, if undefined let the augeas provider decide
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
#   legacy host key management
# @param rsa_public_key
#   legacy host key management
# @param dsa_private_key
#   legacy host key management
# @param dsa_public_key
#   legacy host key management
# @param ecdsa_private_key
#   legacy host key management
# @param ecdsa_public_key
#   legacy host key management
# @param ed25519_private_key
#   legacy host key management
# @param ed25519_public_key
#   legacy host key management
# @param ssh_authorized_keys
#   hash of ssh_authorized_key resources to create
# @param sshkeys
#   ssh public keys to place in known hosts file, similar in structure to sshkey resource but supports markers
# @param supported_key_types
#   list of key types supported (or desired) for host keys and known hosts
# @param service
#   name of the service to start, enable, etc.
# @param packages
#   list of packages to install for the openssh server and client
# @param service_ensure
#   running, stopped or undefined
# @param service_enable
#   enable the service or not
# @param type_to_type
#   map used to turn full ssh key types into short names (ssh-rsa => rsa)
# @example
#   include openssh
# @example README
#   see the README for more complete examples
class openssh
(
  # hash of ssh_config resources
  Hash $ssh_config,
  # hash of sshd_config resources
  Hash $sshd_config,
  Stdlib::Absolutepath $ssh_etc,
  Optional[Stdlib::Absolutepath] $sshd_config_path,
  Optional[Stdlib::Absolutepath] $ssh_config_path,
  Boolean $manage_known_hosts,
  Stdlib::Absolutepath $known_hosts_path,
  Optional[Array[String]] $packages,
  # mode and group for ssh private keys
  Stdlib::Filemode $private_key_mode,
  Variant[String,Integer] $private_key_owner,
  Variant[String,Integer] $private_key_group,
  Stdlib::Absolutepath $banner_path,
  Optional[String] $banner,
  # private and public keys
  Variant[String,Undef] $rsa_private_key,
  Variant[String,Undef] $rsa_public_key,
  Variant[String,Undef] $dsa_private_key,
  Variant[String,Undef] $dsa_public_key,
  Variant[String,Undef] $ecdsa_private_key,
  Variant[String,Undef] $ecdsa_public_key,
  Variant[String,Undef] $ed25519_private_key,
  Variant[String,Undef] $ed25519_public_key,
  Hash $ssh_authorized_keys,
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
  }]] $sshkeys,
  Array[Enum[
    'rsa',
    'dsa',
    'ecdsa',
    'ed25519',
  ]] $supported_key_types,
  Hash[String,String] $type_to_type,
  String $service,
  Variant[Enum['running','stopped'],Undef] $service_ensure,
  Variant[Boolean,Undef] $service_enable,
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
