# == Class: selinux
#
#  This class manages SELinux on RHEL based systems.
#
# === Parameters:
#  [*mode*]
#    (enforcing|permissive|disabled)
#    sets the operating state for SELinux.
#
#  [*installmake*]
#    make is required to install modules. If you have the make package declared
#    elsewhere, you want to set this to false. It defaults to true.
#
# === Requires:
#  - [puppetlab/stdlib]
#
# == Example
#
#  include selinux
#
class selinux (
  $mode        = $selinux::params::ensure,
  $type        = $selinux::params::type,
  $installmake = $selinux::params::installmake,
) inherits selinux::params {

  file { $selinux::params::modules_dir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  include selinux::config

}
