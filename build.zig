const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const lib = b.addSharedLibrary("mohui", "src/main.zig", .unversioned);
    lib.setTarget(target);
    lib.setBuildMode(mode);
    lib.install();

    const run_cmd = b.addSystemCommand(&[_][]const u8{"/Users/wombat/code/omoh/build/debug-darwin-x86_64/openmohaa.x86_64"});
    run_cmd.step.dependOn(b.getInstallStep());

    const compile_step = b.step("compile", "Compile the app");
    compile_step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
