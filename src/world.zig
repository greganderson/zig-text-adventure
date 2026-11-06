// Memory ownership for locations should live here
// Also include a collection of all the locations so I can free each one exactly once in the deinit function
// errdefer is a thing, use that when creating a new location. addLocation -> allocation the location, allocate the edges slice, add location to the collection of locations, then finally return. If any of those steps fail, release the memory.

const std = @import("std");
const Console = @import("console.zig").Console;
const Location = @import("location.zig").Location;

pub const World = struct {
    allocator: std.mem.Allocator,
    locations: std.ArrayList(*Location),
    console: Console,

    pub fn init(allocator: std.mem.Allocator, console: Console) World {
        return .{ .allocator = allocator, .locations = .empty, .console = console };
    }

    pub fn deinit(self: *World) void {
        for (self.locations.items) |location| {
            self.allocator.free(location.name);
            self.allocator.free(location.description);
            location.paths.deinit(self.allocator);
            self.allocator.destroy(location);
        }

        self.locations.deinit(self.allocator);
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
