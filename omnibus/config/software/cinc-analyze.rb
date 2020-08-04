#
# Copyright 2019 Chef Software, Inc.
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

name "cinc-analyze"
default_version "master"
license "Apache-2.0"
license_file "LICENSE"
source git: "https://github.com/chef/chef-analyze.git"

dependency "go"

build do
  env = with_standard_compiler_flags(with_embedded_path)
  env["CGO_ENABLED"] = "0"
  env["DIST_FILE"] = "https://cinc.sh/assets/cinc-branding-dist.json"

  file_extension = windows? ? ".exe" : ""
  command "#{install_dir}/embedded/go/bin/go generate", env: env, cwd: "#{project_dir}/pkg/dist"
  command "#{install_dir}/embedded/go/bin/go build -o #{install_dir}/bin/#{name}#{file_extension}", env: env
end
