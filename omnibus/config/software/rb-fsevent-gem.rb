#
# Copyright 2012-2020 Chef Software, Inc.
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

# The author built their binary against an old SDK version and signing
# only supports SDK version >= 10.9, so we must rebuild and install.

name "rb-fsevent-gem"
default_version "master"

source git: "https://github.com/thibaudgg/rb-fsevent.git"

license "Apache-2.0"
license_file "https://raw.githubusercontent.com/thibaudgg/rb-fsevent/master/LICENSE.txt"

dependency "ruby"

build do
  env = with_standard_compiler_flags(with_embedded_path)
  # Look up active sdk version.
  sdk_ver = `xcrun --sdk macosx --show-sdk-version`.strip
  # Newer versions of xcode returns a full semver so see if we have a full
  # semver and account for that.
  ver = Gem::Version.new(sdk_ver)
  if ver.canonical_segments.count < 3
    env["MACOSX_DEPLOYMENT_TARGET"] = sdk_ver
  else
    env["MACOSX_DEPLOYMENT_TARGET"] = "#{ver.canonical_segments[0]}.#{ver.canonical_segments[1]}"
  end

  # We specifically don't want to install the rb-fsevent deps into the Workstation
  # bundle because it causes dependency conflicts. But we probably need to
  # bundle install so we ensure we have rake available to run the replace_exe task.
  # After running that we build and install the gem manually while excluding
  # dependencies (so we don't bring in conflicts).
  bundle "config set --local path vendor", env: env
  bundle "install", env: env
  bundle "exec rake replace_exe", env: env, cwd: "#{project_dir}/ext"
  gem "build rb-fsevent.gemspec", env: env
  gem "install rb-fsevent-*.gem --no-document --ignore-dependencies", env: env
end
