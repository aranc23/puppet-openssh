# @summary calls create_resources on the ssh_authorized_keys hash
#
class openssh::authorized_keys {
  create_resources(
    'ssh_authorized_key',
    $openssh::ssh_authorized_keys,
    { user => 'root' },
  )
}
