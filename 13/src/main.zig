const std = @import("std");

pub fn main() !void {
    const out = try solution();
    // _ = out;
    std.debug.print("out {d}\n", .{out});
}

fn eqls(a: []const u8, b: []const u8) bool {
    var i: usize = 0;
    while (i <= (a.len) / 2) : (i += 1) {
        if (a[i] != b[b.len - i - 1]) {
            return false;
        }
    }
    return true;
}

const parseOutput = struct {
    max_len: u64,
    col: u64,
};

fn verticalMirror(pattern: []const u8, possible_is: *std.AutoHashMap(u64, void), impossible_is: *std.AutoHashMap(u64, void), w: usize, h: usize) !parseOutput {
    var j: usize = 0;
    while (j < h) : (j += 1) {
        var i: usize = 1;
        while (i < w) : (i += 1) {
            var k: usize = 0;
            while (k + i < w) : (k += 1) {
                const beggining_line = j * w + j;
                const a = beggining_line + k;

                var length = i;
                if (w - i - k < i) {
                    length = w - i - k;
                }

                const b = a + length;
                const c = b + length;

                const part1 = pattern[a..b];
                const part2 = pattern[b..c];

                const key = i * 100 + k;

                if (eqls(part1, part2)) {
                    if (!impossible_is.contains(key)) {
                        try possible_is.put(key, {});
                    }
                } else {
                    _ = possible_is.remove(key);
                    try impossible_is.put(key, {});
                }
            }
        }
    }

    var it2 = possible_is.keyIterator();
    var m1_key: u64 = 100000;
    var found = false;
    while (it2.next()) |item| {
        const v = item.*;
        if (v < m1_key) {
            m1_key = v;
            found = true;
        }
    }
    if (!found) {
        return parseOutput{ .max_len = 0, .col = 0 };
    }
    const m1 = m1_key % 100;
    var max_len = m1;
    if (w - m1 < m1) {
        max_len = w - m1;
    }
    return parseOutput{ .max_len = max_len, .col = m1 };
}

fn horizontalMirror(pattern: []const u8) !parseOutput {
    var max_len: u64 = 0;
    var out: u64 = 0;

    var rows_it = std.mem.split(u8, pattern, "\n");
    var rows = std.ArrayList([]const u8).init(std.heap.page_allocator);
    defer rows.deinit();
    while (rows_it.next()) |row| {
        try rows.append(row);
    }

    var i: usize = 0;
    while (i < rows.items.len - 1) : (i += 1) {
        var ok = true;
        var length = i;
        if (i * 2 + 1 >= rows.items.len) {
            length = rows.items.len - i - 1;
        }
        if (length == 0) {
            continue;
        }
        if (length < max_len) {
            break;
        }
        var k: usize = 0;
        while (k < length) : (k += 1) {
            // std.debug.print("{d} i:{d} k:{d} length:{d}\n", .{ rows.items.len, i, k, length });
            if (!std.mem.eql(u8, rows.items[i - k], rows.items[i + 1 + k])) {
                ok = false;
                break;
            }
        }
        if (ok) {
            max_len = length;
            out = i;
        }
    }

    return parseOutput{ .max_len = max_len, .col = out };
}

fn solution() !u64 {
    var out: u64 = 0;

    //  Get an allocator
    var gp = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
    defer _ = gp.deinit();
    var allocator = gp.allocator();

    // Open the file
    const file = try std.fs.cwd().openFile("input.txt", .{ .mode = .read_only });
    defer file.close();

    // Read the contents
    const stat = try file.stat();
    const file_buffer = try file.readToEndAlloc(allocator, stat.size);
    defer allocator.free(file_buffer);

    const patterns_str = std.mem.trim(u8, file_buffer, "\n");

    var possible_is = std.AutoHashMap(u64, void).init(std.heap.page_allocator);
    defer possible_is.deinit();
    var impossible_is = std.AutoHashMap(u64, void).init(std.heap.page_allocator);
    defer impossible_is.deinit();

    var it = std.mem.split(u8, patterns_str, "\n\n");
    while (it.next()) |pattern| {
        std.debug.print("-----------------\n{s}\n\n", .{pattern});
        const w = std.mem.indexOf(u8, pattern, "\n").?;
        const h = std.mem.count(u8, pattern, "\n") + 1;

        const vertical_mirror = try verticalMirror(pattern, &possible_is, &impossible_is, w, h);

        possible_is.clearAndFree();
        impossible_is.clearAndFree();

        const horizontal_mirror = try horizontalMirror(pattern);

        possible_is.clearAndFree();
        impossible_is.clearAndFree();

        std.debug.print("ver:{any} hor:{any}\n", .{ vertical_mirror, horizontal_mirror });

        if (vertical_mirror.max_len > horizontal_mirror.max_len) {
            out += vertical_mirror.col + 1;
        } else {
            out += (horizontal_mirror.col + 1) * 100;
        }
    }

    return out;
}
