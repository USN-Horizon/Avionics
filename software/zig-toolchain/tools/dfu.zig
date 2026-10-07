const std = @import("std");
const fatal = std.process.fatal;

// Implementation of DFU
// (Device Firmware Upgrade) device class specification for USB.
// Allows us to set board options, and flash our program onto the microcontroller.

// Might support ELF files...

// Written while reading dfu-util source code,
// as well as the DFU specification.

// Dfu-util uses libusb as a dependency,
// this program only implements what is needed from libusb

// It should also append a dfu-suffix...

pub fn main(init: std.process.Init) !void {
    const arena = init.arena;
    const arg_it = try init.minimal.args.iterateAllocator(arena);
    defer arg_it.deinit();

    _ = arg_it.skip();
    const binpath = arg_it.next() orelse fatal("Missing argument: path to binary file ", .{});
    const addr = if (arg_it.next()) |a_str| blk: {
        break :blk std.fmt.parseInt(u32, a_str, 0) catch |err| {
            fatal("Invalid upload address: {t}", .{err});
        };
    } else fatal("Missing argument: upload address");

    //TODO:
    // 1. discover connected usb device supporting dfu
    //    (warn if more than one is found, and pick the first)?
    //    (or maybe the usb device just has to be given as an argument?)
    // 2. speak with it.
    // 3. profit???
}
