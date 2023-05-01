const std = @import("std");
const Allocator = std.mem.Allocator;

pub const ParserError = error{
    Unimplemented,
    IncompleteData,
    InvalidData,
};

pub fn ParserContext(comptime T: type) type {
    return struct {
        data: T,
    };
}

pub fn ExperimentParser(comptime I: type, comptime O: type, comptime R: type) type {
    return struct {
        const Self = @This();
        pub const ResultTuple = struct { output: O, remain: R };
        pub const ParserResult = ParserError!ResultTuple;
        pub const ParserFunction = *const fn (I, ?[]align(16) u8) ParserResult;

        delegatedData: ?[]align(16) u8,
        allocator: ?Allocator,
        parser: ParserFunction,

        pub fn initStringLiteralCtx(allocator: Allocator, comptime data: []const u8, comptime parser: *const fn (I, []const u8) ParserResult) !Self {
            return Self.init(allocator, data, parser);
        }

        pub fn init(allocator: Allocator, comptime data: anytype, comptime parser: *const fn (I, @TypeOf(data)) ParserResult) !Self {
            const T = @TypeOf(data);
            const delegatedData = try allocator.alignedAlloc(u8, 16, @sizeOf(T));
            errdefer allocator.free(delegatedData);
            @ptrCast(*T, delegatedData.ptr).* = data;

            const parserImpl = struct {
                fn parse(input: I, context: ?[]align(16) u8) ParserResult {
                    return @call(.{ .modifier = .always_inline }, parser, .{ input, @ptrCast(*@TypeOf(data), context.?.ptr).* });
                }
            };

            return .{
                .delegatedData = delegatedData,
                .allocator = allocator,
                .parser = parserImpl.parse,
            };
        }

        pub fn invoke(self: *const Self, input: I) ParserResult {
            defer self.deinit();
            return try self.parser(input, self.delegatedData);
        }

        pub fn deinit(self: Self) void {
            if (self.delegatedData) |delegatedData| {
                self.allocator.?.free(delegatedData);
            }
        }
    };
}

pub fn Parser(comptime I: type, comptime O: type, comptime R: type) type {
    return struct {
        const Self = @This();
        pub const ResultTuple = struct { output: O, remain: R };
        pub const ParserResult = ParserError!ResultTuple;
        pub const ParserFunction = *const fn (I, ?[]align(16) u8) ParserResult;

        delegatedData: ?[]align(16) u8,
        allocator: ?Allocator,
        parser: ParserFunction,

        pub fn initImmediate(parser: ParserFunction) Self {
            return .{
                .delegatedData = null,
                .allocator = null,
                .parser = parser,
            };
        }

        pub fn initDelegated(allocator: Allocator, data: anytype, parser: ParserFunction) !Self {
            const T = @TypeOf(data);
            const delegatedData = try allocator.alignedAlloc(u8, 16, @sizeOf(T));
            errdefer allocator.free(delegatedData);
            @ptrCast(*T, delegatedData.ptr).* = data;

            return .{
                .delegatedData = delegatedData,
                .allocator = allocator,
                .parser = parser,
            };
        }

        pub fn invoke(self: *const Self, input: I) ParserResult {
            defer self.deallocateData();
            return try self.parser(input, self.delegatedData);
        }

        fn deallocateData(self: *const Self) void {
            if (self.delegatedData) |delegatedData| {
                self.allocator.?.free(delegatedData);
            }
        }
    };
}

pub fn castDeref(comptime T: type, dataSlice: ?[]align(16) u8) ?T {
    if (dataSlice) |slice| {
        return @ptrCast(*T, slice.ptr).*;
    } else {
        return null;
    }
}
