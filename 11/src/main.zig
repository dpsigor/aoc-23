const std = @import("std");

pub fn main() !void {
    const out = try solution();
    // solution 1: 10231178
    std.debug.print("out {d}\n", .{out});
}

const Galaxy = struct {
    x: u64,
    y: u64,
    name: u64,
};

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

    const image = std.mem.trim(u8, file_buffer, "\n");

    var galaxies = std.ArrayList(Galaxy).init(allocator);
    defer galaxies.deinit();

    var emptyRows = std.AutoHashMap(u64, void).init(allocator);
    defer emptyRows.deinit();
    var emptyCols = std.AutoHashMap(u64, void).init(allocator);
    defer emptyCols.deinit();

    var x: usize = 0;
    var y: usize = 0;
    var cols: usize = 0;
    var name: u64 = 0;
    for (image) |point| {
        if (point == '\n') {
            y += 1;
            x = 0;
            continue;
        }
        if (point == '#') {
            name += 1;
            try galaxies.append(Galaxy{ .x = x, .y = y, .name = name });
            if (x > cols) {
                cols = x;
            }
        }
        x += 1;
    }

    var i: u64 = 0;
    while (i <= y) : (i += 1) {
        try emptyRows.put(i, {});
    }
    i = 0;
    while (i <= cols) : (i += 1) {
        try emptyCols.put(i, {});
    }

    for (galaxies.items) |galaxy| {
        _ = emptyRows.remove(galaxy.y);
        _ = emptyCols.remove(galaxy.x);
    }

    i = 0;
    while (i < galaxies.items.len) : (i += 1) {
        var j = i + 1;
        while (j < galaxies.items.len) : (j += 1) {
            const a = galaxies.items[i];
            const b = galaxies.items[j];
            var dist_hor: u64 = 0;
            var ax = a.x;
            var bx = b.x;
            if (ax > bx) {
                const tmp = ax;
                ax = bx;
                bx = tmp;
            }
            while (ax < bx) : (ax += 1) {
                if (emptyCols.contains(ax)) {
                    dist_hor += 2;
                    continue;
                }
                dist_hor += 1;
            }
            var dist_ver: u64 = 0;
            var ay = a.y;
            var by = b.y;
            if (ay > by) {
                const tmp = ay;
                ay = by;
                by = tmp;
            }
            while (ay < by) : (ay += 1) {
                if (emptyRows.contains(ay)) {
                    dist_ver += 2;
                    continue;
                }
                dist_ver += 1;
            }
            out += dist_hor + dist_ver;
        }
    }

    return out;
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
