const std = @import("std");
const Console = @import("console.zig").Console;
const Location = @import("location.zig").Location;
const World = @import("world.zig").World;
const Game = @import("game.zig").Game;

pub fn main(init: std.process.Init) !void {
    var output_buffer: [1024]u8 = undefined;
    var stdout_file_writer: std.Io.File.Writer = .init(.stdout(), init.io, &output_buffer);
    const stdout = &stdout_file_writer.interface;

    var input_buffer: [1024]u8 = undefined;
    var stdin_file_reader: std.Io.File.Reader = .init(.stdin(), init.io, &input_buffer);
    const stdin = &stdin_file_reader.interface;

    const arena: std.mem.Allocator = init.arena.allocator();

    const console = Console{ .stdout = stdout, .stdin = stdin };

    const game: Game = try .init(arena, init.io, console);
    try stdout.print("The player has {d} health.\n", .{game.world.player.?.health});
    try stdout.flush();
}
