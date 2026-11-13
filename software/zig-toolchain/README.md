# Zig Toolchain for stm32 Flight Computer
Attempt at creating a single dependency (zig compiler) toolchain for building,
testing and emulating the flight computer software.
The flight computer software could be written in zig, c++ or c, or a combination.

It is supposed to be multi-platform (windows, linux, mac).

Focused on Stm32 microcontrollers. Specifically f411ce.

### Dependencies:
These should be available in your $PATH:
* [zig-0.17.0](https://ziglang.org/download/#release-0.17.0)
* [dfu-util](https://dfu-util.sourceforge.net/) (will be replaced later)

### Usage:
Run `zig build -l` to list possible actions (build steps), which can be executed
by running `zig build <name-of-build-step>`.


### Planned features:
- [ ] tools/emu.zig:      Emulator for flight computer (minimal arm-v8 m)
- [ ] tools/dfu.zig:      Flashing with dfu
- [ ] tools/monitor.zig:  A serial monitor
  - [x] linux
  - [ ] windows (almost)
  - [ ] mac

### Will look into:
- Compiling flight computer code written in c++ along with freeRTOS
- Fetching needed freeRTOS files using zig's package manager (or just vendoring it)


