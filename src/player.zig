const std = @import("std");
const Location = @import("location.zig").Location;

pub const Player = struct {
    name: []const u8,
    health: u10 = 100,
    currentLocation: ?*Location = null,

    pub fn travel(self: *Player, location: *Location) void {
        // TODO: Make sure location is an option
        self.currentLocation = location;
    }

    pub fn deinit(self: *Player, allocator: std.mem.Allocator) void {
        allocator.free(self.name);
    }
};
