// THIS ANSWER WAS NOT VALIDATED

const std = @import("std");

const dbg = false;

pub fn main() !void {
    const filename: []const u8 = "input.txt";
    const out = try example(filename);
    // _ = out;
    std.debug.print("out: {d}\n", .{out});
}

fn example(filename: []const u8) !u64 {
    const file = try std.fs.cwd().openFile(filename, .{ .mode = .read_only });
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;

    const allocator = std.heap.page_allocator;

    var mapping = std.ArrayList([3]u64).init(allocator);
    defer mapping.deinit();

    var seeds = std.ArrayList(u64).init(allocator);
    defer seeds.deinit();

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (seeds.items.len == 0) {
            var it = std.mem.split(u8, line[7..], " ");
            while (it.next()) |n| {
                const seed = try std.fmt.parseInt(u64, n, 10);
                try seeds.append(seed);
            }
            continue;
        }

        if (line.len == 0) {
            continue;
        }

        if (std.mem.endsWith(u8, line, " map:")) {
            // map values
            try map_values(&seeds, &mapping);
            // release mapping
            mapping.clearAndFree();
            continue;
        }

        try parse_map(line, &mapping);
    }

    try map_values(&seeds, &mapping);

    var out: u64 = seeds.items[0];
    var i: usize = 2;
    while (i < seeds.items.len) : (i += 2) {
        if (seeds.items[i] < out) {
            out = seeds.items[i];
        }
    }

    return out;
}

fn map_values(seeds: *std.ArrayList(u64), map: *std.ArrayList([3]u64)) !void {
    if (map.items.len == 0) {
        return;
    }

    if (dbg) std.debug.print(">>>>>>{any}\n", .{seeds.items});
    if (dbg) std.debug.print("======{any}\n", .{map.items});

    var i: usize = 0;
    while (i < seeds.items.len) : (i += 2) {
        var j: usize = 0;
        while (j < map.items.len) : (j += 1) {
            if (seeds.items[i] <= map.items[j][1] + map.items[j][2] and seeds.items[i] + seeds.items[i + 1] >= map.items[j][1]) {
                // the ranges overlap
                var lower_bound = seeds.items[i];
                var original_lower_lower_bound: u64 = 0;
                var original_lower_higher_bound: u64 = 0;
                if (lower_bound < map.items[j][1]) {
                    original_lower_lower_bound = lower_bound;
                    original_lower_higher_bound = map.items[j][1] - 1;
                    lower_bound = map.items[j][1];
                }

                var higher_bound = seeds.items[i] + seeds.items[i + 1];
                var original_higher_lower_bound: u64 = 0;
                var original_higher_higher_bound: u64 = 0;
                if (higher_bound > map.items[j][1] + map.items[j][2]) {
                    original_higher_lower_bound = map.items[j][1] + map.items[j][2] + 1;
                    original_higher_higher_bound = higher_bound;
                    higher_bound = map.items[j][1] + map.items[j][2];
                }

                // std.debug.print("{d} {d} | {d} {d} {d}\n", .{ seeds.items[i], seeds.items[i + 1], map.items[j][0], map.items[j][1], map.items[j][2] });
                seeds.items[i] = lower_bound + map.items[j][0] - map.items[j][1];
                seeds.items[i + 1] = higher_bound - lower_bound;
                // std.debug.print("{d} {d}\n", .{ seeds.items[i], seeds.items[i + 1] });

                if (original_lower_lower_bound > 0) {
                    try seeds.append(original_lower_lower_bound);
                    try seeds.append(original_lower_higher_bound - original_lower_lower_bound);
                }

                if (original_higher_lower_bound > 0) {
                    try seeds.append(original_higher_lower_bound);
                    try seeds.append(original_higher_higher_bound - original_higher_lower_bound);
                }

                break;
            }
        }
    }
    if (dbg) std.debug.print("<<<<<<{any}\n", .{seeds.items});
}

fn parse_map(line: []u8, map: *std.ArrayList([3]u64)) !void {
    var it = std.mem.split(u8, line, " ");
    var i: usize = 0;
    var dest: u64 = 0;
    var source: u64 = 0;
    var range: u64 = 0;
    while (i < 3) : (i += 1) {
        const n = it.next();
        const v = try std.fmt.parseInt(u64, n.?, 10);
        if (i == 0) {
            dest = v;
        }
        if (i == 1) {
            source = v;
        }
        if (i == 2) {
            range = v;
        }
    }

    i = 0;
    try map.append([3]u64{ dest, source, range });
}

test "simple test" {
    std.debug.print("-----------\n", .{});
    const filename: []const u8 = "input2.txt";
    const out = try example(filename);
    std.debug.print("out: {d}\n", .{out});
}
