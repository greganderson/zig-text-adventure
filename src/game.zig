const std = @import("std");
const Console = @import("console.zig").Console;
const World = @import("world.zig").World;

pub const Game = struct {
    world: *World,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, io: std.Io, console: Console) !Game {
        var world = try allocator.create(World);
        world.* = try .init(allocator, console);

        try world.initWorld(io, "src/world.json");
        return .{ .world = world, .allocator = allocator };
    }

    pub fn deinit(self: *const Game) void {
        self.world.deinit();
        self.allocator.destroy(self.world);
    }

    pub fn run(self: Game) !void {
        const welcome =
            \\Welcome to the world of Yargshire! This is a place of mystery and
            \\wonder, where monsters roam the lands, yet great treasure is to be found.
            \\
            \\Before we begin, you must choose a class. Each class has unique abilities
            \\and what you choose will determine your future.
            \\
            \\What would you like to be?
            \\    1. Warrior
            \\    2. Wizard
            \\    3. Rogue
            \\
        ;
        try self.world.console.stdout.print(welcome, .{});
        // const class_choice = try self.world.console.getInt("Choice: ", .{});
        // switch (class_choice) {
        //     1 => try self.world.console.stdout.writeAll("Warrior! A most excellent choice!\n"),
        //     2 => try self.world.console.stdout.writeAll("You did strike me as someone innate arcane abilities, I look forward to the magic you shall work!\n"),
        //     3 => try self.world.console.stdout.writeAll("Ah, a rogue...a choice reserved for those who know how to stay quiet and unseen, striking only when they are sure to hit their mark. It takes great skill to be a rogue, and I hope for your success.\n"),
        //     else => try self.world.console.stdout.writeAll("You did not pick a valid class!\n"),
        // }
        try self.world.console.stdout.flush();
    }
};
