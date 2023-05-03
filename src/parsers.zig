const std = @import("std");
const Allocator = std.mem.Allocator;

/// ParserError represents a set of invalid states of `Parser`'s parser function.
pub const ParserError = error{
    IncompleteData,
    InvalidData,
};

/// Parser is a general purpose struct to parse a series of data with predefined context and parser function.
///
/// ## Type Parameters
/// `I`: Input type
/// `O`: Output type (or transformed type)
/// `R`: Remaining type
///
/// ## Allocator and context data
///
/// Due to the implementation limitation, to discard additional generic type from `Parser` struct and stores,
/// context data, `Parser` requires an `Allocator` to store context data onto heap, this is only required when
/// context data is not void.
///
/// To avoid multiple `Parser` instance initialization, `Parser` does not free context data on invocation of
/// `Parser#parse(Self, I) ParserResult`, instead, `Parser` has function `deinit` to allow user manually decide
/// when to free the context data.
///
/// This could be handy when a `Parser` is used in different functions, we suggest using an `ArenaAllocator` with
/// `GeneralPurposeAllocator` as child allocator, to free at once without any safety issue; or using an
/// `ArenaAllocator` with `c_allocator` as child allocator to speed up allocation.
///
/// ## Design notes
///
/// This implementation has multiple benefits:
/// 1. Chaining multiple parsers that accepts same types is possible (without designating the context data type)
/// 2. Parser function is defined in a user friendly way so user don't have to cast a pointer into desired context
///    data type.
///
/// But also comes with several limitations:
/// 1. Due to safety and implementation, context data type and parser function must be known at compile time.
pub fn Parser(comptime I: type, comptime O: type, comptime R: type) type {
    return struct {
        const Self = @This();
        pub const ResultTuple = struct { output: O, remain: R };
        pub const ParserResult = ParserError!ResultTuple;
        pub const ParserFunction = *const fn (I, ?[]align(16) u8) ParserResult;

        parserCtx: ?[]align(16) u8,
        allocator: ?Allocator,
        parser: ParserFunction,

        /// Inits `Parser` by specifying type of `parserCtx`.
        pub fn initByType(comptime T: type, allocator: Allocator, comptime parserCtx: T, comptime parser: *const fn (I, T) ParserResult) Allocator.Error!Self {
            return Self.init(allocator, parserCtx, parser);
        }

        /// Inits `Parser` without any predefined context.
        pub fn initImmediateCtx(comptime parser: *const fn (I, void) ParserResult) Self {
            const parserImpl = struct {
                fn parse(input: I, _: ?[]align(16) u8) ParserResult {
                    return @call(.{ .modifier = .always_inline }, parser, .{ input, void{} });
                }
            };

            return .{
                .parserCtx = null,
                .allocator = null,
                .parser = parserImpl.parse,
            };
        }

        pub fn init(allocator: Allocator, comptime parserCtx: anytype, comptime parser: *const fn (I, @TypeOf(parserCtx)) ParserResult) Allocator.Error!Self {
            const T = @TypeOf(parserCtx);
            const parserCtxSlice = try allocator.alignedAlloc(u8, 16, @sizeOf(T));
            errdefer allocator.free(parserCtxSlice);
            @ptrCast(*T, parserCtxSlice.ptr).* = parserCtx;

            const parserImpl = struct {
                fn parse(input: I, context: ?[]align(16) u8) ParserResult {
                    return @call(.{ .modifier = .always_inline }, parser, .{ input, @ptrCast(*@TypeOf(parserCtx), context.?.ptr).* });
                }
            };

            return .{
                .parserCtx = parserCtxSlice,
                .allocator = allocator,
                .parser = parserImpl.parse,
            };
        }

        pub fn parse(self: *const Self, input: I) ParserResult {
            return try self.parser(input, self.parserCtx);
        }

        pub fn deinit(self: Self) void {
            if (self.parserCtx) |parserCtx| {
                self.allocator.?.free(parserCtx);
            }
        }
    };
}
