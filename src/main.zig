const std = @import("std");
const bytes_parser = @import("parsers/byte.zig");
const bytes_predicate = @import("predicates/byte.zig");
const testing = std.testing;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    const result = try bytes_parser.alpha().invoke("ABC");
    std.debug.print("{}\n", .{result});
    const tagResult = try (try bytes_parser.satisfy(allocator, bytes_predicate.isAlpha)).invoke("1ACD");
    std.debug.print("{}\n", .{tagResult});
}
