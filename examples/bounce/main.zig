const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();
    const out = std.fs.File.stdout();

    // Alt buffer + hide cursor
    try out.writeAll("\x1b[?1049h\x1b[?25l\x1b[2J\x1b[H");
    defer out.writeAll("\x1b[?25h\x1b[?1049l\x1b[0m") catch {};

    const cfg = try parseArgs(alloc);
    const fps: u32 = if (cfg.fps == 0) 60 else cfg.fps;

    _ = fps;
}

const Config = struct {
    w: usize = 64,
    h: usize = 24,
    fps: u32 = 60,
    frames: u64 = 0,
    gravity: bool = true,
};

fn parseArgs(alloc: std.mem.Allocator) !Config {
    var cfg: Config = .{};
    var it = try std.process.argsWithAllocator(alloc);
    defer it.deinit();
    _ = it.next();

    while (it.next()) |arg| {
        if (std.mem.eql(u8, arg, "--fps")) {
            if (it.next()) |v| cfg.fps = try std.fmt.parseInt(u32, v, 10);
        } else {}
    }
    return cfg;
}
