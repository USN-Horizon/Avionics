const std = @import("std");
const fatal = std.process.fatal;

// A simple Armv8-M emulator with only the Main Extension, since it is needed
// for Armv7-M compatibility.
// Simulating performance characteristics is currently not a goal.
//   But it probably should be, or at least time, so we can test if the software
//   has correct timing.
// In comments, 5 Letter uppercase words beginning with R or I are the rules
// and information identifiers from the Armv8-M Architecture Reference Manual

var mem: Memory = .{};
var regs: Registers = .reset;

/// Handles all memory writes and reads, and also address mapping
const Memory = struct {
    // TODO: determine actual size needed
    bytes: [23_000]u8 align(2) = undefined,

    // inclusive address ranges
    // 0x0000_0000 - 0x1FFF_FFFF : code
    // 0x2000_0000 - 0x3FFF_FFFF : sram
    // 0x4000_0000 - 0x5FFF_FFFF : peripheral
    // 0x6000_0000 - 0x9FFF_FFFF : external ram
    // 0xA000_0000 - 0xDFFF_FFFF : external device
    // 0xE000_0000 - 0xE00F_FFFF : PPB
    // 0xE010_0000 - 0xFFFF_FFFF : vendor_sys
    fn ptr(m: *Memory,T: type, addr: u32) *T {
        // TODO: map addresses correctly
        // also, do faults and stuff when things are incorrect
        return @ptrCast(m.bytes[addr]);
    }
};

// maybe this is memory mapped registers???
// RNFSM priority numbers start at 0 and go down to the configured min..
// They are presented as negative in documentation, but internally i represent them as unsigned.
// treat numbers as if they are negative (1 higher priority than 0)
var exception_priorities: [512]u8 = @splat(1); // TODO: find out default priority
const Exception = enum (u9) { // IFPJD at most 512 values 
    thread_mode = 0,
    reset = 1,
    nmi = 2,
    hard_fault = 3,
    mem_manage_fault = 4,
    bus_fault = 5,
    usage_fault = 6,
    // secure_fault = 7, // unsupported
    // 8-10 is reserved
    sv_call = 11,
    debug_monitor = 12,
    // 13 is reserved
    pend_sv = 14,
    sys_tick = 15,
    // the rest are generic irq's
    _,

    fn fromIrq(n: u9) Exception {
        return @enumFromInt(n + 16);
    }

    fn priority(e: Exception,pri_arr: *[512]u8) {
        return switch (e) {
            // these are non-configurable
            .reset => 4,
            .nmi => 2, // TODO: secure hard fault?? B.39 RCMTC
            .hard_fault => 1,
            else => pri_arr[@intFromEnum(e)],
        }
    } 
    
};

