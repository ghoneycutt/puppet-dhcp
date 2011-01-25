# Class: dhcp
#
# This module manages the DHCP service
#
class dhcp {

    package { "dhcp": }

    # referenced in dhcpd.conf.erb
    $includes = "/etc/dhcp"

    file {
        "/etc/dhcpd.conf":
            content => template("dhcp/dhcpd.conf.erb"),
            notify  => Service["dhcpd"];
        "${includes}":
            ensure  => directory;
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
