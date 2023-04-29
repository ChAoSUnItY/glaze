const std = @import("std");
const defs = @import("defs.zig");
const char_parser = @import("u8.zig");

pub fn main() defs.ParserError!void {
    const result = try char_parser.alpha().invoke("ABC");
    std.debug.print("{}\n", .{result});
    const result_tag = try char_parser.tag('A').invoke("BCD");
    std.debug.print("{}\n", .{result_tag});
}
