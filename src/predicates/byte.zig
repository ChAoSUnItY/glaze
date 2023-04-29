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
