#
# Cookbook Name:: cookbook-chef-sudo
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

package "sudo" do
  action (platform?("freebsd") ? :install : :upgrade)
end

if node.authorization.sudo.include_sudoers_d

  directory "/etc/sudoers.d" do
    mode 0750
    owner "root"
    group "root"
    action :create
  end

  template "/etc/sudoers.d/README" do
    source "readme-sudoers-d.erb"
    mode 0440
    owner "root"
    group "root"
    action :create
  end

end


users = node.authorization.sudo.users.to_hash
groups = node.authorization.sudo.groups.to_hash

Chef::Log.info("SUDO Users: #{users.inspect}")
Chef::Log.info("SUDO Groups: #{groups.inspect}")

template "/etc/sudoers" do
  source "sudoers.erb"
  mode 0440
  owner "root"
  group (platform?("freebsd") ? "wheel" : "root")
  variables(
    :sudo_groups => groups,
    :sudo_users => users,
    :include_sudoers_d => node.authorization.sudo.include_sudoers_d
  )
end
