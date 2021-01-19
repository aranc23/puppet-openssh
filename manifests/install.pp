# @summary install packages as needed
#
class openssh::install
(
)
{
  package { $::openssh::packages:
    ensure => installed,
  }
  file { "${::openssh::ssh_etc}/validate_public_cert.sh":
    owner  => 'root',
    group  => 0,
    mode   => '0750',
    source => 'puppet:///modules/openssh/validate_public_cert.sh',
  }
}
