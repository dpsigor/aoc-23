const std = @import("std");

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try bw.flush(); // don't forget to flush!
}

fn parseqty(s: []const u8) !u16 {
    var it = std.mem.split(u8, std.mem.trimLeft(u8, s, " "), " ");
    const next = it.peek().?;
    return try std.fmt.parseUnsigned(u16, next, 10);
}

fn isColorOK(y: []const u8, max_qty: u16) bool {
    const qtd = parseqty(y) catch |err| {
        std.debug.print("unable to parse qty: {any}\n", .{err});
        return false;
    };
    if (qtd > max_qty) {
        return false;
    }
    return true;
}

pub fn banana() anyerror!i64 {
    const file = std.fs.cwd().openFile("input.txt", .{ .mode = .read_only }) catch |err| {
        std.debug.print("unable to open file: {any}\n", .{err});
        return 0;
    };
    defer file.close();
    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;

    const max_reds: i64 = 12;
    const max_greens: i64 = 13;
    const max_blues: i64 = 14;

    var out: u16 = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        // std.debug.print("line: {s}\n", .{line});

        var it = std.mem.split(u8, line, ":");
        var game_it = std.mem.split(u8, it.first(), " ");
        const next = game_it.next();
        if (next == null) {
            std.debug.print("sem next: {s}\n", .{line});
            continue;
        }

        // get game_num
        const game_num = std.fmt.parseInt(u16, game_it.rest(), 10) catch |err| {
            std.debug.print("unable to parse int: {any}\n", .{err});
            continue;
        };

        it = std.mem.split(u8, it.rest(), ";");
        var ok = true;
        while (it.next()) |x| {
            var round = std.mem.split(u8, x, ",");
            if (!ok) {
                break;
            }
            while (round.next()) |y| {
                if (std.mem.containsAtLeast(u8, y, 1, "red")) {
                    if (isColorOK(y, max_reds)) {
                        continue;
                    } else {
                        ok = false;
                        break;
                    }
                }
                if (std.mem.containsAtLeast(u8, y, 1, "green")) {
                    if (isColorOK(y, max_greens)) {
                        continue;
                    } else {
                        ok = false;
                        break;
                    }
                }
                if (std.mem.containsAtLeast(u8, y, 1, "blue")) {
                    if (isColorOK(y, max_blues)) {
                        continue;
                    } else {
                        ok = false;
                        break;
                    }
                }
            }
        }

        if (ok) {
            out += game_num;
        }
    }
    return out;
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    const resp = banana() catch |err| {
        std.debug.print("banana failed: {any}\n", .{err});
        return;
    };
    std.debug.print("out: {d}\n", .{resp});
    // try std.testing.expectEqual(@as(i64, 10), resp);
}
