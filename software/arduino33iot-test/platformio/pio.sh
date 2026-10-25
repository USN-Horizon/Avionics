#!/usr/bin/env sh
# set up fhs container to make programs installed with platformio work...
# source this file to get pio in path
# 
# need this:  --expose="$HOME/.platformio/penv/bin/python=<pathtopythonbin>"
# gcc-toolchain needed since bossac (programmer software) needs libstdc++
# but when building the project, having gcc-toolchain installed makes it fail,
# since it looks in the gcc-toolchain libraries for files to use to compile.. bad..
# so gcc-toolchain needs to be removed when building..
# but included when uploading???.. whatdahell
#
# and with this, build always must run before upload

case $1 in
 "upload") 
    guix shell python gcc-toolchain \
      --container \
      --emulate-fhs \
      --network \
      --share="/dev/ttyACM0" \
      --expose="$HOME/.platformio/penv/bin/python=/gnu/store/f2ajvxpbpshgx29j9dmq2h5y053hd6g2-profile/bin/python3" \
      --share="$HOME" \
      -E PATH="$PATH:$HOME/.platformio/penv/bin/" \
      -E '.*' --  pio run -t upload
  ;;
 "build")

  guix shell python \
    --container \
    --emulate-fhs \
    --network \
    --share="/dev/ttyACM0" \
    --expose="$HOME/.platformio/penv/bin/python=/gnu/store/f2ajvxpbpshgx29j9dmq2h5y053hd6g2-profile/bin/python3" \
    --share="$HOME" \
    -E PATH="$PATH:$HOME/.platformio/penv/bin/" \
    -E '.*' -- pio run
 ;;
 *) if [ $1 ]
     then echo "unknown command $1"
     else echo "missing command"
    fi
 ;;
esac
