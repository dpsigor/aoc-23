const std = @import("std");

pub fn main() !void {
    const out = try solution();
    // first solution: 6828
    std.debug.print("{d}\n", .{out});
}

const Pos = struct {
    x: usize,
    y: usize,
};

const NoNext = error{
    NoNext,
};

fn nextPos(layout: *std.ArrayList([]const u8), curr: Pos, prev: Pos) !Pos {
    const pipe = layout.items[curr.y][curr.x];
    const isOnEastBorder = curr.x == layout.items[curr.y].len - 1;
    if (!isOnEastBorder and curr.x + 1 != prev.x and (pipe == '-' or pipe == 'L' or pipe == 'F')) {
        const n = layout.items[curr.y][curr.x + 1];
        if (n == '-' or n == 'J' or n == '7' or n == 'S') {
            return Pos{ .x = curr.x + 1, .y = curr.y };
        }
    }
    const isOnNorthBorder = curr.y == 0;
    if (!isOnNorthBorder and curr.y - 1 != prev.y and (pipe == '|' or pipe == 'L' or pipe == 'J')) {
        const n = layout.items[curr.y - 1][curr.x];
        if (n == '|' or n == '7' or n == 'F' or n == 'S') {
            return Pos{ .x = curr.x, .y = curr.y - 1 };
        }
    }
    const isOnWestBorder = curr.x == 0;
    if (!isOnWestBorder and curr.x - 1 != prev.x and (pipe == '-' or pipe == '7' or pipe == 'J')) {
        const n = layout.items[curr.y][curr.x - 1];
        if (n == '-' or n == 'L' or n == 'F' or n == 'S') {
            return Pos{ .x = curr.x - 1, .y = curr.y };
        }
    }
    const isOnSouthBorder = curr.y == layout.items.len - 1;
    if (!isOnSouthBorder and curr.y + 1 != prev.y and (pipe == '|' or pipe == '7' or pipe == 'F')) {
        const n = layout.items[curr.y + 1][curr.x];
        if (n == '|' or n == 'J' or n == 'L' or n == 'S') {
            return Pos{ .x = curr.x, .y = curr.y + 1 };
        }
    }
    return error.NoNext;
}

fn firstPos(layout: *std.ArrayList([]const u8), start: Pos) !Pos {
    const isOnEastBorder = start.x == layout.items[start.y].len - 1;
    if (!isOnEastBorder) {
        const n = layout.items[start.y][start.x + 1];
        if (n == '-' or n == 'J' or n == '7') {
            return Pos{ .x = start.x + 1, .y = start.y };
        }
    }
    const isOnNorthBorder = start.y == 0;
    if (!isOnNorthBorder) {
        const n = layout.items[start.y - 1][start.x];
        if (n == '|' or n == '7' or n == 'F') {
            return Pos{ .x = start.x, .y = start.y - 1 };
        }
    }
    const isOnWestBorder = start.x == 0;
    if (!isOnWestBorder) {
        const n = layout.items[start.y][start.x - 1];
        if (n == '-' or n == 'L' or n == 'F') {
            return Pos{ .x = start.x - 1, .y = start.y };
        }
    }
    const isOnSouthBorder = start.y == layout.items.len - 1;
    if (!isOnSouthBorder) {
        const n = layout.items[start.y + 1][start.x];
        if (n == '|' or n == 'J' or n == 'L') {
            return Pos{ .x = start.x, .y = start.y + 1 };
        }
    }
    return error.NoNext;
}

fn solution() !u64 {
    //  Get an allocator
    var gp = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
    defer _ = gp.deinit();
    var allocator = gp.allocator();

    // Open the file
    const file = try std.fs.cwd().openFile("input.txt", .{ .mode = .read_only });
    defer file.close();

    // Read the contents
    const buffer_size = 32768;
    const file_buffer = try file.readToEndAlloc(allocator, buffer_size);
    defer allocator.free(file_buffer);

    var it = std.mem.split(u8, file_buffer, "\n");

    var layout = std.ArrayList([]const u8).init(allocator);
    defer layout.deinit();

    var y: usize = 0;
    var found_start = false;
    var start = Pos{ .x = 0, .y = 0 };
    while (it.next()) |line| {
        if (line.len == 0) {
            continue;
        }
        try layout.append(line);
        if (!found_start) {
            const x = std.mem.indexOf(u8, line, "S");
            if (x != null) {
                start.x = x.?;
                start.y = y;
                found_start = true;
            }
        }
        y += 1;
    }

    // Now we have the layout by line, and the starting point.
    // How start walking until we return to the start, counting steps.
    var step: u64 = 1;
    var prev = start;
    var curr = try firstPos(&layout, start);
    while (curr.x != start.x or curr.y != start.y) {
        step += 1;
        const prevX = curr.x;
        const prevY = curr.y;
        curr = try nextPos(&layout, Pos{ .x = curr.x, .y = curr.y }, prev);
        prev = Pos{ .x = prevX, .y = prevY };
    }

    return step / 2;
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
