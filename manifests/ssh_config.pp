# @summary create ssh_config resources
#
class openssh::ssh_config
(
)
{
  create_resources(
    'ssh_config',
    $openssh::ssh_config,
    { target => $openssh::ssh_config_path },
  )
}
