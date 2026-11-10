const std = @import("std");
const Console = @import("console.zig").Console;
const Color = @import("console.zig").Color;
const Location = @import("location.zig").Location;
const Player = @import("player.zig").Player;
const startText = @import("title.zig").startText;

pub const World = struct {
    allocator: std.mem.Allocator,
    console: Console,
    locations: std.ArrayList(*Location),
    player: Player,

    pub fn init(allocator: std.mem.Allocator, console: Console) !World {
        try console.clear();
        try console.stdout.writeAll(startText);
        const raw_name = try console.getInput("Hello adventurer! Tell me your name so that I might properly address you: ", .{});
        const name = try allocator.dupe(u8, raw_name);
        const player: Player = .{ .name = name };

        return .{ .allocator = allocator, .locations = .empty, .console = console, .player = player };
    }

    pub fn deinit(self: *World) void {
        // Locations
        for (self.locations.items) |location| {
            location.deinit(self.allocator);
            self.allocator.destroy(location);
        }

        // Player
        self.player.deinit(self.allocator);

        // Self destruct
        self.locations.deinit(self.allocator);
    }

    pub fn initWorld(self: *World, io: std.Io, filepath: []const u8) !void {
        try self.loadWorld(io, filepath);
    }

    pub fn addLocation(self: *World, name: []const u8, description: []const u8) !void {
        const owned_name = try self.allocator.dupe(u8, name);
        errdefer self.allocator.free(owned_name);

        const owned_description = try self.allocator.dupe(u8, description);
        errdefer self.allocator.free(owned_description);

        const location = try self.allocator.create(Location);
        errdefer self.allocator.destroy(location);

        location.* = .init(owned_name, owned_description);

        try self.locations.append(self.allocator, location);
    }

    pub fn addPath(self: *World, from: []const u8, to: []const u8) !void {
        const fromLocation = self.getLocation(from) orelse return;
        const toLocation = self.getLocation(to) orelse return;
        try fromLocation.paths.append(self.allocator, toLocation);
        try toLocation.paths.append(self.allocator, fromLocation);
    }

    fn getLocation(self: *const World, name: []const u8) ?*Location {
        for (self.locations.items) |location| {
            if (std.mem.eql(u8, location.name, name)) {
                return location;
            }
        }
        return null;
    }

    pub fn loadWorld(self: *World, io: std.Io, filepath: []const u8) !void {
        const cwd: std.Io.Dir = std.Io.Dir.cwd();
        const json_data: []u8 = cwd.readFileAlloc(io, filepath, self.allocator, .limited(1024 * 1024)) catch |err| {
            try self.console.stdout.print("Error opening file {s}, error: {s}\n", .{ filepath, @errorName(err) });
            try self.console.stdout.flush();
            return err;
        };
        defer self.allocator.free(json_data);

        const parsed = std.json.parseFromSlice(WorldJson, self.allocator, json_data, .{}) catch |err| {
            try self.console.stdout.print("Got an error when loading the world: {s}\n", .{@errorName(err)});
            try self.console.stdout.flush();
            return err;
        };
        defer parsed.deinit();
        const world_content = parsed.value;

        for (world_content.locations) |location| {
            try self.addLocation(location.name, location.description);
        }

        for (world_content.paths) |path| {
            try self.addPath(path.from, path.to);
        }
    }
};

const WorldJson = struct {
    locations: []LocationJson,
    paths: []PathJson,
};

const LocationJson = struct {
    name: []const u8,
    description: []const u8,
};

const PathJson = struct {
    from: []const u8,
    to: []const u8,
};
