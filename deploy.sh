#!/bin/bash

# Show script errors
set -eE -o functrace

APT=$(which apt)
DPKG=$(which dpkg)
FIND=$(which find)
MYLOCBASE="$HOME/tmp/i3-code"
MYREPO="$MYLOCBASE/i3-ansible"
MYREPORMT="https://github.com/bashfulrobot/i3-ansible.git"

### SCRIPT FUNCTIONS

# Check if software is installed and install with APT if needed.

function checkInstalled() {
  $DPKG -s "$1" 2>/dev/null >/dev/null || sudo $APT -y install "$1"
}
# Ansible Deploy from local GIT repo
function deployLocal() {
  if [ ! -f "$MYYAML" ]; then
    # Get the repo if needed
    mkdir -p $MYLOCBASE
    cd $MYLOCBASE
    $GIT clone $MYREPORMT
  else
    cd $MYREPO
    # Get the latest version if exists.
    $GIT pull
  fi

  # Run ansible-pull no matter what (local dev iteration)
  sudo $ANSIBLE $MYYAML --connection=local
}

# Update APT Repos of older than 12 hours
if [ -z "$(find /var/cache/apt/pkgcache.bin -mmin -720)" ]; then
  sudo $APT update
fi

neededSoftware=(software-properties-common ansible dialog git vim-nox)

# Install Software if needed

for sw in "${neededSoftware[@]}"; do
  checkInstalled "$sw"
done

ANSIBLE=$(which ansible-playbook)
APULL=$(which ansible-pull)
GIT=$(which git)

# Configure git
$GIT config user.name bashfulrobot
$GIT config user.email dustin@bashfulrobot.com
$GIT config user.editor code

# Setup Ansible CFG
if [ ! -f $HOME/.ansible.cfg ]; then
  touch $HOME/.ansible.cfg
  echo '[defaults]' >$HOME/.ansible.cfg
  echo 'remote_tmp     = /tmp/$USER/ansible' >>$HOME/.ansible.cfg
fi

# Build Menu
HEIGHT=15
WIDTH=40
CHOICE_HEIGHT=4
BACKTITLE="Deploying ansible scripts"
TITLE="Ansible Deploy"
MENU="Choose one of the following options:"

OPTIONS=(1 "Local Repo Deploy All"
  2 "Local Repo Deploy ZSH"
  3 "Remote Repo Deploy All"
  4 "Local Repo Test Script")

CHOICE=$(dialog --clear \
  --backtitle "$BACKTITLE" \
  --title "$TITLE" \
  --menu "$MENU" \
  $HEIGHT $WIDTH $CHOICE_HEIGHT \
  "${OPTIONS[@]}" \
  2>&1 >/dev/tty)

clear

case $CHOICE in
1)
  echo "Running $MYREPO/local.yml"
  MYYAML="$MYREPO/local.yml"
  deployLocal
  ;;
2)
  echo "Running $MYREPO/local-test.yml"
  MYYAML="$MYREPO/local-test.yml"
  deployLocal
  ;;
3)
  echo "Running ansible-pull from $MYREPORMT"
  sudo $APULL -U $MYREPORMT
  ;;
4)
  echo "Running $MYREPO/local-test.yml"
  MYYAML="$MYREPO/local-test.yml"
  deployLocal
  ;;
esac

exit 0
