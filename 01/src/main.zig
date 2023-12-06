const std = @import("std");
const File = std.fs.File;

pub fn main() !void {
    const out = run() catch |err| {
        std.debug.print("Failed to run: {any}\n", .{err});
        return;
    };
    std.debug.print("out: {d}\n", .{out});
}

pub fn run() !u64 {
    var out: u32 = 0;

    var file = std.fs.cwd().openFile("input.txt", .{ .mode = .read_only }) catch |err| {
        std.debug.print("Unable to open file: {any}\n", .{err});
        return 1;
    };
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var strm = buf_reader.reader();

    const allocator = std.heap.page_allocator;

    const memory = try allocator.alloc(u8, 1024);
    defer allocator.free(memory);

    while (try strm.readUntilDelimiterOrEof(memory, '\n')) |line| {
        var offset: usize = 0;
        var left: u32 = 0;
        while (offset < line.len - 1) : (offset += 1) {
            const inner_line = line[offset..];
            if (inner_line[0] == '1') {
                left = 1;
            } else if (inner_line[0] == '2') {
                left = 2;
            } else if (inner_line[0] == '3') {
                left = 3;
            } else if (inner_line[0] == '4') {
                left = 4;
            } else if (inner_line[0] == '5') {
                left = 5;
            } else if (inner_line[0] == '6') {
                left = 6;
            } else if (inner_line[0] == '7') {
                left = 7;
            } else if (inner_line[0] == '8') {
                left = 8;
            } else if (inner_line[0] == '9') {
                left = 9;
            } else if (std.mem.startsWith(u8, inner_line, "one")) {
                left = 1;
            } else if (std.mem.startsWith(u8, inner_line, "two")) {
                left = 2;
            } else if (std.mem.startsWith(u8, inner_line, "three")) {
                left = 3;
            } else if (std.mem.startsWith(u8, inner_line, "four")) {
                left = 4;
            } else if (std.mem.startsWith(u8, inner_line, "five")) {
                left = 5;
            } else if (std.mem.startsWith(u8, inner_line, "six")) {
                left = 6;
            } else if (std.mem.startsWith(u8, inner_line, "seven")) {
                left = 7;
            } else if (std.mem.startsWith(u8, inner_line, "eight")) {
                left = 8;
            } else if (std.mem.startsWith(u8, inner_line, "nine")) {
                left = 9;
            }
            if (left != 0) {
                break;
            }
        }

        offset = line.len;
        var right: u32 = 0;
        while (offset >= 1) {
            offset = offset - 1;
            const inner_line = line[offset..line.len];
            if (inner_line[0] == '1') {
                right = 1;
            } else if (inner_line[0] == '2') {
                right = 2;
            } else if (inner_line[0] == '3') {
                right = 3;
            } else if (inner_line[0] == '4') {
                right = 4;
            } else if (inner_line[0] == '5') {
                right = 5;
            } else if (inner_line[0] == '6') {
                right = 6;
            } else if (inner_line[0] == '7') {
                right = 7;
            } else if (inner_line[0] == '8') {
                right = 8;
            } else if (inner_line[0] == '9') {
                right = 9;
            } else if (std.mem.startsWith(u8, inner_line, "one")) {
                right = 1;
            } else if (std.mem.startsWith(u8, inner_line, "two")) {
                right = 2;
            } else if (std.mem.startsWith(u8, inner_line, "three")) {
                right = 3;
            } else if (std.mem.startsWith(u8, inner_line, "four")) {
                right = 4;
            } else if (std.mem.startsWith(u8, inner_line, "five")) {
                right = 5;
            } else if (std.mem.startsWith(u8, inner_line, "six")) {
                right = 6;
            } else if (std.mem.startsWith(u8, inner_line, "seven")) {
                right = 7;
            } else if (std.mem.startsWith(u8, inner_line, "eight")) {
                right = 8;
            } else if (std.mem.startsWith(u8, inner_line, "nine")) {
                right = 9;
            }
            if (right != 0) {
                break;
            }
        }

        const incr = left * 10 + right;
        out += incr;
        std.debug.print("adds: {d} out: {d}\n", .{ incr, out });
    }

    return out;
}

test "simple test" {
    const out = run() catch |err| {
        std.debug.print("Failed to run: {any}\n", .{err});
        return;
    };
    std.debug.print("out: {d}\n", .{out});
    // try std.testing.expectEqual(out, @as(i64, 53278));
}
