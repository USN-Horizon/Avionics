const std = @import("std");
const Io = std.Io;
const fatal = std.process.fatal;
const builtin = @import("builtin");
const SerialPort = @import("SerialPort.zig");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const arena = init.arena.allocator();
    const args = try init.minimal.args.toSlice(arena);

    var fi = SerialPort.fileIterator();
    while (fi.next(io)) |r| switch (r) {
        .opened => break,
        .denied => std.log.info("Skip {s}: Permission denied", .{fi.path()}),
        .unexpected => std.log.err("Skip {s}: {t}", .{ fi.path(), fi.err.? }),
    } else fatal("No valid serial ports were found", .{});

    const baud: SerialPort.BaudRate = .@"115200";
    std.log.info("Connecting to {s} with baud rate {t}", .{ fi.path(), baud });

    var sp: SerialPort = try .init(fi.file.?, baud);
    defer sp.deinit(io);

    if (args.len <= 1) {
        var rbuf: [128]u8 = undefined;
        var wbuf: [128]u8 = undefined;
        var reader = sp.file.reader(io, &rbuf);
        var writer = Io.File.stdout().writer(io, &wbuf);
        while (true) {
            _ = reader.interface.stream(&writer.interface, .unlimited) catch |err| switch (err) {
                error.EndOfStream => {
                    std.log.info("Connection closed", .{});
                    return;
                },
                error.ReadFailed => switch (reader.err.?) {
                    error.Unexpected => {
                        // returns INVALID_DEVICE_STATE when arduino is restarted..
                        // and when usb is unplugged
                        // should this error maybe not be unexpected by zig? i could modify std?
                        std.log.info("Unexpected error, device most likely disconnected", .{});
                        return;
                    },
                    else => |e| return e,
                },
                else => return err,
            };
            try writer.interface.flush();
        }
        comptime unreachable;
    }
    const filepath = args[1];
    _ = filepath;
}
