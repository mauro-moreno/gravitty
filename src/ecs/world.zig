const std = @import("std");

pub const Entity = struct {
    id: u32,
    gen: u32,
};

const ComponentDesc = struct {
    tid: u64,
    size: usize,
    // align
    al: u29,
    // Typed column ops
    append_copy: *const fn (col: *std.ArrayList(u8), value_ptr: *const anyopaque, gpa: std.mem.Allocator) anyerror!void,
    swap_remove: *const fn (col: *std.ArrayList(u8), index: usize) void,
};

const Archetype = struct {
    key: std.AutoHashMapUnmanaged(u64, void), // set of component type ids
    // For iteration order we keep parallel arrays
    tids: std.ArrayList(u64),
    descs: std.ArrayList(ComponentDesc),
    columns: std.ArrayList(std.ArrayList(u8)), // raw byte columns
    entities: std.ArrayList(Entity),

    fn init() Archetype {
        return .{
            .key = .{},
            .tids = .{},
            .descs = .{},
            .columns = .{},
            .entities = .{},
        };
    }

    fn deinit(self: *Archetype, gpa: std.mem.Allocator) void {
        var i: usize = 0;
        while (i < self.columns.items.len) : (i += 1) self.columns.items[i].deinit(gpa);
        self.key.deinit(gpa);
        self.tids.deinit(gpa);
        self.descs.deinit(gpa);
        self.columns.deinit(gpa);
        self.entities.deinit(gpa);
    }

    fn matches(self: *const Archetype, tids: []const u64) bool {
        // return true if this archetype contains all tids
        var ok = true;
        for (tids) |tid| {
            ok = ok and (self.key.contains(tid));
            if (!ok) return false;
        }
        return true;
    }
};

pub const World = struct {
    gpa: std.mem.Allocator,
    next_id: u32,
    freelist: std.ArrayList(Entity),

    // archetypes keyed by sorted tids hash
    arch_by_sig: std.AutoHashMap(u64, usize),
    arches: std.ArrayList(Archetype),

    pub fn init(gpa: std.mem.Allocator) !World {
        var w: World = .{
            .gpa = gpa,
            .next_id = 1,
            .freelist = .{},
            .arch_by_sig = std.AutoHashMap(u64, usize).init(gpa),
            .arches = .{},
        };
        
        // empty archetype
        const empty_idx = try w.addOrGetArchetype(&[_]u64{});
        _ = empty_idx;

        return w;
    }

    pub fn deinit(self: *World) void {
        for (self.arches.items) |*a| a.deinit(self.gpa);
        self.arches.deinit();
        self.arch_by_sig.deinit();
        self.freelist.deinit(self.gpa);
    }

    pub fn spawn(self: *World) Entity {
        if (self.freelist.pop()) |e| {
            return e;
        }
        const e: Entity = .{ .id = self.next_id, .gen = 1 };
        self.next_id += 1;
        
        return e;
    }

    fn sigHash(tids_sorted: []const u64) u64 {
        var h: u64 = 1469598103934665603;
        for (tids_sorted) |tid| h = std.hash.Fnv1a_64.hash(std.mem.asBytes(&tid));
        return h;
    }

    fn addOrGetArchetype(self: *World, tids_in: []const u64) !usize {
        // copy and sort tids for canonical signature
        const tids = try self.gpa.alloc(u64, tids_in.len);
        defer self.gpa.free(tids);
        
        @memcpy(tids, tids_in);
        std.sort.pdq(u64, tids, {}, std.sort.asc(u64));
        const sig = sigHash(tids);
        if (self.arch_by_sig.get(sig)) |idx| return idx;
    }

    pub fn add(self: *World, e: Entity, comptime T: type, value: T) !void {
        // Move entity from current archetype to one with +T
        var src_idx: usize = 0;
        var src_pos: usize = 0;
        // Find entity (linear scan)
        for (self.arches.items, 0..) |*a, ai| {
            for (a.entities.items, 0..) |en, ei| {
                if (en.id == e.id and en.gen == e.gen) { src_idx = ai; src_pos = ei; break;}
            }
        }
        _ = &self.arches.items[src_idx];
        _ = value;
    }
};
