const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const grav = b.addLibrary(.{
        .linkage = .static,
        .name = "gravitty",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/gravitty.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    b.installArtifact(grav);

    const unit_tests = b.addTest(.{ .root_module = b.createModule(.{
        .root_source_file = b.path("src/gravitty.zig"),
        .target = target,
        .optimize = optimize,
    }) });
    const run_unit_tests = b.addRunArtifact(unit_tests);
    const test_step = b.step("test", "Run gravitty tests");
    test_step.dependOn(&run_unit_tests.step);

    // Examples
    const grav_mod = b.addModule("gravitty", .{
        .root_source_file = b.path("src/gravitty.zig"),
    });

    // Pong
    const pong = b.addExecutable(.{
        .name = "pong",
        .root_module = b.createModule(.{
            .root_source_file = b.path("examples/pong/src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    pong.root_module.addImport("gravitty", grav_mod);
    b.installArtifact(pong);

    const run_pong = b.addRunArtifact(pong);
    const run_step = b.step("run-pong", "Rung the Pong demo");
    run_step.dependOn(&run_pong.step);
}
