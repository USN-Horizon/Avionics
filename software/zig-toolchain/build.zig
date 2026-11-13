const std = @import("std");

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .thumb,
        .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_m4 },
        // hard float eabi
        .abi = .eabihf,
        .os_tag = .freestanding,
    });

    const fc_exe = b.addExecutable(.{
        .name = "fc",
        .root_module = b.createModule(.{
            .root_source_file = b.path("main.zig"),
            .single_threaded = true, // specified for optimizations? maybe redundant
            .optimize = optimize,
            .target = target,
        }),
        // make sure to use llvm and llvm's linker when compiling
        // so the linker script works
        // (even though compiling for arm thumb probably always uses llvm)
        // Only until linker scripts are dead!!!
        // https://github.com/ziglang/zig/issues/25069#issuecomment-3251765888
        .use_llvm = true,
        .use_lld = true,
    });

    // entry is set in linker script
    fc_exe.entry = .disabled;
    fc_exe.setLinkerScript(b.path("linker/stm32f411ce.ld"));
    // fc_exe.bundle_compiler_rt = false;
    fc_exe.bundle_ubsan_rt = false;
    fc_exe.link_gc_sections = true;

    // can only upload binary files, not elf
    const fc_bin = fc_exe.addObjCopy(.{ .format = .binary });

    const fc_bin_install = b.addInstallBinFile(
        fc_bin.getOutput(),
        b.graph.wip_configuration.stringSlice(fc_bin.basename.unwrap().?),
    );
    b.getInstallStep().dependOn(&fc_bin_install.step);
    b.installArtifact(fc_exe);

    const emu_exe = b.addExecutable(.{
        .name = "emu",
        .root_module = b.createModule(.{
            .root_source_file = b.path("tools/emu.zig"),
            .target = b.graph.host,
        }),
    });

    const dfu_exe = b.addExecutable(.{
        .name = "dfu",
        .root_module = b.createModule(.{
            .root_source_file = b.path("tools/dfu.zig"),
            .target = b.graph.host,
        }),
    });

    const monitor_exe = b.addExecutable(.{
        .name = "monitor",
        .root_module = b.createModule(.{
            .root_source_file = b.path("tools/monitor.zig"),
            .target = b.graph.host,
        }),
    });

    const emu_step = b.step("emu", "Run flight computer in emulator");
    const run_emu = b.addRunArtifact(emu_exe);
    run_emu.addFileArg2(fc_bin.getOutput(), .{});
    emu_step.dependOn(&run_emu.step);

    // Just use dfu-utils so you can do some testing until the dfu.zig implementation is done
    _ = dfu_exe;
    const upload_step = b.step("upload", "Upload flight computer using external dfu-utils");
    // copied from flight-computer platformio file (double check if this is correct)
    const run_dfu = b.addSystemCommand(&.{ "dfu-util", "-s", "0x08000000:leave", "-D" });
    run_dfu.addFileArg2(fc_bin.getOutput(), .{});
    upload_step.dependOn(&run_dfu.step);

    const monitor_step = b.step("monitor", "monitor serial port");
    const run_monitor = b.addRunArtifact(monitor_exe);
    monitor_step.dependOn(&run_monitor.step);
}
