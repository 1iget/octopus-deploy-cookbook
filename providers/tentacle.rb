#
# Author:: Brent Montague (<bmontague@cvent.com>)
# Cookbook Name:: octopus-deploy
# Provider:: tentacle
#
# Copyright:: Copyright (c) 2015 Cvent, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include OctopusDeploy::Shared
include OctopusDeploy::Tentacle

use_inline_resources

action :install do
  new_resource = @new_resource
  checksum = new_resource.checksum
  version = new_resource.version

  verify_version(version)
  verify_checksum(checksum)

  tentacle_installer = ::File.join(Chef::Config[:file_cache_path], 'octopus-tentacle.msi')
  install_url = installer_url(new_resource.version)

  download = remote_file tentacle_installer do
    action :create
    source install_url
    checksum checksum if checksum
  end

  install = windows_package display_name do
    action :install
    source tentacle_installer
    version version
    installer_type :msi
    options '/passive /norestart'
  end

  new_resource.updated_by_last_action(download.updated_by_last_action? || install.updated_by_last_action?)
end

action :configure do
  new_resource = @new_resource
  name = new_resource.name
  instance = new_resource.instance
  checksum = new_resource.checksum
  version = new_resource.version
  home_path = new_resource.home_path
  config_path = new_resource.config_path
  app_path = new_resource.app_path
  trusted_cert = new_resource.trusted_cert
  port = new_resource.port
  polling = fancy_bool(new_resource.polling)
  service_name = service_name(instance)

  install = octopus_deploy_tentacle name do
    action :install
    checksum checksum
    version version
  end

  configure = batch 'configure-tentacle' do
    cwd 'C:\Program Files\Octopus Deploy\Tentacle'
    code <<-EOH
      .\\Tentacle.exe create-instance --instance="#{instance}" --config="#{config_path}" --console
      .\\Tentacle.exe create-instance --instance="#{instance}" --config="#{config_path}" --console
      .\\Tentacle.exe new-certificate --instance="#{instance}" --if-blank --console
      .\\Tentacle.exe configure --instance="#{instance}" --reset-trust --console
      .\\Tentacle.exe configure --instance="#{instance}" --home="#{home_path}" --app="#{app_path}" --port="#{port}" --noListen="#{polling}" --console
      .\\Tentacle.exe configure --instance="#{instance}" --trust="#{trusted_cert}" --console
      .\\Tentacle.exe service --instance="#{instance}" --install --start --console
    EOH
    not_if { ::File.exist?(config_path) && ::Win32::Service.exists?(service_name) }
  end

  # Make sure enabled and started
  service = windows_service service_name do
    action [:enable, :start]
  end

  new_resource.updated_by_last_action(install.updated_by_last_action? || configure.updated_by_last_action? || service.updated_by_last_action?)
end

action :remove do
  new_resource = @new_resource
  version = new_resource.version

  tentacle_installer = ::File.join(Chef::Config[:file_cache_path], 'octopus-tentacle.msi')

  delete = file tentacle_installer do
    action :delete
  end

  remove = windows_package display_name do
    action :remove
    version version if version
  end

  new_resource.updated_by_last_action(remove.updated_by_last_action? || delete.updated_by_last_action?)
end

private

def verify_version(version)
  fail 'A version is required in order to install Octopus Deploy Tentacle' unless version
end

def verify_checksum(checksum)
  Chef::Log.warn 'You should include a checksum in the octopus_deploy_tentacle resource for security and performance reasons' unless checksum
end
