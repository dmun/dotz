const std = @import("std");
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

pub fn fmt(allocator: Allocator, str: []const u8, config: Config) []const u8 {
    return std.fmt.allocPrint(allocator, "\u{001b}[{d};{d};{d}m{s}\u{001b}[0m", .{
        @intFromEnum(config.attr),
        @intFromEnum(config.fg),
        @intFromEnum(config.bg) + 10,
        str,
    }) catch str;
}
