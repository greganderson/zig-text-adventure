const std = @import("std");
const Console = @import("console.zig").Console;
const World = @import("world.zig").World;

pub const Game = struct {
    world: *World,

    pub fn init(allocator: std.mem.Allocator, io: std.Io, console: Console) !Game {
        var world: World = .init(allocator, console);
        defer world.deinit();

        try world.initWorld(io, "src/world.json");
        return .{ .world = &world };
    }
};
