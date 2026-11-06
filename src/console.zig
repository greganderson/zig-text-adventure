const std = @import("std");

pub const Console = struct {
    stdout: *std.Io.Writer,
    stdin: *std.Io.Reader,

    pub fn getInput(console: *const Console, comptime prompt: []const u8, args: anytype) ![]const u8 {
        try console.stdout.print(prompt, args);
        try console.stdout.flush();

        const result = try console.stdin.takeDelimiter('\n') orelse return error.EndOfStream;
        return std.mem.trim(u8, result, " \t\r");
    }

    pub fn getInt(console: *const Console, comptime prompt: []const u8, args: anytype) !i32 {
        while (true) {
            const result = try console.getInput(prompt, args);
            return std.fmt.parseInt(i32, result, 10) catch {
                try console.stdout.writeAll("Adventurer! You must enter a valid number!\n");
                try console.stdout.flush();
                continue;
            };
        }
    }
};
