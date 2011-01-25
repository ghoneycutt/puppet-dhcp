# Class: dhcp::cobbler
#
# For cobbler managed systems
#
class dhcp::cobbler {

    package { "dhcp": }

    service { "dhcpd":
        ensure  => running,
        enable  => true,
        require => [
            Package["dhcp"],
            File["/etc/cobbler/dhcp.template"],
        ],
    } # service
} # class dhcp::cobbler
