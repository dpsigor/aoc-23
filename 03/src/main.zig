const std = @import("std");

fn get_symbol_positions(line: []u8) ![]bool {
    var positions: []bool = &.{};
    positions = try std.heap.page_allocator.alloc(bool, line.len);
    var i: usize = 0;
    while (i < line.len) {
        if ((line[i] < '0' or line[i] > '9') and line[i] != '.') {
            positions[i] = true;
        }
        i += 1;
    }
    return positions;
}

fn parseLine1(line: []u8, above: []bool, current: []bool, under: []bool) !u64 {
    var out: u64 = 0;
    // get numbers which has adjacent symbols
    var n: usize = 0;
    while (n < line.len) {
        if (line[n] >= '0' and line[n] <= '9') {
            var j: usize = n + 1;
            while (j < line.len) {
                if (line[j] < '0' or line[j] > '9') {
                    break;
                }
                j += 1;
            }

            var aboveOk = false;

            var i: usize = n;
            if (n > 0) {
                i = n - 1;
            }

            var limit = j;
            if (j < current.len) {
                limit = j + 1;
            }

            while (i < limit) {
                if (above[i]) {
                    aboveOk = true;
                    break;
                }
                i += 1;
            }

            var currOk = false;
            if (!aboveOk) {
                if ((n > 0 and current[n - 1]) or (j < current.len and current[j])) {
                    currOk = true;
                }
            }

            var underOk = false;
            if (!currOk and !aboveOk) {
                i = n;
                if (n > 0) {
                    i = n - 1;
                }

                while (i < limit) {
                    if (under[i]) {
                        underOk = true;
                        break;
                    }
                    i += 1;
                }
            }

            if (currOk or aboveOk or underOk) {
                const val = try std.fmt.parseInt(u64, line[n..j], 10);
                std.debug.print("val: {d}\n", .{val});
                out += val;
            }

            n = j;
        }
        n += 1;
    }
    return out;
}

const Val = struct {
    a: usize,
    b: usize,
    val: u64,
};

fn get_vals(line: []u8, positions: *std.ArrayList(Val)) !void {
    var i: usize = 0;
    while (i < line.len) {
        if (line[i] >= '0' and line[i] <= '9') {
            var j: usize = i + 1;
            while (j < line.len) {
                if (line[j] < '0' or line[j] > '9') {
                    break;
                }
                j += 1;
            }
            const val = try std.fmt.parseInt(u64, line[i..j], 10);
            try positions.append(Val{ .a = i, .b = j, .val = val });
            i = j;
        }
        i += 1;
    }
}

fn parseLine2(
    line: []u8,
    above: std.ArrayList(Val),
    current: std.ArrayList(Val),
    under: std.ArrayList(Val),
) !u64 {
    std.debug.print("-----------line: {s}\n", .{line});

    var i: usize = 0;
    var out: u64 = 0;

    var debug_a: u64 = 0;
    var debug_b: u64 = 0;

    while (i < line.len) {
        var local: u64 = 1;
        var amt: u8 = 0;
        if (line[i] == '*') {
            for (above.items) |val| {
                if (val.b - 1 >= i - 1 and val.a <= i + 1) {
                    if (debug_a > 0) {
                        debug_b = val.val;
                    } else {
                        debug_a = val.val;
                    }

                    local *= val.val;
                    amt += 1;
                    if (amt > 2) {
                        local = 0;
                        break;
                    }
                }
            }

            if (amt > 2) {
                local = 0;
                i += 1;
                continue;
            }

            for (current.items) |val| {
                if (val.b == i or val.a == i + 1) {
                    if (debug_a > 0) {
                        debug_b = val.val;
                    } else {
                        debug_a = val.val;
                    }

                    local *= val.val;
                    amt += 1;

                    if (amt > 2) {
                        local = 0;
                        break;
                    }
                }
            }

            if (amt > 2) {
                local = 0;
                i += 1;
                continue;
            }

            for (under.items) |val| {
                if (val.b - 1 >= i - 1 and val.a <= i + 1) {
                    if (debug_a > 0) {
                        debug_b = val.val;
                    } else {
                        debug_a = val.val;
                    }

                    local *= val.val;
                    amt += 1;
                    if (amt > 2) {
                        local = 0;
                        break;
                    }
                }
            }
        }

        if (amt == 2) {
            std.debug.print("{d} * {d}\n", .{ debug_a, debug_b });
            // std.debug.print("local: {d}\n", .{local});
            out += local;
        }

        debug_a = 0;
        debug_b = 0;

        i += 1;
    }

    return out;
}

