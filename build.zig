const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Library module
    const gravitty_mod = b.addModule("gravitty", .{
        .root_source_file = b.path("src/lib.zig"),
    });

    // Examples

    // Bounce
    const bounce = b.addExecutable(.{
        .name = "bounce",
        .root_module = b.createModule(.{
            .root_source_file = b.path("examples/bounce/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    bounce.root_module.addImport("gravitty", gravitty_mod);

    b.installArtifact(bounce);

    const run_bounce = b.addRunArtifact(bounce);
    if (b.args) |args| run_bounce.addArgs(args);
    b.step("run-bounce", "Run the bounce example").dependOn(&run_bounce.step);

    // Tests
    const unit_tests = b.addTest(.{ .root_module = b.createModule(.{
        .root_source_file = b.path("src/lib.zig"),
        .target = target,
        .optimize = optimize,
    }) });
    unit_tests.root_module.addImport("gravitty", gravitty_mod);

    const run_tests = b.addRunArtifact(unit_tests);
    b.step("test", "Run unit tests").dependOn(&run_tests.step);
}
