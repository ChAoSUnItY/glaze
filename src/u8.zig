const std = @import("std");
const Allocator = std.mem.Allocator;
const parsers = @import("parsers.zig");

pub const CharParser = parsers.Parser([]const u8, u8, []const u8);

fn slice(input: []const u8) CharParser.ParserResult {
    return .{
        .output = input[0],
        .remain = input[1..],
    };
}

fn first_char(input: []const u8) parsers.ParserError!u8 {
    if (input.len > 0) {
        return input[0];
    } else {
        return parsers.ParserError.IncompleteData;
    }
}

fn _tag(input: []const u8, ctx: ?[]align(16) u8) CharParser.ParserResult {
    if (parsers.cast_deref(u8, ctx)) |tag_ctx| {
        if (tag_ctx == try first_char(input)) {
            return slice(input);
        }
    }

    return parsers.ParserError.InvalidData;
}

pub fn tag(allocator: Allocator, char: u8) !CharParser {
    return try CharParser.init_delegated(allocator, char, _tag);
}

fn _alpha(input: []const u8, _: ?[]align(16) u8) CharParser.ParserResult {
    switch (try first_char(input)) {
        'A'...'Z', 'a'...'z' => {
            return slice(input);
        },
        else => {
            return parsers.ParserError.InvalidData;
        },
    }
}

pub fn alpha() CharParser {
    return CharParser.init_immediate(_alpha);
}
