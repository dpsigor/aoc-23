const std = @import("std");

pub fn main() !void {
    const out = try banana();
    std.debug.print("out: {}\n", .{out});
}

fn banana() !u64 {
    // var file = try std.fs.cwd().openFile("input2.txt", .{ .mode = .read_only });
    var file = try std.fs.cwd().openFile("input.txt", .{ .mode = .read_only });
    defer file.close();
    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;

    var out: u64 = 0;

    const allocator = std.heap.page_allocator;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var local_out: u64 = 0;
        var i: usize = 0;
        var winningIdx: usize = 0;
        var numbersIdx: usize = 0;
        while (i < line.len) {
            if (winningIdx == 0) {
                if (line[i] == ':') {
                    winningIdx = i + 2;
                }
            } else if (line[i] == '|') {
                numbersIdx = i + 2;
                break;
            }
            i += 1;
        }

        var winning = std.AutoHashMap(u64, bool).init(allocator);
        defer winning.deinit();

        var it = std.mem.split(u8, line[winningIdx .. numbersIdx - 3], " ");

        while (it.next()) |number| {
            if (number.len == 0) {
                continue;
            }
            const num = try std.fmt.parseInt(u64, number, 10);
            try winning.put(num, true);
        }

        var numbers = std.AutoHashMap(u64, bool).init(allocator);
        defer numbers.deinit();

        it = std.mem.split(u8, line[numbersIdx..line.len], " ");

        while (it.next()) |number| {
            if (number.len == 0) {
                continue;
            }
            const num = try std.fmt.parseInt(u64, number, 10);
            try numbers.put(num, true);
        }

        var nums = numbers.keyIterator();
        while (nums.next()) |num| {
            if (winning.contains(num.*)) {
                if (local_out == 0) {
                    local_out = 1;
                } else {
                    local_out *= 2;
                }
            }
        }

        out += local_out;
    }

    return out;
}

fn apple() !u64 {
    // var file = try std.fs.cwd().openFile("input2.txt", .{ .mode = .read_only });
    var file = try std.fs.cwd().openFile("input.txt", .{ .mode = .read_only });
    defer file.close();
    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;

    var out: u64 = 0;

    const allocator = std.heap.page_allocator;

    var scratchcards = std.AutoHashMap(u64, u64).init(allocator);
    defer scratchcards.deinit();

    var scratchcard: u64 = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        scratchcard += 1;

        const exists = try scratchcards.getOrPut(scratchcard);
        var scratchcard_amt: u64 = 1;
        if (exists.found_existing) {
            scratchcard_amt = exists.value_ptr.* + 1;
            try scratchcards.put(scratchcard, scratchcard_amt);
        } else {
            try scratchcards.put(scratchcard, scratchcard_amt);
        }

        var points: u64 = 0;
        var i: usize = 0;
        var winningIdx: usize = 0;
        var numbersIdx: usize = 0;
        while (i < line.len) {
            if (winningIdx == 0) {
                if (line[i] == ':') {
                    winningIdx = i + 2;
                }
            } else if (line[i] == '|') {
                numbersIdx = i + 2;
                break;
            }
            i += 1;
        }

        var winning = std.AutoHashMap(u64, bool).init(allocator);
        defer winning.deinit();

        var it = std.mem.split(u8, line[winningIdx .. numbersIdx - 3], " ");

        while (it.next()) |number| {
            if (number.len == 0) {
                continue;
            }
            const num = try std.fmt.parseInt(u64, number.?, 10);
            try winning.put(num, true);
        }

        var numbers = std.AutoHashMap(u64, bool).init(allocator);
        defer numbers.deinit();

        it = std.mem.split(u8, line[numbersIdx..line.len], " ");

        while (it.next()) |number| {
            if (number.len == 0) {
                continue;
            }
            const num = try std.fmt.parseInt(u64, number.?, 10);
            try numbers.put(num, true);
        }

        var nums = numbers.keyIterator();
        while (nums.next()) |num| {
            if (winning.contains(num.*)) {
                points += 1;
            }
        }

        i = 1;
        while (i <= points) {
            const card = scratchcard + i;
            const card_result = try scratchcards.getOrPut(card);
            if (card_result.found_existing) {
                try scratchcards.put(card, card_result.value_ptr.* + scratchcard_amt);
            } else {
                try scratchcards.put(card, scratchcard_amt);
            }
            i += 1;
        }
    }

    var keys = scratchcards.keyIterator();
    while (keys.next()) |k| {
        if (k.* > scratchcard) {
            continue;
        }
        const v = scratchcards.get(k.*);
        out += v.?;
        std.debug.print("k: {d}, v: {d}\n", .{ k.*, v.? });
    }

    return out;
}

test "simple test" {
    // const out = try banana();
    const out = try apple();
    std.debug.print("out: {d}", .{out});
}
