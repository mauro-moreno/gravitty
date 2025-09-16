//! Engine loop and callbacks-deterministic fixed-step, allocation-free at
//! runtime.

const std = @import("std");
const util = @import("util.zig");
const Renderer = @import("renderer.zig").Renderer;
const assert = std.debug.assert;
const isFinite = std.math.isFinite;

pub const Callbacks = struct {
    init: fn (*anyopaque) void,
    // update: fn (*anyopaque, f32) void,
    // render: fn (*anyopaque, *renderer.Renderer) !void,
    deinit: fn (*anyopaque) void,
};

pub const Engine = struct {
    target_hz: u32 = 60,
    ren: Renderer,

    pub fn init(ren: Renderer, target_hz: u32) !Engine {
        assert(target_hz == 0 or target_hz <= 1000);
        return .{ .ren = ren, .target_hz = target_hz };
    }

    pub fn run(self: *Engine, cbs: Callbacks, user_ctx: *anyopaque) void {
        // Delta time
        const dt: f32 = 1.0 / @as(f32, @floatFromInt(self.target_hz));
        assert(isFinite(dt) and dt > 0);

        cbs.init(user_ctx);
        defer cbs.deinit(user_ctx);

        while (true) {
            if (util.shouldQuitNonBlocking()) break;
        }
    }

    pub fn deinit(self: *Engine) void {
        _ = self;
    }
};