// programmer's model visible registers ( the others are memory mapped)
const Registers = struct {
    // general purpose
    r0: u32,
    r1: u32,
    r2: u32,
    r3: u32,
    r4: u32,
    r5: u32,
    r6: u32,
    r7: u32,
    r8: u32,
    r9: u32,
    r10: u32,
    r11: u32,
    r12: u32,
    // stack pointers
    // access active stack pointer register with .sp()
    msp: u32,
    psp: u32,
    // stack lower limit addresses (exception happens if these are passed)
    msplim: packed struct (u32) {
        reserved: u3, // RTCXN res0 (always zero?, not writable?)
        limit: u29,
    },
    psplim: packed struct (u32) {
        reserved: u3, // RTCXN res0 (always zero?, not writable?)
        limit: u29,
    },
    // link register, stores return information
    lr: u32, // r14
    // program counter, current program address
    // TODO: RJPCB if an instruction reads this register, the value read should be pc + 4...
    pc: u32, // r15
    // program status registers
    // combined: xpsr
    apsr: packed struct (u32) { // application psr
        reserved1: u16,
        ge: u4, // greater than or equal flags
        reserved2: u7,
        q: u1, // dsp overflow and saturation flag
        v: u1, // overflow flag
        c: u1, // carry or borrow flag
        z: u1, // zero flag
        n: u1, // negative flag
    },
    ipsr: packed struct (u32) { // interrupt psr
        isr_number: Exception, // exception number of current isr (interrupt service routine)
        reserved: u23,
    }, 
    // this should be ignored from software
    // always return zero on read, and always ignore writes
    epsr: packed struct (u32) { // execution psr
        reserved1: u10,
        it_ici1: u6,
        reserved2: u8,
        t: u1, // thumb state bit
        it_ici2: u2,
        reserved3: u5,
    },
    // exception mask registers
    primask: packed struct (u32) {
        pm: u1, // setting this masks all exceptions with programmable priority
        reserved: u31,
    },
    faultmask: packed struct (u32) {
        fm: u1, // setting this masks all exceptions except NMI
        reserved: u31,
    },
    // base priority mask register
    basepri: packed struct (u32) {
        basepri: u8, // used to mask all exceptions with a lower priority, 0 disables.
        reserved: u8,
        
    },
    control: packed struct (u32) {
        npriv: enum (u1) {priviliged = 0, unpriviliged = 1}, // threaded mode privilige level
        // select active stack pointer
        // in handler mode this is always main, and writes are ignored
        spsel: enum (u1) {main = 0, process = 1},
        // floating-point context active, decides if floating-point state is
        // preserved when processing an exception
        fpca: enum (u1) {inactive = 0, active = 1},
        sfpa: enum (u1) {no_state = 0, has_state = 1}, // maybe unused?
        reserved: u28,
    },

    // active stack pointer / r13
    fn sp(rs: *Registers) *u32 {
        return switch (rs.control.spsel) {
            .main => &rs.msp,
            .process => &rs.psp,
        };
    }

    // reset registers
    // during cold reset, a warm reset also happens.
    // on cold reset, registers with a defined reset value will be set to that value.
    // on warm reset, only registers with a defined warm-reset value will be reset.
    // TODO: on warm reset, TakeReset() happens (arm pseudocode): implement this
    // TODO: this all means, warm reset always happens, only need to check if cold is given
    // to decide if certain registers should be reset or not.., they
    fn resetWarm(r:*Registers) void {
        r.lr = 0xffff_ffff; // set to this because of main extension
        r.pc = undefined; // TODO: load with reset handler start address ?
    }

    fn resetCold(r: *Registers) void {
        r.resetWarm();
    }

    fn getFromIdx(r: *Registers,i: u4) *u32 {
        return switch (i) {
            0 => &r.r0,
            1 => &r.r1,
            2 => &r.r2,
            3 => &r.r3,
            4 => &r.r4,
            5 => &r.r5,
            6 => &r.r6,
            7 => &r.r7,
            8 => &r.r8,
            9 => &r.r9,
            10 => &r.r10,
            11 => &r.r11,
            12 => &r.r12,
            else => unreachable,
        };
    }
};

pub fn main(init: std.process.Init) !void {
    const arena = init.arena.allocator();
    const io = init.io;
    const args = try init.minimal.args.toSlice(arena);

    // Just load program directly.. bootloader emulation :)
    if (args.len < 2) fatal("No program supplied to emulator", .{});
    const prog_path = args[1];
    const cwd = std.Io.Dir.cwd();
    const prog = try cwd.readFile(io, prog_path, &flash_mem);
    std.debug.print("{x}", .{prog[0..2]});
}

// Executes an instruction
// and maybe also shows the 'assembly' version of it??
// if i want that, i probably also want to read the debug info...
// and i can have brief descriptions for the neumonics as well..


// SO I WANT:: one function that takes an instruction (either u16 or u32.. maybe one each..)
//   and executes it, sets the state of the emulated machine.
// something that returns the neumonic of that instruction

// executes one timestep of the emulator
// looks in the pc register, executes stuff...
fn step() void {
    const inst = mem.ptr(u16,regs.pc);
    switch (instructionLength(pc.*)) {
        .half => execHalf(pc.*),
        .full => execFull(mem.ptr(u32,regs.pc).*),
    };
}

fn execHalf(i: u16) {
    const top: packed struct(u16) {r: u10,op0 = u6} = @bitCast(i);
    switch (top.op0) {
        0b000110 => {
            // add and sub
            p: packed struct(u10) {rd: u3,rn:u3,rm:u3,s:bool} = @bitCast(top.r);
            if (s) {
                ret, overflow = @subWithOverflow();
            } else {
                ret, overflow = @addWithOverflow();
                
            }
        },
    }
}

fn instructionLength(i: u16) enum {half,full} {
    const p: packed struct(u16) {r: u11, op1: u2, op0: u3} = @bitCast(i);
    if (p.op1 != 0b00 and p.op0 == 0b111 ) return .full;
    return .half;
}

