module Puppet::Parser::Functions
  newfunction(:resolvedhcpnetwork, :type => :rvalue ) do |args|
    Facter::Util::Resolution.exec("/bin/bash /tmp/dhcp/generate_net.sh #{args[0]} #{args[1]} #{args[2]} #{args[3]} #{args[4]}")
  end
end
