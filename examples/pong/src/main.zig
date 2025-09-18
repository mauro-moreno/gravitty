const std = @import("std");
const grav = @import("gravitty");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var world = try grav.ecs.World.init(gpa.allocator());
    defer world.deinit();

    _ = world.spawn();
}
