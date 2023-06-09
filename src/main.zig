const std = @import("std");
const bytes_parser = @import("byte/parsers.zig");
const bytes_predicate = @import("byte/predicates.zig");
const testing = std.testing;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var arena = std.heap.ArenaAllocator.init(gpa.allocator());

    defer _ = arena.deinit();

    const allocator = arena.allocator();

    const result = try (try bytes_parser.tag(allocator, 'A')).parse("ABC");
    std.debug.print("{}\n", .{result});
    const tagResult = try (try bytes_parser.satisfy(allocator, bytes_predicate.isAlpha)).parse("ACD");
    std.debug.print("{}\n", .{tagResult});
}
