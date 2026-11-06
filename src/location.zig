const std = @import("std");

pub const Location = struct {
    name: []const u8,
    description: []const u8,
    paths: std.ArrayList(*Location) = .empty,

    pub fn init(name: []const u8, description: []const u8) Location {
        return .{ .name = name, .description = description };
    }
};
