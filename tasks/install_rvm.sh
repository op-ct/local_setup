#!/bin/bash
RVM_user="${PT_rvm_user:-$USER}"
RVM_default_ruby_version="${PT_rvm_default_ruby_version:-2.5.7}"

# On CentOS7 admin needs to install
# yum install -y autoconf automake bison gcc-c++ libffi-devel libtool readline-devel ruby sqlite-devel openssl-devel

[ "${PT_install_rvm:-yes}" == yes ] || { echo "== skipping ${0}: PT_install_rvm='${PT_install_rvm}' (instead of 'yes')"; }

rvm_install_script="$(mktemp -p "$HOME" "rvm__install.XXXXX")" || { echo "ERROR: cannot make temp file for RVM install" 1>&2 ; exit 1 ; }
cat << SCRIPT_CMDS > "$rvm_install_script"
#!/bin/bash -e
# Install RVM
gpg-agent --daemon; :
gpg2 --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB

[ -f install_rvm.sh ] || curl -sSL https://get.rvm.io > install_rvm.sh
bash install_rvm.sh stable '--with-default-gems=rake'
source "\${HOME:-/home/gitlab-runner}/.rvm/scripts/rvm"
#rvm install --disable-binary "$RVM_default_ruby_version"
rvm install "$RVM_default_ruby_version"
gem install bundler --no-document
SCRIPT_CMDS

chmod +x "$rvm_install_script"
ls -l "$rvm_install_script"
cat "$rvm_install_script"

bash "$rvm_install_script"
rm -f "$rvm_install_script"
