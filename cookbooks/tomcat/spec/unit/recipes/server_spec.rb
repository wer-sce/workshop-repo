#
# Cookbook:: tomcat
# Spec:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

require 'spec_helper'

describe 'tomcat::server' do
  context 'When all attributes are default, on CentOS 7.4.1708' do
    let(:chef_run) do
      # for a complete list of available platforms and versions see:
      # https://github.com/customink/fauxhai/blob/master/PLATFORMS.md
      runner = ChefSpec::ServerRunner.new(platform: 'centos', version: '7.4.1708')
      runner.converge(described_recipe)
    end

    before do
      stub_command('find /opt/tomcat/conf -group tomcat | grep tomcat').and_return(false)
      stub_command('find /opt/tomcat/bin -group tomcat | grep tomcat').and_return(false)
      stub_command('stat -c %a /opt/tomcat/conf/server.xml | grep 640').and_return(false)
      stub_command('stat -c %U /opt/tomcat/webapps | grep tomcat').and_return(false)
    end

    it 'installs java-1.7.0-openjdk-devel' do
      expect(chef_run).to install_package('java-1.7.0-openjdk-devel')
    end

    it 'creates group tomcat' do
      expect(chef_run).to create_group('tomcat')
    end

    it 'creates user tomcat and adds it to the tomcat group' do
      expect(chef_run).to create_user('tomcat').with(group: 'tomcat')
    end

    it 'downloads tomcat binary to /tmp/apache-tomcat-8.5.24.tar.gz' do
      expect(chef_run).to create_remote_file('/tmp/apache-tomcat-8.5.24.tar.gz')
    end

    it 'downloads certification sample.war to /tmp/sample.war' do
      expect(chef_run).to create_remote_file_if_missing('/tmp/sample.war')
    end

    it 'creates directory /opt/tomcat' do
      expect(chef_run).to create_directory('/opt/tomcat')
    end

    it 'extracts tomcat binary' do
      expect(chef_run).to run_execute('tar xvf apache-tomcat-8*tar.gz -C /opt/tomcat --strip-components=1').with(
        cwd: '/tmp',
        creates: '/opt/tomcat/LICENSE'
      )
    end

    it 'updates group for directory /opt/tomcat/conf ' do
      expect(chef_run).to run_execute('chgrp -R tomcat /opt/tomcat/conf')
    end

    it 'updates group for directory /opt/tomcat/bin ' do
      expect(chef_run).to run_execute('chgrp -R tomcat /opt/tomcat/bin')
    end

    it 'changes permission on /opt/tomcat/conf' do
      expect(chef_run).to create_directory('/opt/tomcat/conf').with(
        mode: '770'
      )
    end

    it 'executes chmod g+r /opt/tomcat/conf/*' do
      expect(chef_run).to run_execute('chmod g+r /opt/tomcat/conf/*')
    end

    it 'executes chown -R tomcat /opt/tomcat/webapps/ /opt/tomcat/work/ /opt/tomcat/temp/ /opt/tomcat/logs/' do
      expect(chef_run).to run_execute('chown -R tomcat /opt/tomcat/webapps/ /opt/tomcat/work/ /opt/tomcat/temp/ /opt/tomcat/logs/')
    end

    it 'installs the server.xml template' do
      expect(chef_run).to create_template('/opt/tomcat/conf/server.xml')
    end

    it 'installs the systemd unit file based on a template' do
      expect(chef_run).to create_template('/etc/systemd/system/tomcat.service')
    end

    it 'executes systemctl daemon-reload' do
      expect(chef_run).to run_execute('systemctl daemon-reload')
    end

    it 'starts and enables the tomcat service' do
      expect(chef_run).to enable_service('tomcat')
      expect(chef_run).to start_service('tomcat')
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end
end
