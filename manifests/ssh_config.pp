# @summary create ssh_config resources
#
# A description of what this class does
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
