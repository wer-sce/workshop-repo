#
# Cookbook:: tomcat
# Recipe:: server
#
# Copyright:: 2018, The Authors, All Rights Reserved.

package 'java-1.7.0-openjdk-devel' do
  action :install
end

group 'tomcat' do
  action :create
end

user 'tomcat' do
  action :create
  group 'tomcat'
end

remote_file '/tmp/apache-tomcat-8.5.24.tar.gz' do
  source 'http://mirror.klaus-uwe.me/apache/tomcat/tomcat-8/v8.5.24/bin/apache-tomcat-8.5.24.tar.gz'
  action :create
end

remote_file '/tmp/sample.war' do
  source 'https://github.com/johnfitzpatrick/certification-workshops/blob/master/Tomcat/sample.war'
  action :create_if_missing
end

directory '/opt/tomcat' do
  recursive true
  action :create
end

execute 'extract tomcat' do
  command 'tar xvf apache-tomcat-8*tar.gz -C /opt/tomcat --strip-components=1'
  cwd '/tmp'
  action :run
  creates '/opt/tomcat/LICENSE'
end

execute 'change group on /opt/tomcat/conf ' do
  command 'chgrp -R tomcat /opt/tomcat/conf'
  action :run
  not_if 'find /opt/tomcat/conf -group tomcat | grep tomcat'
end

execute 'change group on /opt/tomcat/bin ' do
  command 'chgrp -R tomcat /opt/tomcat/bin'
  action :run
  not_if 'find /opt/tomcat/bin -group tomcat | grep tomcat'
end

directory '/opt/tomcat/conf' do
  group 'tomcat'
  mode '770'
  action :create
end

execute 'change permisson for group on /opt/tomcat/conf/*' do
  command 'chmod g+r /opt/tomcat/conf/*'
  action :run
  not_if 'stat -c %a /opt/tomcat/conf/server.xml | grep 640'
end

execute 'change owner for certain directories' do
  command 'chown -R tomcat /opt/tomcat/webapps/ /opt/tomcat/work/ /opt/tomcat/temp/ /opt/tomcat/logs/'
  action :run
  not_if 'stat -c %U /opt/tomcat/webapps | grep tomcat'
end

template '/opt/tomcat/conf/server.xml' do
  source 'server.xml.erb'
  action :create
  notifies :restart, 'service[tomcat]', :immediately
end

template '/etc/systemd/system/tomcat.service' do
  source 'tomcat.service.erb'
  action :create
  notifies :restart, 'service[tomcat]', :immediately
end

execute 'systemctl daemon-reload' do
  command 'systemctl daemon-reload'
  action :run
end

service 'tomcat' do
  action [:enable, :start]
end
