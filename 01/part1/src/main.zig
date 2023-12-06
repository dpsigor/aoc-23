const std = @import("std");
const File = std.fs.File;

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

pub fn run() error{OutOfMemory}!u64 {
    const filepath = "/home/dpsigor/repos/github.com/dpsigor/aoc-23/01/input.txt";
    var file = std.fs.openFileAbsolute(filepath, .{ .mode = File.OpenMode.read_only }) catch |err| {
        std.debug.print("Unable to open file: {any}\n", .{err});
        return 1;
    };
    defer file.close();

    const allocator = std.testing.allocator;
    const buf = try allocator.alloc(u8, 100000);
    const size = file.readAll(buf) catch |err| {
        std.debug.print("Failed to read file: {any}\n", .{err});
        return 1;
    };

    // split buf into lines
    var out: u64 = 0;

    var line = std.ArrayList(u8).init(allocator);
    defer line.deinit();

    for (buf[0..size]) |c| {
        if (c == '\n') {
            var first: u8 = 0;
            var last: u8 = 0;
            for (line.items) |v| {
                if (v >= '0' and v <= '9') {
                    first = v;
                    break;
                }
            }
            var i: usize = line.items.len;
            while (i > 0) {
                i -= 1;
                if (line.items[i] >= '0' and line.items[i] <= '9') {
                    last = line.items[i];
                    break;
                }
            }
            // concat first and last as a string
            out = out + (first - '0') * 10 + (last - '0');
            line.clearRetainingCapacity();
        } else {
            try line.append(c);
        }
    }

    allocator.free(buf);

    return out;
}

test "simple test" {
    const out = run() catch |err| {
        std.debug.print("Failed to run: {any}\n", .{err});
        return;
    };
    try std.testing.expectEqual(out, @as(i64, 54940));
}
