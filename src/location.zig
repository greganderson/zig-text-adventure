const std = @import("std");

pub const Location = struct {
    name: []const u8,
    description: []const u8,
    paths: std.ArrayList(*Location) = .empty,

    pub fn init(name: []const u8, description: []const u8) Location {
        return .{ .name = name, .description = description };
    }

    pub fn deinit(location: *Location, allocator: std.mem.Allocator) void {
        allocator.free(location.name);
        allocator.free(location.description);
        location.paths.deinit(allocator);
    }
};
