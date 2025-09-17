const std = @import("std");
const grav = @import("gravitty");

const Game = struct {
    w: usize,
    h: usize,
};

fn init(ctx: *anyopaque) void {
    const g: *Game = @ptrCast(@alignCast(ctx));
    _ = g;
    grav.util.setDemoQuitAfterSeconds(20);
}

fn deinit(ctx: *anyopaque) void {
    _ = ctx;
}

fn update(ctx: *anyopaque, dt: f32) void {
    _ = ctx;
    _ = dt;
}

fn render(ctx: *anyopaque, r: *grav.renderer.Renderer) void {
    _ = ctx;
    _ = r;
}

pub fn main() !void {
    var gpa = std.heap.page_allocator;

    var g = Game{ .w = 80, .h = 24 };

    const W = g.w;
    const H = g.h;
    const N = W * H;

    const back_cells = try gpa.alloc(grav.renderer.Glyph, N);
    defer gpa.free(back_cells);
    const front_cells = try gpa.alloc(grav.renderer.Glyph, N);
    defer gpa.free(front_cells);

    const ren = try grav.renderer.Renderer.init(W, H, back_cells, front_cells, .{});
    var eng = try grav.engine.Engine.init(ren, 60);

    const cbs = grav.engine.Callbacks{ .init = init, .deinit = deinit, .update = update, .render = render };

    eng.run(cbs, &g);
    eng.deinit();
}
