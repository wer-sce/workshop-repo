#
# Cookbook:: tomcat
# Spec:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

require 'spec_helper'

describe 'tomcat::default' do
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

    it 'should include server recipe' do
      expect(chef_run).to include_recipe('tomcat::server')
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end
end
