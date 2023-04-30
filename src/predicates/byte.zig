const std = @import("std");

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
