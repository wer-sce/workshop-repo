#
# Cookbook:: users
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

user 'chef' do
  password 'chef'
  action :create
end
