const std = @import("std");
const parsers = @import("parsers.zig");
const bytes_parser = @import("parsers/byte.zig");
const bytes_predicate = @import("predicates/byte.zig");
const testing = std.testing;

fn parse(input: []const u8, context: []const u8) parsers.ExperimentParser([]const u8, u8, []const u8).ParserResult {
    _ = context;

    return .{
        .output = input[0],
        .remain = input[1..],
    };
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    // const result = try bytes_parser.alpha().invoke("ABC");
    // std.debug.print("{}\n", .{result});
    // const tagResult = try (try bytes_parser.satisfy(allocator, bytes_predicate.isAlpha)).invoke("1ACD");
    // std.debug.print("{}\n", .{tagResult});

    const experimentParser = try parsers.ExperimentParser([]const u8, u8, []const u8).initStringLiteralCtx(allocator, "AKA", parse);

    std.debug.print("{}\n", .{try experimentParser.invoke("AKA")});
}
