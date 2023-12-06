const std = @import("std");

var filename = "input.txt";
// var filename = "input2.txt";

pub fn main() !void {
    const out = try part1(filename);
    std.debug.print("{d}\n", .{out});
}

fn parseFile(fname: []const u8) ![2]u64 {
    const file = try std.fs.cwd().openFile(fname, .{ .mode = .read_only });
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());

    var buf: [1024]u8 = undefined;

    const read_amt = try buf_reader.read(&buf);
    const buf_slice = buf[0..read_amt];

    var it = std.mem.split(u8, buf_slice, "\n");
    const times_line = it.next().?;
    const distances_line = it.next().?;

    var race = [2]u64{ 0, 0 };

    var val: u64 = 0;
    var i: usize = 0;
    while (i < times_line.len) {
        if (times_line[i] >= '0' and times_line[i] <= '9') {
            val = val * 10 + @as(u64, times_line[i] - '0');
        }
        i += 1;
    }
    race[0] = val;

    val = 0;
    i = 0;
    while (i < distances_line.len) {
        if (distances_line[i] >= '0' and distances_line[i] <= '9') {
            val = val * 10 + @as(u64, distances_line[i] - '0');
        }
        i += 1;
    }
    race[1] = val;

    return race;
}

fn part1(fname: []const u8) !u64 {
    const race = try parseFile(fname);

    std.debug.print("{d}:{d}\n", .{ race[0], race[1] });

    const time = race[0];
    const dist = race[1];

    var lower_bound: u64 = 0;
    var upper_bound: u64 = 0;

    var i: usize = 0;
    while (i < time) : (i += 1) {
        const dist_traveled = i * (time - i);
        if (dist_traveled > dist) {
            lower_bound = i;
            break;
        }
    }

    i = time;
    while (i > lower_bound) : (i -= 1) {
        const dist_traveled = i * (time - i);
        if (dist_traveled > dist) {
            upper_bound = i;
            break;
        }
    }

    const winning_ways: u64 = upper_bound - lower_bound + 1;

    return winning_ways;
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
