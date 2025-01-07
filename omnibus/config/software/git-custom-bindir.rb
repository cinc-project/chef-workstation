#
# Copyright:: Chef Software, Inc.
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

# NOTE - This is a straight copy of the git.rb definition in omnibus-software
# EXCEPT we specify a custom bindir when running make. We do this because
# we only want to include the Git binaries at the end of a user's path
# when they run `chef shell-init`. This is a temporary solution until we
# shave the yak of moving ruby into /opt/chefdk/bin and putting
# /opt/chefdk/embedded/bin at the end of the user's path.
# TODO - when deleting this, also delete omnibus/config/templates/git-custom-bindir

name "git-custom-bindir"
skip_transitive_dependency_licensing true

default_version "2.43.7"

license "LGPL-2.1"
license_file "LGPL-2.1"
skip_transitive_dependency_licensing true

dependency "curl"
dependency "zlib"
dependency "openssl"
dependency "pcre"
dependency "libiconv" # FIXME: can we figure out how to remove this?
dependency "expat"

relative_path "git-#{version}"

version("2.43.7") { source sha256: "b30055b0dac1aebcb6f332f1fddbc81e3ce43819920a23709d71b4f76763f1f4" }

source url: "https://www.kernel.org/pub/software/scm/git/git-#{version}.tar.gz"
internal_source url: "https://www.kernel.org/pub/software/scm/git/git-#{version}.tar.gz"
bin_dirs ["#{install_dir}/gitbin", "#{install_dir}/embedded/libexec/git-core"]

build do
  env = with_standard_compiler_flags(with_embedded_path)

  # We do a distclean so we ensure that the autoconf files are not trying to be
  # clever.
  make "distclean"

  # In 2.13.1 they introduced some sha code that wasn't super good at endianness
  if aix?
    # AIX needs /opt/freeware/bin only for patch
    patch_env = env.dup
    patch_env["PATH"] = "/opt/freeware/bin:#{env["PATH"]}"

    patch source: "aix-endian-fix.patch", plevel: 0, env: patch_env
  end

  config_hash = {
    # Universal options
    NO_GETTEXT: "YesPlease",
    NEEDS_LIBICONV: "YesPlease",
    NO_INSTALL_HARDLINKS: "YesPlease",
    NO_PERL: "YesPlease",
    NO_PYTHON: "YesPlease",
    NO_TCLTK: "YesPlease",
  }

  if freebsd?
    config_hash["CHARSET_LIB"] = "-lcharset"
    config_hash["FREAD_READS_DIRECTORIES"] = "UnfortunatelyYes"
    config_hash["HAVE_CLOCK_GETTIME"] = "YesPlease"
    config_hash["HAVE_CLOCK_MONOTONIC"] = "YesPlease"
    config_hash["HAVE_GETDELIM"] = "YesPlease"
    config_hash["HAVE_PATHS_H"] = "YesPlease"
    config_hash["HAVE_STRINGS_H"] = "YesPlease"
    config_hash["PTHREAD_LIBS"] = "-pthread"
    config_hash["USE_ST_TIMESPEC"] = "YesPlease"
    config_hash["HAVE_BSD_SYSCTL"] = "YesPlease"
    config_hash["NO_R_TO_GCC_LINKER"] = "YesPlease"
  elsif aix?
    env["CC"] = "xlc_r"
    env["INSTALL"] = "/opt/freeware/bin/install"
    env["CFLAGS"] = "-q64 -qmaxmem=-1 -I#{install_dir}/embedded/include -D_LARGE_FILES -O2"
    env["CPPFLAGS"] = "-q64 -qmaxmem=-1 -I#{install_dir}/embedded/include -D_LARGE_FILES -O2"
    env["LDFLAGS"] = "-q64 -L#{install_dir}/embedded/lib -lcurl -lssl -lcrypto -lz -Wl,-blibpath:#{install_dir}/embedded/lib:/usr/lib:/lib"
    # xlc doesn't understand the '-Wl,-rpath' syntax at all so... we don't enable
    # the NO_R_TO_GCC_LINKER flag. This means that it will try to use the
    # old style -R for libraries and as a result, xlc will ignore it. In this case, we
    # we want that to happen because we explicitly set the libpath with the correct
    # command line argument in omnibus itself.
    config_hash["CC_LD_DYNPATH"] = "-R"
    config_hash["AR"] = "ar -X64"
    config_hash["NO_REGEX"] = "YesPlease"
  else
    # Linux things!
    config_hash["HAVE_PATHS_H"] = "YesPlease"
    config_hash["NO_R_TO_GCC_LINKER"] = "YesPlease"
  end

  # ensure that header files in git's source code are found first before looking in other directories
  # this solves an issue that occurs when libarchive has been built and installed and its archive.h header
  # file in #{install_dir}/embedded/include is accidentally picked up when compiling git
  env["CFLAGS"] = "-I. #{env["CFLAGS"]}"
  env["CPPFLAGS"] = "-I. #{env["CPPFLAGS"]}"
  env["CXXFLAGS"] = "-I. #{env["CXXFLAGS"]}"
  env["CFLAGS"] = "-std=c99 #{env["CFLAGS"]}"

  erb source: "config.mak.erb",
      dest: "#{project_dir}/config.mak",
      mode: 0755,
      vars: {
               cc: env["CC"],
               ld: env["LD"],
               cflags: env["CFLAGS"],
               cppflags: env["CPPFLAGS"],
               install: env["INSTALL"],
               install_dir: install_dir,
               ldflags: env["LDFLAGS"],
               shell_path: env["SHELL_PATH"],
               config_hash: config_hash,
             }

  #
  # NOTE - If you run ./configure the environment variables set above will not be
  # used and only the command line args will be used. The issue with this is you
  # cannot specify everything on the command line that you can with the env vars.
  make "prefix=#{install_dir}/embedded bindir=#{install_dir}/gitbin -j #{workers}", env: env
  make "prefix=#{install_dir}/embedded bindir=#{install_dir}/gitbin install", env: env
end
