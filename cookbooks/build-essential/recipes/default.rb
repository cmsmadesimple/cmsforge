#
# Cookbook Name:: build-essential
# Recipe:: default
#
# Copyright 2008-2009, Opscode, Inc.
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

case node['platform']
when "ubuntu","debian"
  %w{build-essential wget ssl-cert libreadline6 libreadline6-dev openssl libssl-dev zlib1g zlib1g-dev libyaml-dev}.each do |pkg|
    package pkg do
      action :install
    end
  end
end

package "autoconf" do
  action :install
end

package "flex" do
  action :install
end

package "bison" do
  action :install
end

package "git" do
  action :install
end

package "libxml2-dev" do
  action :install
end

package "libxslt-dev" do
  action :install
end

package "vim" do
  action :install
end
