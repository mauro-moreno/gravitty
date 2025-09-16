//! ASCII renderer.

const std = @import("std");
const assert = std.debug.assert;
const mul = std.math.mul;

pub const Glyph = struct {
    ch: u21 = ' ',
    fg_rgb: u24 = 0xFFFFFF,
    bg_rgb: u24 = 0x000000,
    opacity: bool = true,
};

pub const Surface = struct {
    w: usize,
    h: usize,
    cells: []Glyph,

    pub fn index(self: *const Surface, x: usize, y: usize) usize {
        return y * self.w + x;
    }
};

pub const Renderer = struct {
    back: Surface,
    front: Surface,

    comptime {
        assert(@sizeOf(Glyph) <= 16);
    }

    pub fn init(w: usize, h: usize, back_cells: []Glyph, front_cells: []Glyph, fill: Glyph) !Renderer {
        assert(w != 0 and h != 0);
        const need = try mul(usize, w, h);
        assert(back_cells.len == need and front_cells.len == need);
        assert(need > 0 and &back_cells[0] != &front_cells[0]);

        var r = Renderer{
            .back = .{ .w = w, .h = h, .cells = back_cells },
            .front = .{ .w = w, .h = h, .cells = front_cells },
        };
        r.clear(fill);
        return r;
    }

    pub fn clear(self: *Renderer, g: Glyph) void {
        @memset(self.back.cells, g);
    }
};
