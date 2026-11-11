#!/usr/bin/env sh
# This script is only useful on computers running the Guix System distribution of linux.
# PlatformIO needs to be installed in $HOME/.platformio for this script to function.

# It sets up a container which follows the Filesystem Hierarchy Standard
# so the programs installed with platformio can find their shared libraries.
# And then runs pio with the supplied command line arguments.
 
# need: --symlink="$HOME/.platformio/penv/bin/python3=bin/python3"
# since this is already a symlink, and symlinks are not copied into the container.
# and also symlink dfu-util since it is missing some libraries and stuff conflicts.
# also /sys/ is used by platformio to read information about usb devices
# and /dev/ is used by dfu-util

guix shell python dfu-util \
  --container \
  --emulate-fhs \
  --network \
  --pure \
  --symlink="$HOME/.platformio/penv/bin/python3=bin/python3" \
  --symlink="$HOME/.platformio/packages/tool-dfuutil/bin/dfu-util=bin/dfu-util" \
  --share="/dev/" \
  --share="/sys/" \
  --share="$HOME" \
  -E PATH="$PATH:$HOME/.platformio/penv/bin/" \
  -- pio $@
