# @summary control the openssh service
#
class openssh::service {
  service { $::openssh::service:
    ensure => $::openssh::service_ensure,
    enable => $::openssh::service_enable,
  }
}
