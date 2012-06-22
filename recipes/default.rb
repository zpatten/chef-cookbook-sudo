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

if node['authorization']['sudo']['include_sudoers_d']

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

current_users = (node['z']['users']['uids'].keys rescue Array.new)
users = node['authorization']['sudo']['users']

Chef::Log.debug("current_users:#{current_users.inspect}")

Chef::Log.debug("users.count:#{users.count}")
users.each do |user, passwordless|
  ( !current_users.include?(user) ? users.delete(user) : nil )
end
Chef::Log.debug("users.count:#{users.count}")

template "/etc/sudoers" do
  source "sudoers.erb"
  mode 0440
  owner "root"
  group (platform?("freebsd") ? "wheel" : "root")
  variables(
    :groups => node['authorization']['sudo']['groups'],
    :users => node['authorization']['sudo']['users'],
    :include_sudoers_d => node['authorization']['sudo']['include_sudoers_d']
  )
end
