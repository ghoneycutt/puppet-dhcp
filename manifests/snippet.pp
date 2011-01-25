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
define dhcp::snippet ( $ensure = "present", $source = undef, $content = undef, $nofile = undef ) {

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
                            require => File["${dhcp::includes}"],
                        } # file
                    } # '':
                    default: {
                        file { "${dhcp::includes}/$name.conf":
                            content => "$content",
                            require => File["${dhcp::includes}"],
                        } # file
                    } # default:
                } # case $content
            } # fi $nofile
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
} # define dhcp::snippet
