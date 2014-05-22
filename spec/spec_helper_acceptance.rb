require 'beaker-rspec'

hosts.each do |host|
  # Install Puppet
  install_package host, 'rubygems'
  install_package host, 'puppet'
  on host, "mkdir -p #{host['distmoduledir']}"
end

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module
    puppet_module_install(:source => proj_root, :module_name => 'firewall')
    puppet_module_install(:source => proj_root, :module_name => 'stdlib')
  end
end
