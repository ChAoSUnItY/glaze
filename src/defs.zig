const std = @import("std");
const Allocator = std.mem.Allocator;

pub const ParserError = error{
    IncompleteData,
    InvalidData,
};

pub fn ParserResult(comptime O: type, comptime R: type) type {
    return ParserError!struct { output: O, remain: R };
}

pub fn Parser(comptime I: type, comptime O: type, comptime R: type) type {
    return struct {
        const Self = @This();
        const ParserFunction = *const fn (I, ?*anyopaque) ParserResult(O, R);

        delegated_data: ?*anyopaque,
        data_size: u32,
        allocator: ?*const Allocator,
        parser: ParserFunction,

        pub fn init_immediate(parser: ParserFunction) Self {
            return .{
                .delegated_data = null,
                .data_size = 0,
                .allocator = null,
                .parser = parser,
            };
        }

        pub fn init_delegated(allocator: *const Allocator, data: anytype, parser: ParserFunction) !Self {
            var delegated_data = try allocator.*.create(@TypeOf(data));
            delegated_data.* = data;

            return .{
                .delegated_data = delegated_data,
                .data_size = @sizeOf(@TypeOf(data)),
                .allocator = allocator,
                .parser = parser,
            };
        }

        pub fn invoke(self: *const Self, input: I) ParserResult(O, R) {
            defer self.deallocate_data();
            const result = try self.parser(input, self.delegated_data);
            return result;
        }

        fn deallocate_data(self: *const Self) void {
            if (self.delegated_data) |delegated_data| {
                const mem = @ptrCast([*]u8, delegated_data)[0..self.data_size];
                self.allocator.?.*.free(mem);
            }
        }
    };
}
