//! Engine loop and callbacks-deterministic fixed-step, allocation-free at
//! runtime.

const std = @import("std");
const util = @import("util.zig");
const Renderer = @import("renderer.zig").Renderer;
const assert = std.debug.assert;
const isFinite = std.math.isFinite;

pub const Callbacks = struct {
    init: fn (*anyopaque) void,
    update: fn (*anyopaque, f32) void,
    render: fn (*anyopaque, *Renderer) void,
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

        const MAX_ACCUM_S: f32 = 0.25;
        const MAX_STEPS_PER_TICK: u32 = 8;

        var acc: f32 = 0.0;
        var last = util.nowSeconds();

        cbs.init(user_ctx);
        defer cbs.deinit(user_ctx);

        while (true) {
            if (util.shouldQuitNonBlocking()) break;

            const now = util.nowSeconds();
            const frame_elapsed: f32 = @floatCast(@as(f64, now - last));
            last = now;

            acc += frame_elapsed;
            if (acc > MAX_ACCUM_S) acc = MAX_ACCUM_S;

            var steps: u32 = 0;
            while (acc >= dt and steps < MAX_STEPS_PER_TICK) : (steps += 1) {
                acc -= dt;
                cbs.update(user_ctx, dt);
            }

            cbs.render(user_ctx, &self.ren);
            self.ren.present();

            util.sleepMs(@intCast(1000 / self.target_hz));
        }
    }

    pub fn deinit(self: *Engine) void {
        _ = self;
    }
};
