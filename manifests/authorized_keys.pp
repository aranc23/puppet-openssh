# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include openssh::authorized_keys
class openssh::authorized_keys {
  create_resources(
    'ssh_authorized_key',
    $openssh::ssh_authorized_keys,
    { user => 'root' },
  )
}
