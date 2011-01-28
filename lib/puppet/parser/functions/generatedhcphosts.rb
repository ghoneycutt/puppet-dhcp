module Puppet::Parser::Functions
  newfunction(:generatedhcphosts, :type => :rvalue ) do |args|
    Facter::Util::Resolution.exec("/bin/bash /tmp/dhcp/generate_hosts.sh /tmp/dhcp/1.2.3.0")
  end
end
