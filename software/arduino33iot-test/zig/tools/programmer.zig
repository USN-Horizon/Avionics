const std = @import("std");
const Io = std.Io;
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
                        // maybe there is a comm setting to avoid this.. probably not
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

    // maybe always erase and flash? to same hardcoded location as well?
    // in bossac: flasher.erase and flasher.write
}

const SamBa = struct {
    port: Io.File,
    fn open(io: Io) !SamBa {
        return switch (builtin.target.os.tag) {
            .linux => .{ .port = try openLinuxPort(io) },
            .macos => .{ .port = try openMacPort(io) },
            .windows => .{ .port = try openWindowsPort(io) },
            else => @compileError("unsupported operating system: " ++ @tagName(builtin.target.os.tag)),
        };
    }

    fn close(s: SamBa, io: Io) void {
        s.file.close(io);
    }
};

fn openLinuxPort(io: Io) !Io.File {
    const path = "/dev/ttyACM0";
    const file = Io.Dir.openFileAbsolute(io, path, .{
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
// is probably similar to linux (but maybe using system libraries)
fn openMacPort(io: Io) !Io.File {
    _ = io;
    @compileError("mac not supported yet");
}

const win = std.os.windows;

// https://learn.microsoft.com/en-us/windows/win32/api/winbase/ns-winbase-dcb
const DCB = extern struct {
    length: win.DWORD = @sizeOf(DCB),
    baud_rate: win.DWORD = 0,
    f: packed struct(win.DWORD) {
        binary: bool = false,
        parity: bool = false,
        outx_cts_flow: bool = false,
        outx_dsr_flow: bool = false,
        dtr_control: u2 = 0,
        dsr_sensitivity: bool = false,
        tx_continue_on_x_off: bool = false,
        outx: bool = false,
        inx: bool = false,
        error_char: bool = false,
        null: bool = false,
        rts_control: u2 = 0,
        abort_on_error: bool = false,
        unused: u17 = 0,
    } = .{},
    reserved1: win.WORD = 0,
    xon_lim: win.WORD = 0,
    xoff_lim: win.WORD = 0,
    byte_size: win.BYTE = 0,
    parity: enum(win.BYTE) {
        no = 0,
        odd = 1,
        even = 2,
        mark = 3,
        space = 4,
    } = .no,
    stop_bits: enum(win.BYTE) {
        one = 0,
        one_5s = 1,
        two = 2,
    } = .one,
    xon_char: c_char = 0,
    xoff_char: c_char = 0,
    error_char: c_char = 0,
    eof_char: c_char = 0,
    evt_char: c_char = 0,
    reserved2: win.WORD = 0,
};

// https://learn.microsoft.com/en-us/windows/win32/api/winbase/ns-winbase-commtimeouts
const CommTimeouts = extern struct {
    read_interval_timeout: win.DWORD,
    read_total_timeout_multiplier: win.DWORD,
    read_total_timeout_constant: win.DWORD,
    write_total_timeout_multiplier: win.DWORD,
    write_total_timeout_constant: win.DWORD,
};
extern "kernel32" fn GetCommState(handle: Io.File.Handle, dcb: *DCB) callconv(.winapi) win.BOOL;
extern "kernel32" fn SetCommState(handle: Io.File.Handle, dcb: *DCB) callconv(.winapi) win.BOOL;
extern "kernel32" fn SetCommTimeouts(handle: Io.File.Handle, ct: *const CommTimeouts) callconv(.winapi) win.BOOL;

const com_path_template = "\\\\.\\COM\x00\x00";

fn openWindowsPort(io: Io) !Io.File {
    // COM port enumeration:
    // https://stackoverflow.com/a/1388977
    var path = com_path_template.*;
    const file = for (1..99) |n| {
        const n_c: u8 = @intCast(n);
        const path_len: usize = if (n < 10) 8 else 9;
        switch (path_len) {
            8 => path[7] = '0' + n_c,
            9 => path[7..9].* = .{ '0' + (n_c / 10), '0' + (n_c % 10) },
            else => unreachable,
        }
        break Io.Dir.openFileAbsolute(io, path[0..path_len], .{
            .mode = .read_write,
        }) catch |err| switch (err) {
            error.FileNotFound => continue,
            error.AccessDenied => {
                std.log.info("Skipping {s}, since access was denied", .{path});
                continue;
            },
            else => fatal("{t}: {s}", .{ err, path }),
        };
    } else fatal("No COM port available", .{});

    std.log.info("Connecting to {s}", .{path});

    var dcb: DCB = .{};
    if (GetCommState(file.handle, &dcb) == .FALSE)
        fatal("{t}", .{win.GetLastError()});

    dcb.baud_rate = baud_rate;
    dcb.byte_size = 8;
    dcb.parity = .no;
    dcb.stop_bits = .one;

    if (SetCommState(file.handle, &dcb) == .FALSE)
        fatal("{t}", .{win.GetLastError()});

    std.debug.print("{}", .{dcb});

    // i think this stuff is the issue maybe..
    // waits until 4096 bytes are available before reading
    const ct: CommTimeouts = .{
        .read_interval_timeout = std.math.maxInt(win.DWORD),
        .read_total_timeout_multiplier = 0,
        .read_total_timeout_constant = 0,
        .write_total_timeout_multiplier = 0,
        .write_total_timeout_constant = 0,
    };

    if (SetCommTimeouts(file.handle, &ct) == .FALSE)
        fatal("{t}", .{win.GetLastError()});

    return file;
}
