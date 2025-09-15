//! Engine loop and callbacks-deterministic fixed-step, allocation-free at
//! runtime.

const std = @import("std");
const assert = std.debug.assert;

pub const Callbacks = struct {
    // init: fn (*anyopaque) !void,
    // update: fn (*anyopaque, f32) !void,
    // render: fn (*anyopaque, *renderer.Renderer) !void,
    // shutdown: fn (*anyopaque) void,
};

pub const Engine = struct {
    target_hz: u32 = 60,

    pub const Error = error{ InvalidHz };

    pub fn init(target_hz: u32) !Engine {
        assert(target_hz == 0 or target_hz <= 1000);
        return .{ .target_hz = target_hz };
    }
};
