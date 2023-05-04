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
