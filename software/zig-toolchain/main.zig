pub fn main() void {
    // gpio clock enable register
    const rcc_ahb1enr: *volatile u32 = @ptrFromInt(0x4002_3830);
    const gpio_c_mode: *volatile u32 = @ptrFromInt(0x4002_0800);
    const gpio_c_odr: *volatile u32 = @ptrFromInt(0x4002_0814);

    rcc_ahb1enr.* |= (1 << 2); // enable clock
    gpio_c_mode.* |= (1 << 26); // output mode for c13
    gpio_c_odr.* = 0; // turn off all port c pins

    while (true) {
        for (0..1000000) |_| {
            asm volatile ("nop");
        }
        gpio_c_odr.* ^= (1 << 13); // toggle pin c13
    }
}

extern var _szero: u32;
extern var _ezero: u32;
extern var _sdata: u32;
extern var _edata: u32;
extern var _ldata: u32;

fn _start() void {
    const szero: [*]u8 = @ptrCast(&_szero);
    const sdata: [*]u8 = @ptrCast(&_sdata);
    const ldata: [*]u8 = @ptrCast(&_ldata);

    @memset(szero[0 .. @intFromPtr(&_ezero) - @intFromPtr(&_szero)], 0);
    @memcpy(sdata[0 .. @intFromPtr(&_edata) - @intFromPtr(&_sdata)], ldata);

    main();

    while (true) asm volatile ("nop");
}

// This is the first code that runs
export fn resetHandler() callconv(.c) void {
    _start();
}

export fn nmiHandler() callconv(.c) void {}
export fn hardFaultHandler() callconv(.c) void {}
export fn memManageHandler() callconv(.c) void {}
export fn busFaultHandler() callconv(.c) void {}
export fn usageFaultHandler() callconv(.c) void {}
export fn svCallHandler() callconv(.c) void {}
export fn debugMonitorHandler() callconv(.c) void {}
export fn pendSvHandler() callconv(.c) void {}
export fn sysTickHandler() callconv(.c) void {}

export const vectors linksection(".vectors") = [_]?*const fn () callconv(.c) void{
    // these are standard
    resetHandler,
    nmiHandler,
    hardFaultHandler,
    memManageHandler,
    busFaultHandler,
    usageFaultHandler,
    null, // unused
    null, // unused
    null, // unused
    null, // unused
    svCallHandler,
    debugMonitorHandler,
    null, // unused
    pendSvHandler,
    sysTickHandler,

    // from here: mcu specific interrupts, can be found in f411ce reference manual
};
