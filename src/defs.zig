const std = @import("std");

pub const ParserError = error{
    IncompleteData,
    InvalidData,
};

pub fn ParserResult(comptime O: type, comptime R: type) type {
    return ParserError!struct { output: O, remain: R };
}

/// An ImmediateParser is used to simple parsing operation without any context requirement.
pub fn ImmediateParser(comptime I: type, comptime O: type, comptime R: type) type {
    return struct {
        parser: *const fn (I) ParserResult(O, R),

        pub fn invoke(self: *const ImmediateParser(I, O, R), input: I) ParserResult(O, R) {
            return try self.parser(input);
        }
    };
}

pub fn new_immediate_parser(comptime I: type, comptime O: type, comptime R: type, parser: *const fn (I) ParserResult(O, R)) ImmediateParser(I, O, R) {
    return ImmediateParser(I, O, R){ .parser = parser };
}

/// A DelegateParser is used to operate more complicate parsing operation that requires runtime context.
pub fn DelegateParser(comptime I: type, comptime O: type, comptime R: type, comptime D: type) type {
    return struct {
        delegated_data: D,
        parser: *const fn (D, I) ParserResult(O, R),

        pub fn invoke(self: *const DelegateParser(I, O, R, D), input: I) ParserResult(O, R) {
            return try self.parser(self.delegated_data, input);
        }
    };
}

pub fn new_delegate_parser(comptime I: type, comptime O: type, comptime R: type, comptime D: type, delegated_data: D, parser: *const fn (I) ParserResult(O, R)) DelegateParser(I, O, R, D) {
    return DelegateParser(I, O, R, D){
        .delegated_data = delegated_data,
        .parser = parser,
    };
}
