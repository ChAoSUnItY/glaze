const std = @import("std");
const Allocator = std.mem.Allocator;

pub const ParserError = error{
    IncompleteData,
    InvalidData,
};

pub fn Parser(comptime I: type, comptime O: type, comptime R: type) type {
    return struct {
        const Self = @This();
        pub const ParserResult = ParserError!struct { output: O, remain: R };
        pub const ParserFunction = *const fn (I, ?[]align(16) u8) ParserResult;

        delegated_data: ?[]align(16) u8,
        allocator: ?Allocator,
        parser: ParserFunction,

        pub fn init_immediate(parser: ParserFunction) Self {
            return .{
                .delegated_data = null,
                .allocator = null,
                .parser = parser,
            };
        }

        pub fn init_delegated(allocator: Allocator, data: anytype, parser: ParserFunction) !Self {
            const T = @TypeOf(data);
            const delegated_data = try allocator.alignedAlloc(u8, 16, @sizeOf(T));
            errdefer allocator.free(delegated_data);
            @ptrCast(*T, delegated_data.ptr).* = data;

            return .{
                .delegated_data = delegated_data,
                .allocator = allocator,
                .parser = parser,
            };
        }

        pub fn invoke(self: *const Self, input: I) ParserResult {
            defer self.deallocate_data();
            return try self.parser(input, self.delegated_data);
        }

        fn deallocate_data(self: *const Self) void {
            if (self.delegated_data) |delegated_data| {
                self.allocator.?.free(delegated_data);
            }
        }
    };
}

pub fn cast_deref(comptime T: type, data_slice: ?[]align(16) u8) ?T {
    if (data_slice) |slice| {
        return @ptrCast(*T, slice.ptr).*;
    } else {
        return null;
    }
}
