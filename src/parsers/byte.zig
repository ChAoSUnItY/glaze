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

fn _satisfy(input: []const u8, ctx: ?[]align(16) u8) ByteParser.ParserResult {
    if (parsers.castDeref(*const fn (u8) bool, ctx)) |satisfyCtx| {
        if (satisfyCtx(try firstChar(input))) {
            return slice(input);
        }
    }

    return parsers.ParserError.InvalidData;
}

pub fn satisfy(allocator: Allocator, predicate: *const fn (u8) bool) !ByteParser {
    return try ByteParser.initDelegated(allocator, predicate, _satisfy);
}

fn _tag(input: []const u8, ctx: ?[]align(16) u8) ByteParser.ParserResult {
    if (parsers.castDeref(u8, ctx)) |tagCtx| {
        if (tagCtx == try firstChar(input)) {
            return slice(input);
        }
    }

    return parsers.ParserError.InvalidData;
}

pub fn tag(allocator: Allocator, char: u8) !ByteParser {
    return try ByteParser.initDelegated(allocator, char, _tag);
}

fn _alpha(input: []const u8, _: ?[]align(16) u8) ByteParser.ParserResult {
    switch (try firstChar(input)) {
        'A'...'Z', 'a'...'z' => {
            return slice(input);
        },
        else => {
            return parsers.ParserError.InvalidData;
        },
    }
}

pub fn alpha() ByteParser {
    return ByteParser.initImmediate(_alpha);
}
