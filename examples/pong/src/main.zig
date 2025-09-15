const std = @import("std");
const grav = @import("gravitty");

pub fn main() void {
    _ = try grav.engine.Engine.init(1001);
}
