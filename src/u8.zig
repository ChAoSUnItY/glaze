const std = @import("std");
const Allocator = std.mem.Allocator;
const defs = @import("defs.zig");

pub const CharParser = defs.Parser([]const u8, u8, []const u8);

fn first_char(input: []const u8) defs.ParserError!u8 {
    if (input.len > 0) {
        return input[0];
    } else {
        return defs.ParserError.IncompleteData;
    }
}

fn _tag(input: []const u8, ctx: ?*anyopaque) defs.ParserResult(u8, []const u8) {
    if (@ptrCast(*u8, ctx).* == try first_char(input)) {
        return .{
            .output = input[0],
            .remain = input[1..],
        };
    } else {
        return defs.ParserError.InvalidData;
    }
}

pub fn tag(allocator: *const Allocator, char: u8) !CharParser {
    return try CharParser.init_delegated(allocator, char, _tag);
}

fn _alpha(input: []const u8, _: ?*anyopaque) defs.ParserResult(u8, []const u8) {
    switch (try first_char(input)) {
        'A'...'Z', 'a'...'z' => {
            return .{
                .output = input[0],
                .remain = input[1..],
            };
        },
        else => {
            return defs.ParserError.InvalidData;
        },
    }
}

pub fn alpha() CharParser {
    return CharParser.init_immediate(_alpha);
}
