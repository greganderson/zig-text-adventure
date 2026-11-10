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

    pub fn clear(console: *const Console) !void {
        try console.stdout.writeAll("\x1b[2J\x1b[H");
        try console.stdout.flush();
    }
};

pub const Color = struct {
    pub const red = "\x1b[31m";
    pub const green = "\x1b[32m";
    pub const yellow = "\x1b[33m";
    pub const blue = "\x1b[34m";
    pub const cyan = "\x1b[36m";
    pub const reset = "\x1b[0m";
};