pub fn main() !void {
    var out: u64 = 0;

    const file = try std.fs.cwd().openFile("input.txt", .{ .mode = .read_only });
    // const file = try std.fs.cwd().openFile("input2.txt", .{ .mode = .read_only });
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;

    // var above: []bool = undefined;
    // var current: []bool = undefined;
    // var under: []bool = undefined;

    var allocator = std.heap.page_allocator;

    var above = std.ArrayList(Val).init(allocator);
    var current = std.ArrayList(Val).init(allocator);
    var under = std.ArrayList(Val).init(allocator);

    var line: []u8 = "";

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |next_line| {
        // verify if line is uninitialized
        if (std.mem.eql(u8, line, "")) {
            // above = try allocator.alloc(bool, next_line.len);
            // current = try get_symbol_positions(next_line);
            var n_current = std.ArrayList(Val).init(allocator);
            try get_vals(next_line, &n_current);
            try current.ensureTotalCapacity(n_current.items.len);
            current.clearAndFree();
            try current.appendSlice(n_current.items);
            n_current.deinit();
            line = try allocator.alloc(u8, next_line.len);
            std.mem.copyForwards(u8, line, next_line);
            continue;
        }

        // std.debug.print("-----------line: {s}\n", .{line});

        // under = try get_symbol_positions(next_line);
        var n_under = std.ArrayList(Val).init(allocator);
        try get_vals(next_line, &n_under);
        try under.ensureTotalCapacity(n_under.items.len);
        under.clearAndFree();
        try under.appendSlice(n_under.items);
        n_under.deinit();

        // out += try parseLine1(line, above, current, under);
        out += try parseLine2(line, above, current, under);

        // above = current;
        // current = under;
        above.clearAndFree();
        try above.appendSlice(current.items);
        current.clearAndFree();
        try current.appendSlice(under.items);

        line = try allocator.alloc(u8, next_line.len);
        std.mem.copyForwards(u8, line, next_line);
    }

    // make empty have the length of above slice
    // const empty = try allocator.alloc(bool, above.len);
    const empty = std.ArrayList(Val).init(allocator);
    out += try parseLine2(line, above, current, empty);

    std.debug.print("out: {d}\n", .{out});
}

// fn get_symbol_positions_banana(line: []u8) u64 {
//     var positions: u64 = 0;
//     var i: u6 = 0;
//     while (i < line.len) {
//         if ((line[i] < '0' or line[i] > '9') and line[i] != '.') {
//             const pos = @as(u64, 1) << i;
//             positions |= pos;
//         }
//         i += 1;
//     }
//     return positions;
// }

// fn isOk(jb: u64, above: u64, current: u64, under: u64) bool {
//     if ((current << 1) & jb > 0) {
//         return true;
//     }

//     if ((current >> 1) & jb > 0) {
//         return true;
//     }

//     if ((above << 1) & jb > 0) {
//         return true;
//     }

//     if ((above >> 1) & jb > 0) {
//         return true;
//     }

//     if ((under << 1) & jb > 0) {
//         return true;
//     }

//     if ((under >> 1) & jb > 0) {
//         return true;
//     }

//     return false;
// }

// fn parseLine_banana(line: []u8, above: u64, current: u64, under: u64) u16 {
//     var out: u16 = 0;
//     // get numbers which has adjacent symbols
//     var n: u6 = 0;
//     while (n < line.len) {
//         if (line[n] >= '0' and line[n] <= '9') {
//             var j: u6 = n + 1;
//             while (j < line.len) {
//                 if (line[j] < '0' or line[j] > '9') {
//                     break;
//                 }
//                 j += 1;
//             }

//             const val = std.fmt.parseInt(u16, line[n..j], 10) catch |err| {
//                 std.debug.print("line: {s}\n", .{line});
//                 std.debug.print("n: {d} j: {d}\n", .{ n, j });
//                 std.debug.print("error: {any}\n", .{err});
//                 return 1;
//             };

//             const jb = ((@as(u64, 1) << j - n) - 1) << n;
//             const ok = isOk(jb, above, current, under);
//             if (ok) {
//                 std.debug.print("val: {d}\n", .{val});
//                 out += val;
//             }

//             n = j;
//         }
//         n += 1;
//     }
//     return out;
// }

// fn banana() !u16 {
//     var out: u16 = 0;

//     // const file = try std.fs.cwd().openFile("input.txt", .{ .mode = .read_only });
//     const file = try std.fs.cwd().openFile("input2.txt", .{ .mode = .read_only });
//     defer file.close();

//     var buf_reader = std.io.bufferedReader(file.reader());
//     var in_stream = buf_reader.reader();
//     var buf: [1024]u8 = undefined;

//     var above: u64 = 0; // symbol positions on the line above
//     var current: u64 = 0; // symbol positions on the current line
//     var under: u64 = 0; // symbol positions on the line below

//     var allocator = std.heap.page_allocator;

//     var line: []u8 = "";

//     while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |next_line| {
//         // verify if line is uninitialized
//         if (std.mem.eql(u8, line, "")) {
//             current = get_symbol_positions_banana(next_line);
//             line = try allocator.alloc(u8, next_line.len);
//             std.mem.copyForwards(u8, line, next_line);
//             continue;
//         }

//         std.debug.print("-----------line: {s}\n", .{line});

//         under = get_symbol_positions_banana(next_line);

//         out += parseLine_banana(line, above, current, under);

//         above = current;
//         current = under;
//         std.mem.copyForwards(u8, line, next_line);
//     }

//     out += parseLine_banana(line, above, current, 0);

//     return out;
// }

// test "simple test" {
//     std.debug.print("{s}\n", .{"hello"});
//     const out = try banana();
//     std.debug.print("out: {d}\n", .{out});
// }
