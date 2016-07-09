#
# Cookbook Name:: tomcat
# Recipe:: default
#
# Copyright 2013, bageljp
#
# All rights reserved - Do Not Redistribute
#

if node['tomcat']['suffixes'].empty?
  tomcat_setup ""
else
  node['tomcat']['suffixes'].each do |suffix|
    tomcat_setup #{suffix}"
  end
end
