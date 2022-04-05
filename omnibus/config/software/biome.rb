#
# Copyright:: Copyright Cinc Project
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

name "biome"
license :project_license
skip_transitive_dependency_licensing true

default_version "1.6.474"
linux_sha = "4dcd9180c5e9c3b37fff91199e8a1c975b5aebb4690483c9ce721f3e3784894c"
darwin_sha = ""
windows_sha = ""

if windows?
  suffix = "windows.zip"
  sha256 = windows_sha
elsif linux?
  suffix = "linux.tar.gz"
  sha256 = linux_sha
elsif mac?
  suffix = "darwin.zip"
  sha256 = darwin_sha
else
  raise "biome dep is only available for windows, linux, and mac"
end

source url: "https://github.com/biome-sh/biome/releases/download/v#{version}/bio-#{version}-x86_64-#{suffix}",
  sha256: sha256

build do
  # "block" is needed to prevent evaluating the ruby code
  # before the project_dir contains the extracted package.
  block "Relocating biome" do
    dest = File.join(install_dir, "bin")
    # We don't just copy the bin itself because on Windows additional
    # supporting DLLs are included.
    Dir.glob("#{project_dir}/bio*").each do |f|
      copy f, dest
    end
  end
end
