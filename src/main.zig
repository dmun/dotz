const std = @import("std");
const Dir = std.fs.Dir;
const Allocator = std.mem.Allocator;

const Attribute = enum(u8) {
    normal,
    bold,
    underlined,
    blinking,
    reversed,
    concealed,

    pub fn toAnsi(self: Attribute) u8 {
        return switch (self) {
            .normal => 0,
            .bold => 1,
            .underlined => 4,
            .blinking => 5,
            .reversed => 7,
            .concealed => 8,
        };
    }
};

const Color = enum {
    black,
    red,
    green,
    yellow,
    blue,
    magenta,
    cyan,
    white,
    default,
    reset,

    pub fn toAnsiFg(self: Color) u8 {
        return switch (self) {
            .black => 30,
            .red => 31,
            .green => 32,
            .yellow => 33,
            .blue => 34,
            .magenta => 35,
            .cyan => 36,
            .white => 37,
            .default => 39,
            .reset => 0,
        };
    }

    pub fn toAnsiBg(self: Color) u8 {
        return switch (self) {
            .black => 40,
            .red => 41,
            .green => 42,
            .yellow => 43,
            .blue => 44,
            .magenta => 45,
            .cyan => 46,
            .white => 47,
            .default => 49,
            .reset => 0,
        };
    }
};

const Config = struct {
    fg: Color = .default,
    bg: Color = .default,
    attr: Attribute = .normal,
    pub fn bruh() void {}
};

fn concat(allocator: Allocator, a: []const u8, b: []const u8) ![]u8 {
    const result = try allocator.alloc(u8, a.len + b.len);
    @memcpy(result[0..a.len], a);
    @memcpy(result[a.len..], b);
    return result;
}

fn fmt(allocator: Allocator, str: []const u8, config: Config) []const u8 {
    return std.fmt.allocPrint(allocator, "\u{001b}[{d};{d};{d}m{s}\u{001b}[0m", .{
        config.attr.toAnsi(),
        config.fg.toAnsiFg(),
        config.bg.toAnsiBg(),
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
