const std = @import("std");
const ansi = @import("ansi.zig");
const Dir = std.fs.Dir;
const Allocator = std.mem.Allocator;
const eql = std.mem.eql;

const Error = error{
    NoHomeDirFound,
};

fn getDotfilesDir(allocator: Allocator) !Dir {
    var envMap = try std.process.getEnvMap(allocator);
    defer envMap.deinit();

    const home = envMap.get("HOME") orelse return error.NoHomeDirFound;

    const path = try std.fmt.allocPrint(allocator, "{s}/.dotfiles", .{home});
    return try std.fs.openDirAbsolute(path, .{});
}

const Param = enum {
    status,
    help,
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const dir = try getDotfilesDir(allocator);

    var args = std.process.args();
    _ = args.skip();
    while (args.next()) |arg| {
        const case = std.meta.stringToEnum(Param, arg) orelse .help;
        switch (case) {
            .status => try status(allocator, dir),
            .help => std.debug.print("help", .{}),
        }
    }
}

pub fn status(allocator: Allocator, dir: Dir) !void {
    const writer = std.io.getStdOut().writer();

    var iter = dir.iterate();
    while (try iter.next()) |entry| {
        switch (entry.kind) {
            .directory => {
                try writer.print("{s}/\n", .{
                    try ansi.fmt(allocator, entry.name, .{ .fg = .blue }),
                });
            },
            .file => try writer.print("{s}\n", .{entry.name}),
            else => {},
        }
    }
}
