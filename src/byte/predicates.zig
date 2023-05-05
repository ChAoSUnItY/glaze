const std = @import("std");
const testing = std.testing;

pub fn isAlpha(char: u8) bool {
    switch (char) {
        'A'...'Z', 'a'...'z' => {
            return true;
        },
        else => {
            return false;
        },
    }
}

pub fn isDigit(char: u8) bool {
    switch (char) {
        '0'...'9' => {
            return true;
        },
        else => {
            return false;
        },
    }
}

pub fn isAlphaNumberic(char: u8) bool {
    return isAlpha(char) or isDigit(char);
}

pub fn isHex(char: u8) bool {
    switch (char) {
        '0'...'9', 'A'...'F', 'a'...'f' => {
            return true;
        },
        else => {
            return false;
        },
    }
}

pub fn isOct(char: u8) bool {
    switch (char) {
        '0'...'7' => {
            return true;
        },
        else => {
            return false;
        },
    }
}

pub fn isSpace(char: u8) bool {
    switch (char) {
        '\t', '\n', 0x0B, 0x0C, '\r', ' ', 0x85, 0xA0 => {
            return true;
        },
        else => {
            return false;
        },
    }
}

pub fn isNewLine(char: u8) bool {
    return char == 0x0A;
}

// Tests

fn genRange(comptime start: u8, comptime end: u8) [end - start + 1]u8 {
    if (end < start) {
        @compileError("parameter end must larger than start");
    }
    comptime var i = start;
    var range: [end - start + 1]u8 = undefined;
    inline while (i <= end) : (i += 1) {
        range[i - start] = i;
    }
    return range;
}

test "isAlpha" {
    for (genRange('a', 'z')) |char| {
        try testing.expect(isAlpha(char));
    }

    for (genRange('A', 'Z')) |char| {
        try testing.expect(isAlpha(char));
    }
}

test "isDigit" {
    for (genRange('0', '9')) |char| {
        try testing.expect(isHex(char));
    }
}

test "isHex" {
    for (genRange('0', '9')) |char| {
        try testing.expect(isHex(char));
    }

    for (genRange('a', 'f')) |char| {
        try testing.expect(isHex(char));
    }

    for (genRange('A', 'F')) |char| {
        try testing.expect(isHex(char));
    }
}
