const std = @import("std");
const stdin = std.io.getStdIn().reader();
const stdout = std.io.getStdOut().writer();
const maxRow = 10;
const memsize = 128;

pub fn main() !void {
    var buf: [16]u8 = undefined;

    while (true) {
        try stdout.print("Which allocator to play with? \n\tArenna Allocator <AA>\n\tGeneral Purpose Allocator <GPA>\n\tFixed Buffer Allocator <FBA>\n", .{});

        if (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')) |uinput| {
            if (uinput.len < 1) {
                return;
            } else if (std.mem.eql(u8, uinput[0..2], "AA")) {
                _ = try AA();
            } else if (std.mem.eql(u8, uinput[0..3], "GPA")) {
                _ = try GPA();
            } else if (std.mem.eql(u8, uinput[0..3], "FBA")) {
                _ = try FPA();
            }
        } else {
            try stdout.print("{s}\n", .{"Invalid Input"});
        }
    }
}

fn prettyPrint(size: usize, content: []u8) !void {
    try stdout.print("\nsize: {d} \n", .{size});
    for (0..content.len) |j| {
        if (j % maxRow == 0 and j > 0) {
            try stdout.print("\n", .{});
        }
        try stdout.print("{x:<2} ", .{content[j]});
    }
    try stdout.print("\n", .{});
}

fn GPA() !u8 {
    try stdout.print("{s}\n\t{s} {d} bytes\n", .{ "Using General Purpose Allocator", "memsize:", memsize });
    //var buf: [128]u8 = undefined;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const mem: []u8 = try allocator.alloc(u8, memsize);
    defer allocator.free(mem);

    const in = std.io.getStdIn();
    var size: usize = 2;

    while (true) {
        try stdout.print("{s}\n", .{"<enter> to return, <input> to write to buffer: "});
        size = try in.read(mem);
        if (mem[0] == '\n') {
            return 1;
        }

        try prettyPrint(size, mem);
    }
    return 1;
}

fn FPA() !u8 {
    try stdout.print("{s}\n\t{s} {d} bytes\n", .{ "Using Fixed Buffer Allocator", "memsize:", memsize });
    var buf: [128]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buf);
    const allocator = fba.allocator();
    const mem: []u8 = try allocator.alloc(u8, memsize);
    defer allocator.free(mem);

    const in = std.io.getStdIn();
    var size: usize = 2;

    while (true) {
        try stdout.print("{s}\n", .{"<enter> to return, <input> to write to buffer: "});
        size = try in.read(mem);
        if (mem[0] == '\n') {
            return 1;
        }

        try prettyPrint(size, mem);
    }
    return 1;
}

fn AA() !u8 {
    try stdout.print("{s}\n\t{s} {d} bytes\n", .{ "Using Arena Allocator", "memsize:", memsize });
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const mem: []u8 = try allocator.alloc(u8, memsize);
    defer allocator.free(mem);

    const in = std.io.getStdIn();
    var size: usize = 2;

    while (true) {
        try stdout.print("{s}\n", .{"<enter> to return, <input> to write to buffer: "});
        size = try in.read(mem);
        if (mem[0] == '\n') {
            return 1;
        }

        try prettyPrint(size, mem);
    }
    return 1;
}
