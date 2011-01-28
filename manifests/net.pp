define dhcp::net ( $dhcpnetmask="255.255.255.0" ) {

  file { "${dhcp::includes}/$name":
    content => resolvedhcpnetwork($name,$dhcpnetmask,$domain,$dhcp::filename,$ipaddress_eth1,$nameservers),
  } # file
} # define dhcp::net
