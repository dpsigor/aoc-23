const std = @import("std");

pub fn main() !void {
    const out = try banana();
    // part 1 = 1762065988
    // part 2 = 1066
    std.debug.print("out: {d}\n", .{out});
}

fn nextSequence(seq: *std.ArrayList(i64)) !std.ArrayList(i64) {
    var sequence = try std.ArrayList(i64).initCapacity(std.heap.page_allocator, seq.items.len - 1);

    var i: usize = 1;
    while (i < seq.items.len) : (i += 1) {
        const d = seq.items[i] - seq.items[i - 1];
        try sequence.append(d);
    }

    return sequence;
}

fn nextValue(history: *std.ArrayList(i64)) !i64 {
    const first_value = history.items[0];
    var diff: i64 = 0;

    const allocator = std.heap.page_allocator;

    var sequences = std.ArrayList(std.ArrayList(i64)).init(allocator);
    defer sequences.deinit();

    var first_seq = try std.ArrayList(i64).initCapacity(allocator, history.items.len);
    for (history.items) |value| {
        try first_seq.append(value);
    }
    try sequences.append(first_seq);

    var done = false;
    while (!done) {
        const sequence = try nextSequence(&sequences.items[sequences.items.len - 1]);
        try sequences.append(sequence);

        done = sequence.items[sequence.items.len - 1] == 0;
    }

    var i: usize = sequences.items.len - 2;
    while (i >= 1) : (i -= 1) {
        const seq = sequences.items[i];
        diff = seq.items[0] - diff;
    }

    return first_value - diff;
}

fn banana() !i64 {
    const file = try std.fs.cwd().openFile("input.txt", .{ .mode = .read_only });
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;

    const allocator = std.heap.page_allocator;

    var out: i64 = 0;

    var history = std.ArrayList(i64).init(allocator);

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var it = std.mem.split(u8, line, " ");
        while (it.next()) |next| {
            const integer = try std.fmt.parseInt(i64, next, 10);
            try history.append(integer);
        }
        const next_value = try nextValue(&history);
        history.clearAndFree();
        out += next_value;
    }

    return out;
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
