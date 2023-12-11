const std = @import("std");

pub fn main() !void {
    const out = try solution();
    // first solution: 6828
    // second solution: 459
    std.debug.print("{d}\n", .{out});
}

const Pos = struct {
    x: usize,
    y: usize,
    c: u8,
    loop: bool = false,
    step: u64 = 0,
};

const NoNext = error{
    NoNext,
};

fn nextPos(layout: *std.ArrayList(std.ArrayList(Pos)), curr: Pos, prev: Pos) !Pos {
    const pipe = layout.items[curr.y].items[curr.x].c;
    const isOnEastBorder = curr.x == layout.items[curr.y].items.len - 1;
    if (!isOnEastBorder and curr.x + 1 != prev.x and (pipe == '-' or pipe == 'L' or pipe == 'F')) {
        const n = layout.items[curr.y].items[curr.x + 1].c;
        if (n == '-' or n == 'J' or n == '7' or n == 'S') {
            return layout.items[curr.y].items[curr.x + 1];
        }
    }
    const isOnNorthBorder = curr.y == 0;
    if (!isOnNorthBorder and curr.y - 1 != prev.y and (pipe == '|' or pipe == 'L' or pipe == 'J')) {
        const n = layout.items[curr.y - 1].items[curr.x].c;
        if (n == '|' or n == '7' or n == 'F' or n == 'S') {
            return layout.items[curr.y - 1].items[curr.x];
        }
    }
    const isOnWestBorder = curr.x == 0;
    if (!isOnWestBorder and curr.x - 1 != prev.x and (pipe == '-' or pipe == '7' or pipe == 'J')) {
        const n = layout.items[curr.y].items[curr.x - 1].c;
        if (n == '-' or n == 'L' or n == 'F' or n == 'S') {
            return layout.items[curr.y].items[curr.x - 1];
        }
    }
    const isOnSouthBorder = curr.y == layout.items.len - 1;
    if (!isOnSouthBorder and curr.y + 1 != prev.y and (pipe == '|' or pipe == '7' or pipe == 'F')) {
        const n = layout.items[curr.y + 1].items[curr.x].c;
        if (n == '|' or n == 'J' or n == 'L' or n == 'S') {
            return layout.items[curr.y + 1].items[curr.x];
        }
    }
    return error.NoNext;
}

fn firstPos(layout: *std.ArrayList(std.ArrayList(Pos)), start: Pos) !Pos {
    const isOnEastBorder = start.x == layout.items[start.y].items.len - 1;
    if (!isOnEastBorder) {
        const n = layout.items[start.y].items[start.x + 1].c;
        if (n == '-' or n == 'J' or n == '7') {
            return layout.items[start.y].items[start.x + 1];
        }
    }
    const isOnNorthBorder = start.y == 0;
    if (!isOnNorthBorder) {
        const n = layout.items[start.y - 1].items[start.x].c;
        if (n == '|' or n == '7' or n == 'F') {
            return layout.items[start.y - 1].items[start.x];
        }
    }
    const isOnWestBorder = start.x == 0;
    if (!isOnWestBorder) {
        const n = layout.items[start.y].items[start.x - 1].c;
        if (n == '-' or n == 'L' or n == 'F') {
            return layout.items[start.y].items[start.x - 1];
        }
    }
    const isOnSouthBorder = start.y == layout.items.len - 1;
    if (!isOnSouthBorder) {
        const n = layout.items[start.y + 1].items[start.x].c;
        if (n == '|' or n == 'J' or n == 'L') {
            return layout.items[start.y + 1].items[start.x];
        }
    }
    return error.NoNext;
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
    const buffer_size = 32768;
    const file_buffer = try file.readToEndAlloc(allocator, buffer_size);
    defer allocator.free(file_buffer);

    var it = std.mem.split(u8, file_buffer, "\n");

    var layout = std.ArrayList(std.ArrayList(Pos)).init(allocator);
    defer layout.deinit();

    var y: usize = 0;
    var x: usize = 0;
    var start_x: u64 = 0;
    var start_y: u64 = 0;
    while (it.next()) |line| {
        if (line.len == 0) {
            continue;
        }
        var positions = std.ArrayList(Pos).init(std.heap.page_allocator);
        while (x < line.len) : (x += 1) {
            try positions.append(Pos{ .x = x, .y = y, .c = line[x] });
            if (line[x] == 'S') {
                start_x = x;
                start_y = y;
            }
        }
        try layout.append(positions);
        y += 1;
        x = 0;
    }

    var step: u64 = 0;

    layout.items[start_y].items[start_x].loop = true;
    layout.items[start_y].items[start_x].step = step;
    const start = layout.items[start_y].items[start_x];
    var prev = start;
    var curr = try firstPos(&layout, start);
    step += 1;
    layout.items[curr.y].items[curr.x].loop = true;
    layout.items[curr.y].items[curr.x].step = step;

    while (curr.x != start_x or curr.y != start_y) {
        step += 1;
        const prevTmp = curr;
        curr = try nextPos(&layout, curr, prev);
        prev = prevTmp;
        layout.items[curr.y].items[curr.x].loop = true;
        layout.items[curr.y].items[curr.x].step = step;
    }

    for (layout.items) |line| {
        for (line.items) |pos| {
            if (pos.loop) {
                if (pos.c == 'S') {
                    std.debug.print("S", .{});
                } else {
                    std.debug.print("{d}", .{pos.step % 9});
                }
            } else {
                std.debug.print("_", .{});
            }
        }
        std.debug.print("\n", .{});
    }

    y = 0;
    x = 0;
    while (y < layout.items.len) : (y += 1) {
        var crossed: usize = 0;
        while (x < layout.items[y].items.len) : (x += 1) {
            if (layout.items[y].items[x].loop) {
                continue;
            }
            // go diagonal, to left and bottom, and verify if crossed even
            // times. Ignores L7:
            // L is not crossed:
            // X _ _
            // X _ _
            // X X X
            // 7 is not crossed either:
            // X X X
            // _ _ X
            // _ _ X
            // J is crossed on star:
            // _ _ X
            // _ _ X
            // X X *
            // F is crossed on star:
            // * X X
            // X _ _
            // X _ _
            var m = x;
            var n = y;
            while (n < layout.items.len and m < layout.items[y].items.len) {
                const pos = layout.items[n].items[m];
                if (pos.loop and pos.c != 'L' and pos.c != '7') {
                    crossed += 1;
                }
                m += 1;
                n += 1;
            }
            if (crossed % 2 == 1) {
                out += 1;
            }
            crossed = 0;
        }
        x = 0;
    }

    return out;
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
