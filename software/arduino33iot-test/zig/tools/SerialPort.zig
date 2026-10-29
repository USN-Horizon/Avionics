const std = @import("std");
const Io = std.Io;
const builtin = @import("builtin");
const SerialPort = @This();
const os_tag: enum { windows, linux, macos } = switch (builtin.target.os.tag) {
    .windows => .windows,
    .linux => .linux,
    .macos => .macos,
    else => |os| @compileError("SerialPort unimplemented for " ++ @tagName(os)),
};
// TODO: Windows serial port waits until buffer is full until a read returns.
// one solution is to use a 1 byte buffer
// or i could implement a non-blocking version.. which makes sense.
//
// might need to be able to set RTS and DTR pins? (virtually)

file: Io.File,

pub const BaudRate = enum(u32) {
    @"9600" = 9600,
    @"115200" = 115200,
};

pub fn fileIterator() FileIterator {
    return .{
        .path_buf = undefined,
        .path_len = 0,
        .file = null,
        .index = 0,
        .err = null,
    };
}

const FileIterator = struct {
    path_buf: [512]u8,
    path_len: usize,
    file: ?Io.File,
    index: u8,
    // set when next() returns unexpected
    err: ?Io.File.OpenError,

    pub fn path(fi: *const FileIterator) []const u8 {
        return fi.path_buf[0..fi.path_len];
    }

    fn pathPrint(fi: *FileIterator, comptime fmt: []const u8, args: anytype) void {
        const slc = std.mem.print(&fi.path_buf, fmt, args) catch unreachable;
        fi.path_len = slc.len;
    }

    pub fn next(fi: *FileIterator, io: Io) ?enum { opened, denied, unexpected } {
        if (fi.file) |f| {
            f.close(io);
            fi.file = null;
        }
        if (fi.err) |_| fi.err = null;

        while (true) {
            switch (os_tag) {
                .linux => {
                    if (fi.index > 0) return null;
                    defer fi.index += 1;
                    fi.pathPrint("/dev/ttyACM0", .{});
                },
                .macos => @compileError("Macos unimplemented"),
                .windows => {
                    // COM port enumeration:
                    // https://stackoverflow.com/a/1388977
                    if (fi.index > 254) return null;
                    defer fi.index += 1;
                    fi.pathPrint("\\\\.\\COM{}", .{fi.index + 1});
                },
            }
            fi.file = Io.Dir.openFileAbsolute(io, fi.path(), .{
                .mode = .read_write,
            }) catch |err| switch (err) {
                error.FileNotFound => continue,
                error.AccessDenied => return .denied,
                else => {
                    fi.err = err;
                    return .unexpected;
                },
            };
            return .opened;
        }
    }
};

// takes ownership of file
pub fn init(file: Io.File, baud_rate: BaudRate) !SerialPort {
    switch (os_tag) {
        .linux => try configureLinuxPort(file, baud_rate),
        .macos => try configureMacosPort(file, baud_rate),
        .windows => try configureWindowsPort(file, baud_rate),
    }
    return .{ .file = file };
}

pub fn deinit(sp: SerialPort, io: Io) void {
    sp.file.close(io);
}

fn configureLinuxPort(file: Io.File, baud_rate: BaudRate) !void {
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

    // set baud rate
    const rate: linux.speed_t = switch (baud_rate) {
        .@"9600" => .B9600,
        .@"115200" => .B115200,
    };

    termios.ispeed = rate;
    termios.ospeed = rate;

    if (0 != linux.ioctl(file.handle, linux.T.CSETS2, @intFromPtr(&termios)))
        return error.SetTermiosError;
}
// is probably similar to linux (but maybe using system libraries)
fn configureMacosPort(file: Io.File, baud_rate: BaudRate) !Io.File {
    _ = .{ file, baud_rate };
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

// can call os.windows.GetLastError if more specific errors are needed
fn configureWindowsPort(file: Io.File, baud_rate: BaudRate) !void {
    var dcb: DCB = .{};
    if (GetCommState(file.handle, &dcb) == .FALSE)
        return error.GetCommStateError;

    dcb.baud_rate = @backingInt(baud_rate);
    dcb.byte_size = 8;
    dcb.parity = .no;
    dcb.stop_bits = .one;

    if (SetCommState(file.handle, &dcb) == .FALSE)
        return error.SetCommStateError;

    const ct: CommTimeouts = .{
        .read_interval_timeout = 0,
        .read_total_timeout_multiplier = 0,
        .read_total_timeout_constant = 0,
        .write_total_timeout_multiplier = 0,
        .write_total_timeout_constant = 0,
    };

    if (SetCommTimeouts(file.handle, &ct) == .FALSE)
        return error.SetCommTimeoutsError;
}
