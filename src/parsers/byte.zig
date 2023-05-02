const std = @import("std");
const parsers = @import("../parsers.zig");
const Allocator = std.mem.Allocator;

// Utility Definitions

pub const ByteParser = parsers.Parser([]const u8, u8, []const u8);

fn slice(input: []const u8) ByteParser.ParserResult {
    return .{
        .output = input[0],
        .remain = input[1..],
    };
}

fn firstChar(input: []const u8) parsers.ParserError!u8 {
    if (input.len > 0) {
        return input[0];
    } else {
        return parsers.ParserError.IncompleteData;
    }
}

// Parser Definitions

fn _satisfy(input: []const u8, ctx: *const fn (u8) bool) ByteParser.ParserResult {
    if (ctx(try firstChar(input))) {
        return slice(input);
    }

    return parsers.ParserError.InvalidData;
}

pub fn satisfy(allocator: Allocator, comptime predicate: *const fn (u8) bool) !ByteParser {
    return try ByteParser.init(allocator, predicate, _satisfy);
}

fn _tag(input: []const u8, ctx: u8) ByteParser.ParserResult {
    if (ctx == try firstChar(input)) {
        return slice(input);
    }

    return parsers.ParserError.InvalidData;
}

pub fn tag(allocator: Allocator, comptime char: u8) !ByteParser {
    return try ByteParser.init(allocator, char, _tag);
}
