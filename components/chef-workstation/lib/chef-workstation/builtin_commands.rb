#
# Copyright:: Copyright (c) 2018 Chef Software Inc.
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
require "chef-workstation/commands_map"

ChefWorkstation.commands do |c|
  # TODO must be a better API we can do than `top_level` and `create`
  c.top_level("target", :Target, require_path: "chef-workstation/command/target", subcommands: [
    c.create("converge", :TargetConverge, require_path: "chef-workstation/command/target_converge"),
  ])

  c.top_level("config", :Config, require_path: "chef-workstation/command/config", subcommands: [
    c.create("show", :ConfigShow, require_path: "chef-workstation/command/config_show"),
  ])
end
