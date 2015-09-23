#
# Author:: Brent Montague (<bmontague@cvent.com>)
# Cookbook Name:: verify-octo
# Attribute:: default
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

# Server test configuration
default['verify-octo']['server']['version'] = '3.1.1'
default['verify-octo']['server']['checksum'] = 'fb01b8b0bcab94ef3a5f9a8154faf1c4d81c9e97ce5874d80c13f64ddc93f8a1'

# Tentacle test configuration
default['verify-octo']['tentacle']['version'] = '3.1.1'
default['verify-octo']['tentacle']['checksum'] = '7c35f150f893471afa5712acf1e077bab581dfbf57dd5ce829824720b8d166c5'
