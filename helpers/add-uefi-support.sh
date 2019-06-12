#!/bin/bash

#### CFG

# Path to project root
PROJROOT="$HOME/tmp/i3so"
# Path to downloaded mini.iso
MINIISO="$PROJROOT/raw/mini.iso"

IMAGE_NAME="Ubuntu Mini UEFI"
IMAGE=mini-uefi.iso
BUILD="$PROJROOT/usbdisk"

#### Binaries

# Making things portable
ECHO="$(which echo)"
PRINTF="$(which printf)"
DPKGQUERY="$(which dpkg-query)"
GREP="$(which grep)"
APT="$(which apt)"

#### Colours

# black COLOR_BLACK 0
# red COLOR_RED 1
# green COLOR_GREEN 2
# yellow COLOR_YELLOW 3
# blue COLOR_BLUE 4
# magenta COLOR_MAGENTA 5
# cyan COLOR_CYAN 6
# white COLOR_WHITE 7

BLUE=$(tput setaf 4)
CYAN=$(tput setaf 6)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
NC=$(tput sgr0)

echoHeader() {
  $ECHO ""
  $PRINTF "%s \n" "$BLUE === $1 $NC"
  $ECHO ""
}

echoSubheader() {
  $ECHO ""
  $PRINTF "%s \n" "$CYAN - $1 ... $NC"
  $ECHO ""
}

echoCompledNtfy() {
  $ECHO ""
  $PRINTF "%s \n" "$GREEN $1 Completed. $NC"
  $ECHO ""
}

install-tools() {

  # Packges to install
  declare -a APTPKGS
  APTPKGS=(p7zip-full p7zip-rar xorriso isolinux)

  echoHeader "Checking SW Dependencies"
  # Don't need to loop an array, just making pretty output.
  for i in "${APTPKGS[@]}"; do

    # For each array item, check if it is installed, and install if needed.
    if [ $($DPKGQUERY -W -f='${Status}' $i 2>/dev/null | $GREP -c "ok installed") -eq 0 ]; then
      echoSubheader "Installing $i package"
      sudo $APT install $i -y
    fi

  done
  echoCompledNtfy "SW Dependencies"

  echoHeader "Cleanup Install"
  sudo $APT install -f -y
  sudo $APT autoremove -y
  echoCompledNtfy "Installation Cleanup"

}

extractISO() {
  $SEVENZ x -ousbdisk $MINIISO
  $SEVENZ x -ousbdisk $PROJROOT/usbdisk/boot/grub/efi.img
}

mkMyISO() {
cd $BUILD

# Write the installer back to an ISO
xorriso -as mkisofs \
  -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
  -c boot.cat \
  -b isolinux.bin \
  -V "$IMAGE_NAME" \
  -no-emul-boot \
  -boot-load-size 4 \
  -boot-info-table \
  -eltorito-alt-boot \
  -e boot/grub/efi.img \
  -no-emul-boot \
  -isohybrid-gpt-basdat \
  -o ../$IMAGE \
  $BUILD/.
}
#### Run it all.

# Create Project direcories if needed
[ ! -d $PROJROOT/raw ] && mkdir -p $PROJROOT/raw

# Check if the ISO was downloaded.
[ ! -f "$PROJROOT/raw/mini.iso" ] && $ECHO "Please make sure $PROJROOT/raw/mini.iso exists." && exit 1

# Go to project root
cd $PROJROOT

# Installing needed packages
install-tools

# Chicken and egg. Make installed binaries portable
SEVENZ="$(which 7z)"

# go!
extractISO && mkMyISO

exit 0
