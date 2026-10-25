const std = @import("std");
const fatal = std.process.fatal;
const builtin = @import("builtin");

// Looked at BOSSA code while writing this
//
// TO THINK ABOUT:
// might need to be able to set RTS and DTR pins? (virtually)

const baud_rate = 9600;

// if no filepath is given, just monitor the serial port
// if filepath is given, perform the upload
// these might become separate programs...
pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const arena = init.arena.allocator();
    const args = try init.minimal.args.toSlice(arena);

    var smb: SamBa = try .open(io);

    if (args.len <= 1) {
        var rbuf: [4096]u8 = undefined;
        var wbuf: [4096]u8 = undefined;
        var reader = smb.port.reader(io, &rbuf);
        var writer = std.Io.File.stdout().writer(io, &wbuf);
        while (true) {
            _ = reader.interface.stream(&writer.interface, .unlimited) catch |err| switch (err) {
                error.EndOfStream => {
                    std.log.info("Connection closed", .{});
                    return;
                },
                else => return err,
            };
            try writer.interface.flush();
        }
        comptime unreachable;
    }
    const filepath = args[1];
    _ = filepath;

    // maybe always erase and flash? to same hardcoded location as well?
    // in bossac: flasher.erase and flasher.write
}

const SamBa = struct {
    port: std.Io.File,
    fn open(io: std.Io) !SamBa {
        return switch (builtin.target.os.tag) {
            .linux => .{ .port = try openLinuxPort(io) },
            .macos => .{ .port = try openMacPort(io) },
            .windows => .{ .port = try openWindowsPort(io) },
            else => @compileError("unsupported operating system: " ++ @tagName(builtin.target.os.tag)),
        };
    }

    fn close(s: SamBa, io: std.Io) void {
        s.file.close(io);
    }
};

fn openLinuxPort(io: std.Io) !std.Io.File {
    const path = "/dev/ttyACM0";
    const file = std.Io.Dir.openFileAbsolute(io, path, .{
        .mode = .read_write,
    }) catch |err| fatal("{t}: {s}", .{ err, path });

    std.info.log("Connecting to {s}", .{path});

    const linux = std.os.linux;
    // use termios2 so baud rate can be set..
    // This article was very useful:
    // https://blog.mbedded.ninja/programming/operating-systems/linux/linux-serial-ports-using-c-cpp/
    var termios: linux.termios2 = undefined;
    if (0 != linux.ioctl(file.handle, linux.T.CGETS2, @intFromPtr(&termios)))
        return error.GetTermiosError;

    termios.cflag.PARENB = false; // no parity bit
    termios.cflag.CSTOPB = false; // only one stop bit
    termios.cflag.CSIZE = .CS8; // eight bits size
    termios.cflag.CRTSCTS = false; // disable hardware flow control
    termios.cflag.CREAD = true; // enable reading
    termios.cflag.CLOCAL = true; // ignore signal lines (whatever that means)

    // copied from linux termbits.h, since they are not in zig-std
    const CBAUD: linux.tcflag_t = 0x0000_100f;
    const BOTHER: linux.tcflag_t = 0x0000_1000;
    // clear baud rate and make sure baud rate is read from ispeed and ospeed
    termios.cflag = @fromBackingInt(@backingInt(termios.cflag) & ~CBAUD);
    termios.cflag = @fromBackingInt(@backingInt(termios.cflag) | BOTHER);

    termios.lflag.ICANON = false; // non-canonical mode
    termios.lflag.ECHO = false; // no echo
    termios.lflag.ISIG = false; // disable signals
    termios.lflag.IEXTEN = false; // no implementation defined input processing

    // no software flow control
    termios.iflag.IXON = false;
    termios.iflag.IXOFF = false;
    termios.iflag.IXANY = false;

    // make sure we only receive raw data
    termios.iflag.IGNBRK = false;
    termios.iflag.BRKINT = false;
    termios.iflag.PARMRK = false;
    termios.iflag.ISTRIP = false;
    termios.iflag.INLCR = false;
    termios.iflag.IGNCR = false;
    termios.iflag.ICRNL = false;

    // disable implementation defined output processing (don't know what this does)
    termios.oflag.OPOST = false;

    // reads return as soon as one byte is available
    termios.cc[@backingInt(linux.V.TIME)] = 0;
    termios.cc[@backingInt(linux.V.MIN)] = 1;

    // set baud rate (can add more later)
    const rate: linux.speed_t = switch (baud_rate) {
        9600 => .B9600,
        115200 => .B115200,
        else => fatal("unsupported baud rate: {}", .{baud_rate}),
    };

    termios.ispeed = rate;
    termios.ospeed = rate;

    if (0 != linux.ioctl(file.handle, linux.T.CSETS2, @intFromPtr(&termios)))
        return error.SetTermiosError;

    return file;
}

fn openWindowsPort(io: std.Io) !std.Io.File {
    // COM port enumeration:
    // https://stackoverflow.com/a/1388977
    var path = "\\\\.\\COMx\0";
    const file = for (1..99) |n| {
        const path_len = if (n < 10) 8 else 9;
        switch (path_len) {
            8 => path[7] = '0' + n,
            9 => path[7..9].* = .{ '0' + (n / 10), '0' + (n % 10) },
            else => comptime unreachable,
        }
        break std.Io.Dir.openFileAbsolute(io, path[0..path_len], .{
            .mode = .read_write,
        }) catch |err| switch (err) {
            error.FileNotFound => {},  
            else => fatal("{t}: {s}",.{err,path}),
        });
    } else fatal("No COM port found", .{});

    std.info.log("Connecting to {s}", .{path});
    return error.RestUnimplemented;
}

// is probably similar to linux (but maybe using system libraries)
fn openMacPort(io: std.Io) !std.Io.File {
    _ = io;
    @CompileError("mac not supported yet");
}
