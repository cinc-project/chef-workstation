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

# @afiune This main wrapper will be our new 'chef' binary!
#
# It will understand the entire ecosystem in the Workstation world,
# things like 'chef generate foo'  and 'chef analyze bar'
name "main-cinc-wrapper"
source path: File.join("#{project.files_path}", "../../components/main-cinc-wrapper")
license :project_license

dependency "go"

build do
  env = with_standard_compiler_flags(with_embedded_path)
  env["CGO_ENABLED"] = "0"
  env["DIST_FILE"] = "https://cinc.sh/assets/cinc-branding-dist.json"

  command "#{install_dir}/embedded/go/bin/go generate", env: env, cwd: "#{project_dir}/dist"

  if windows?
    # Windows systems requires an extention (EXE)
    command "#{install_dir}/embedded/go/bin/go build -o #{install_dir}/bin/cinc.exe", env: env

    block "Generate a 'cinc' binary that calls the 'cinc.exe' executable" do
      File.open("#{install_dir}/bin/cinc", "w") do |f|
        f.write("@ECHO OFF\n\"%~dpn0.exe\" %*")
      end
    end
  else
    # Unix systems has no extention
    command "#{install_dir}/embedded/go/bin/go build -o #{install_dir}/bin/cinc", env: env
  end
end