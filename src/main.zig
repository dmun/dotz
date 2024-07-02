const std = @import("std");
const Dir = std.fs.Dir;
const Allocator = std.mem.Allocator;

const Attribute = enum(u8) {
    normal = 0,
    bold = 1,
    underlined = 4,
    blinking = 5,
    reversed = 7,
    concealed = 8,
};

const Color = enum(u8) {
    black = 30,
    red = 31,
    green = 32,
    yellow = 33,
    blue = 34,
    magenta = 35,
    cyan = 36,
    white = 37,
    default = 39,
};

const Config = struct {
    fg: Color = .default,
    bg: Color = .default,
    attr: Attribute = .normal,
};

fn concat(allocator: Allocator, a: []const u8, b: []const u8) ![]u8 {
    const result = try allocator.alloc(u8, a.len + b.len);
    @memcpy(result[0..a.len], a);
    @memcpy(result[a.len..], b);
    return result;
}

fn fmt(allocator: Allocator, str: []const u8, config: Config) []const u8 {
    return std.fmt.allocPrint(allocator, "\u{001b}[{d};{d};{d}m{s}\u{001b}[0m", .{
        @intFromEnum(config.attr),
        @intFromEnum(config.fg),
        @intFromEnum(config.bg) + 10,
        str,
    }) catch str;
}

fn getDotfilesDir() !Dir {
    return try std.fs.openDirAbsolute("/Users/david/.dotfiles", .{});
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const dir = try getDotfilesDir();
    var iter = dir.iterate();
    const writer = std.io.getStdOut().writer();
    while (try iter.next()) |entry| {
        if (entry.kind == .directory) {
            const bruh = fmt(allocator, entry.name, .{ .fg = .blue });
            try writer.print("{s}/\n", .{bruh});
        }
    }
}
