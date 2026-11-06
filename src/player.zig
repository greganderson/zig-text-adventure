const Location = @import("location.zig").Location;

pub const Player = struct {
    health: u10 = 100,
    currentLocation: *Location,

    pub fn travel(self: *Player, location: *Location) void {
        // TODO: Make sure location is an option
        self.currentLocation = location;
    }
};
