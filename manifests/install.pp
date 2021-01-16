# @summary install packages as needed
#
class openssh::install
(
)
{
  package { $::openssh::packages:
    ensure => installed,
  }
}
