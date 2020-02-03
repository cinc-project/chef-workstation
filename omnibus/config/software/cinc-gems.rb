# Copyright:: Copyright (c) 2020 Cinc Project
# License:: Apache License, Version 2.0
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

name "cinc-gems"
source path: File.join("#{project.files_path}", "../../components/gems")
license :project_license

dependency "ruby"
dependency "rubygems"

build do
  env = with_standard_compiler_flags(with_embedded_path)
  gem_dir = "#{ENV['CI_PROJECT_DIR']}/cinc-gems"

  # Use gem instal directly for various gems we patch since it's not directly
  # referenced in Gemfile and doesn't get pulled in. The order is important!
  gem "build #{gem_dir}/chef-zero/chef-zero.gemspec", env: env
  gem "install -N --ignore-dependencies #{gem_dir}/chef-zero/chef-zero*.gem", env: env
  gem "build #{gem_dir}/mixlib-install/mixlib-install.gemspec", env: env
  gem "install -N --ignore-dependencies #{gem_dir}/mixlib-install/mixlib-install*.gem", env: env
  gem "build #{gem_dir}/chef/chef-bin/chef-bin.gemspec", env: env
  gem "build #{gem_dir}/chef/chef-config/chef-config.gemspec", env: env
  gem "build #{gem_dir}/chef/chef-utils/chef-utils.gemspec", env: env
  gem "install -N --ignore-dependencies #{gem_dir}/chef/chef-utils/chef-utils*.gem", env: env
  gem "install -N --ignore-dependencies #{gem_dir}/chef/chef-config/chef-config*.gem", env: env
  gem "build #{gem_dir}/chef/chef.gemspec", env: env
  gem "install -N --ignore-dependencies #{gem_dir}/chef/chef*.gem", env: env
  gem "install -N --ignore-dependencies #{gem_dir}/chef/chef-bin/chef-bin*.gem", env: env
end
