const std = @import("std");
const defs = @import("defs.zig");
const char_parser = @import("u8.zig");

pub fn seqeunced(input: []const u8, parsers: []const char_parser.CharParser) defs.ParserResult(u8, []const u8) {
    var last_result: u8 = undefined;
    var remain: []const u8 = input;

    for (parsers) |parser| {
        var result = try parser.invoke(remain);

        last_result = result.output;
        remain = result.remain;
    }

    return .{
        .output = last_result,
        .remain = remain,
    };
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    defer _ = gpa.deinit();

    var allocator = &gpa.allocator();

    const result = try char_parser.alpha().invoke("ABC");
    std.debug.print("{}\n", .{result});
    const result_seq = try seqeunced("ABC", &[_]char_parser.CharParser{ char_parser.alpha(), try char_parser.tag(allocator, 'B') });
    std.debug.print("{}\n", .{result_seq});
    const result_tag = try (try char_parser.tag(allocator, 'A')).invoke("ACD");
    std.debug.print("{}\n", .{result_tag});
}
