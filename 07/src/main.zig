const std = @import("std");

var powers = [_]u8{
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    'T',
    // 'J', // joker
    'Q',
    'K',
    'A',
};

fn cardPower(card: u8) u8 {
    if (card == 'J') return 0;
    var i: u8 = 0;
    while (i < powers.len) : (i += 1) {
        if (powers[i] == card) {
            return i + 1;
        }
    }
    std.debug.panic("failed to get card power for {c}\n", .{card});
    return 0;
}

const HandType = u8;

const FiveOfAKind: HandType = 7;
const FourOfAKind: HandType = 6;
const FullHouse: HandType = 5;
const ThreeOfAKind: HandType = 4;
const TwoPair: HandType = 3;
const OnePair: HandType = 2;
const HighCard: HandType = 1;

fn printMap(m: *std.AutoHashMap(u8, u8)) void {
    var it = m.iterator();
    while (it.next()) |next| {
        std.debug.print("{c} {d}\n", .{ next.key_ptr.*, next.value_ptr.* });
    }
}

fn handType(hand: [5]u8, counter: *std.AutoHashMap(u8, u8)) !HandType {
    var i: usize = 0;
    while (i < 5) : (i += 1) {
        const val = counter.get(hand[i]);
        if (val == null) {
            try counter.put(hand[i], 1);
            continue;
        }
        try counter.put(hand[i], val.? + 1);
    }

    const j_amt_entry = try counter.getOrPutValue('J', 0);
    const j_amt = j_amt_entry.value_ptr.*;

    var pairs: u8 = 0;
    var threes: u8 = 0;
    var it = counter.iterator();
    while (it.next()) |next| {
        if (next.value_ptr.* == 5) {
            return FiveOfAKind;
        }
        if (next.value_ptr.* == 4) {
            if (j_amt > 0) return FiveOfAKind;
            return FourOfAKind;
        }
        if (next.value_ptr.* == 3) {
            threes += 1;
        }
        if (next.value_ptr.* == 2) {
            pairs += 1;
        }
    }
    if (pairs == 1 and threes == 1) {
        if (j_amt == 1) return FourOfAKind;
        if (j_amt == 2) return FiveOfAKind;
        if (j_amt == 3) return FiveOfAKind;
        return FullHouse;
    }
    if (threes == 1) {
        if (j_amt == 1) return FourOfAKind;
        if (j_amt == 2) return FiveOfAKind; // already covered above
        return ThreeOfAKind;
    }
    if (pairs == 2) {
        if (j_amt == 1) return FullHouse;
        if (j_amt == 2) return FourOfAKind; // already covered above
        return TwoPair;
    }
    if (pairs == 1) {
        if (j_amt == 1) return ThreeOfAKind;
        if (j_amt == 2) return ThreeOfAKind;
        return OnePair;
    }
    if (j_amt == 1) return OnePair;
    return HighCard;
}

const Play = struct {
    hand: [5]u8,
    bid: u64,
    hand_type: HandType,
};

fn comparePlays(_: void, lhs: Play, rhs: Play) bool {
    if (lhs.hand_type == rhs.hand_type) {
        var i: usize = 0;
        while (i < 5) : (i += 1) {
            if (lhs.hand[i] == rhs.hand[i]) continue;
            return cardPower(lhs.hand[i]) < cardPower(rhs.hand[i]);
        }
        std.debug.panic("failed to compare plays {any} and {any}\n", .{ lhs, rhs });
    }
    return lhs.hand_type < rhs.hand_type;
}

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input.txt", .{ .mode = .read_only });
    defer file.close();

    var buf_stream = std.io.bufferedReader(file.reader());
    var in_stream = buf_stream.reader();

    var buf: [1024]u8 = undefined;

    const allocator = std.heap.page_allocator;
    var counter = std.AutoHashMap(u8, u8).init(allocator);

    var plays = std.ArrayList(Play).init(allocator);
    defer plays.deinit();

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var it = std.mem.split(u8, line, " ");
        const cards_str = it.next().?;

        var hand: [5]u8 = undefined;

        var i: usize = 0;
        while (i < 5) : (i += 1) {
            hand[i] = cards_str[i];
        }

        const bid = try std.fmt.parseInt(u64, it.next().?, 10);

        const hand_type = try handType(hand, &counter);

        counter.clearAndFree();
        try plays.append(Play{ .hand = hand, .bid = bid, .hand_type = hand_type });
    }

    const x = try plays.toOwnedSlice();
    std.sort.insertion(Play, x, {}, comparePlays);

    var out: u64 = 0;

    var i: usize = 0;
    while (i < x.len) : (i += 1) {
        out += (i + 1) * x[i].bid;
        std.debug.print("{d}\t{s}\t{d}\t{d}\t{d}\t{d}\n", .{
            i + 1,
            x[i].hand,
            x[i].hand_type,
            x[i].bid,
            (i + 1) * x[i].bid,
            out,
        });
    }

    std.debug.print("{d}\n", .{out});
}

// Declare errors
const errs = error{
    UnexpectedNull,
};

test "simple test" {
    std.debug.print(">>> {d}\n", .{1});
}
