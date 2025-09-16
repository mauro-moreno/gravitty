//! Helpers
const std = @import("std");

var demo_quit_after_s: f64 = -1;
var demo_start_s: f64 = 0;

pub fn nowSeconds() f64 {
    return @as(f64, @floatFromInt(std.time.milliTimestamp())) / 1000;
}

pub fn setDemoQuitAfterSeconds(seconds: f64) void {
    if (seconds > 0) {
        demo_quit_after_s = seconds;
        demo_start_s = nowSeconds();
    } else {
        demo_quit_after_s = -1;
    }
}

pub fn shouldQuitNonBlocking() bool {
    if (demo_quit_after_s > 0) {
        const elapsed = nowSeconds() - demo_start_s;
        if (elapsed >= demo_quit_after_s) return true;
    }
    return false;
}
