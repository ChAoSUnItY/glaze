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

test "Test byte predicates" {
    var char: u8 = 'A';

    while (char != 'Z') : (char += 1) {
        try testing.expect(isAlpha(char));
    }

    char = 'a';

    while (char != 'z') : (char += 1) {
        try testing.expect(isAlpha(char));
    }
}
