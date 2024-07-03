const std = @import("std");
const ansi = @import("ansi.zig");
const Dir = std.fs.Dir;
const Allocator = std.mem.Allocator;

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

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const dir = try getDotfilesDir(allocator);
    const writer = std.io.getStdOut().writer();

    var iter = dir.iterate();
    while (try iter.next()) |entry| {
        switch (entry.kind) {
            .directory => {
                const dirName = ansi.fmt(allocator, entry.name, .{ .fg = .blue });
                try writer.print("{s}/\n", .{dirName});
            },
            .file => try writer.print("{s}\n", .{entry.name}),
            else => {},
        }
    }
}
