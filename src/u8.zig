const defs = @import("defs.zig");

pub fn ImmediateCharParser(comptime I: type, comptime R: type) type {
    return defs.ImmediateParser(I, u8, R);
}

pub fn DelegateCharParser(comptime I: type, comptime R: type, comptime D: type) type {
    return defs.DelegateParser(I, u8, R, D);
}

fn first_char(input: []const u8) defs.ParserError!u8 {
    if (input.len > 0) {
        return input[0];
    } else {
        return defs.ParserError.IncompleteData;
    }
}

fn _tag(tag_char: u8, input: []const u8) defs.ParserResult(u8, []const u8) {
    const char = try first_char(input);
    if (char == tag_char) {
        return .{
            .output = char,
            .remain = input[1..],
        };
    } else {
        return defs.ParserError.InvalidData;
    }
}

pub fn tag(tag_char: u8) DelegateCharParser([]const u8, []const u8, u8) {
    return DelegateCharParser([]const u8, []const u8, u8){
        .delegated_data = tag_char,
        .parser = _tag,
    };
}

fn _alpha(input: []const u8) defs.ParserResult(u8, []const u8) {
    const char = try first_char(input);
    switch (char) {
        'A'...'Z', 'a'...'z' => {
            return .{
                .output = char,
                .remain = input[1..],
            };
        },
        else => {
            return defs.ParserError.InvalidData;
        },
    }
}

pub fn alpha() ImmediateCharParser([]const u8, []const u8) {
    return ImmediateCharParser([]const u8, []const u8){ .parser = _alpha };
}
