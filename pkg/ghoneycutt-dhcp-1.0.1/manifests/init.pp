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
        "/etc/dhcp/":
            ensure  => directory;
    } # file

    exec { "prep dhcp_include":
        command  => "echo '' > /etc/dhcp/includes.conf",
        creates  => "/etc/dhcp/includes.conf",
        require  => File["/etc/dhcp/"],
    } # exec

    service { "dhcpd":
        ensure  => running,
        enable  => true,
        require => [ Package["dhcp"], File["/etc/dhcpd.conf"], Snippet["default"] ],
    } # service

    # Definition: dhcp::snippet
    #
    # add a snippet to the $include directory to be built into a config
    #
    # Parameters:   
    #   $present - present||absent, defaults to present
    #   $source  - specify a source file
    #   $content - specify content or a template
    #   $nofile  - creates an empty file named "$name.conf"
    #
    # Actions:
    #   add a snippet to the $include directory to be built into a config
    #
    # Requires:
    #   must specify at least $source or $content
    #
    # Sample Usage:
    #    snippet { "default":
    #        content => template("dhcp/default_snippet.erb"),
    #}   # snippet
    #
    define snippet ( $ensure = "present", $source = undef, $content = undef, $nofile = undef ) {
        case $ensure {
            present: {
                exec {"$ensure : $name : $origins":
                    command => "sed -i '\$iinclude \"${dhcp::includes}/$name.conf\";' ${dhcp::includes}/includes.conf",
                    unless  => "grep 'include \"${dhcp::includes}/$name.conf\"' ${dhcp::includes}/includes.conf",
                    require => Exec["prep dhcp_include"],
                } # exec

                if $nofile {
                    exec { "touch ${dhcp::includes}/$name.conf": 
                        creates => "${dhcp::includes}/$name.conf",    
                    } # exec
                } else {
                    case $content {
                        '':      {
                            file { "${dhcp::includes}/$name.conf":
                                source  => "$source",
                                require => File["/etc/dhcp/"],
                            } # file
                        } # '': 
                        default: {
                            file { "${dhcp::includes}/$name.conf":
                                content => "$content",
                                require => File["/etc/dhcp/"],
                            } # file
                        } # default:
                    } #case $content
                } #else $nofile
            } # present:
            default: {
                exec {"$ensure : $name : $origins":
                    command => "sed -i '/include ${dhcp::includes}/$name.conf/d' ${dhcp::includes}/includes.conf",
                    onlyif  => "grep 'include \"${dhcp::includes}/$name.conf\"' ${dhcp::includes}/includes.conf",
                    require => Exec["prep dhcp_include"],
                } # exec

                file { "${dhcp::includes}/$name.conf":
                    ensure => absent,
                } # file
            } # default:
        } # case $ensure
    } # define snippet

    snippet { "default":
        content => template("dhcp/default_snippet.erb"),
    } # snippet
} # class dhcp

# Class: dhcp::cobbler
#
# For cobbler managed systems
#
class dhcp::cobbler {

    package { "dhcp": }

    service { "dhcpd":
        ensure  => running,
        enable  => true,
        require => [ Package["dhcp"], File["/etc/cobbler/dhcp.template"] ],
    } # service

} # class dhcp::cobbler
