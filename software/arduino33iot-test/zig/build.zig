const std = @import("std");

pub fn build(b: *std.Build) !void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .thumb,
        .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_m0plus },
        .abi = .eabi, // Specifying eabi allows linking with other code using eabi?
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

    // Need to specify entry point ourselves (maybe from linker script)
    fc_exe.entry = .{ .symbol_name = "main" };

    // probably want to use a linker script to format the file how i want,
    // with the sections i want.
    // and then run this, but without the .only_section option.
    // Or maybe make the programmer handle elf-files?
    const fc_bin = fc_exe.addObjCopy(.{
        .format = .binary,
        .only_section = ".text",
    });

    const programmer_exe = b.addExecutable(.{
        .name = "programmer",
        .root_module = b.createModule(.{
            .root_source_file = b.path("tools/programmer.zig"),
            .target = b.graph.host,
        }),
    });
    b.installArtifact(programmer_exe);

    const upload_step = b.step("upload", "Upload flight computer to microcontroller");
    const upload = b.addRunArtifact(programmer_exe);
    upload.addFileArg2(fc_bin.getOutput(), .{});
    upload_step.dependOn(&upload.step);

    const monitor_step = b.step("monitor", "monitor serial port");
    const monitor = b.addRunArtifact(programmer_exe);
    monitor_step.dependOn(&monitor.step);
}
