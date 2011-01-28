# Class: dhcp
#
# This module manages the DHCP service
#
# Requires:
#   $nameservers be an initialized array in site.pp
#
class dhcp {

  # referenced in dhcpd.conf.erb
  $includes    = "/etc/dhcp"
  # dhcp host entries generated from CMDB
  $hostsconfig = "${dhcp::includes}/hosts.conf"
  # referenced in default_snippet.erb
  $filename    = "/pxelinux.0"

  package { "dhcp": }

  file {
    "/etc/dhcpd.conf":
      content => template("dhcp/dhcpd.conf.erb"),
      notify  => Service["dhcpd"];
    "${includes}":
      ensure  => directory;
    "${hostsconfig}":
      content => generatedhcphosts(),
  } # file

  exec { "prep dhcp_include":
    command  => "echo '' > ${includes}/includes.conf",
    creates  => "${includes}/includes.conf",
    require  => File["${includes}"],
  } # exec

  service { "dhcpd":
    ensure  => running,
    enable  => true,
    require => [
      Package["dhcp"],
      File["/etc/dhcpd.conf"],
      Snippet["default"],
    ],
  } # service

  dhcp::snippet { "default":
    content => template("dhcp/default_snippet.erb"),
  } # dhcp::snippet
} # class dhcp
