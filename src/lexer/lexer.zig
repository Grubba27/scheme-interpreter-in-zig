const std = @import("std");
const ascii = std.ascii;
const allocator = std.heap.page_allocator;
const test_allocator = std.testing.allocator;
const ArrayList = std.ArrayList;
const AllocationError = error{OutOfMemory};
const mem = std.mem;
pub const tokens = enum {
    syntax, // like ( or )
    identifier, // like a or b
    number, // like 1 or 2
};

pub const Token = struct {
    kind: tokens,
    location: usize,
    value: []u8,
    current_location: ?usize,
};

pub fn getIdentifierToken(source: []const u8, cursor: usize) AllocationError!Token {
    var original_cursor = cursor;
    var curr_cursor = cursor;

    var acc = ArrayList(u8).init(allocator);
    defer acc.deinit();

    while (curr_cursor < source.len) {
        var c = source[curr_cursor];
        if (!ascii.isWhitespace(c)) {
            try acc.append(c); // acc = acc ++ c;
            curr_cursor += 1;
        }
        break;
    }
    return Token{ .kind = tokens.identifier, .location = original_cursor, .value = acc.items, .current_location = curr_cursor };
}

pub fn getIntegerToken(source: []const u8, cursor: usize) AllocationError!Token {
    var original_cursor = cursor;
    var ret_cursor = cursor;
    var acc = ArrayList(u8).init(test_allocator);
    defer acc.deinit();

    std.debug.print("acc: {any}\n", .{acc.items.len});
    std.debug.print("cursor: {any}\n", .{cursor});
    std.debug.print("source: {s}\n", .{source});
    std.debug.print("source[cursor]: {any}\n", .{source.len});

    while (ret_cursor < source.len) {
        var c = source[ret_cursor];
        std.debug.print("letter: {s}\n", .{acc.items});
        std.debug.print("len {any}\n", .{ret_cursor});
        if (ascii.isDigit(c)) {
            try acc.append(c); // acc = acc ++ c;
            ret_cursor += 1;
        } else {
            break;
        }
    }

    return Token{ .kind = tokens.number, .location = original_cursor, .value = acc.items, .current_location = ret_cursor };
}

pub fn getSintaxToken(source: []const u8, cursor: usize) Token {
    if (source[cursor] == '(' or source[cursor] == ')') {
        return Token{ .kind = tokens.syntax, .location = cursor, .value = source[cursor .. cursor + 1], .current_location = cursor + 1 };
    }
    return Token{ .kind = tokens.syntax, .location = cursor, .value = "", .current_location = cursor + 1 };
}
pub fn eatWhitespace(source: []const u8, cursor: usize) usize {
    while (cursor < source.len) {
        var c = source[cursor];
        if (!ascii.isWhitespace(c)) {
            break;
        }
        cursor += 1;
    }
    return cursor;
}

pub fn lex(source: []const u8) AllocationError![]Token {
    var token_list = ArrayList(Token).init(allocator);
    defer token_list.deinit();

    var cursor: usize = 0;
    while (cursor < source.len) {
        cursor = eatWhitespace(source, cursor);
        if (cursor == source.len) {
            break;
        }
        const identifier_token = try getIdentifierToken(source, cursor);
        if (identifier_token.value.len != 0) {
            token_list.append(identifier_token);
            cursor = identifier_token.current_location;
            continue;
        }
        const integer_token = try getIntegerToken(source, cursor);
        if (integer_token.value.len != 0) {
            token_list.append(integer_token);
            cursor = integer_token.current_location;
            continue;
        }
        const sintax_token = getSintaxToken(source, cursor);
        if (sintax_token.value.len != 0) {
            token_list.append(sintax_token);
            cursor = sintax_token.current_location;
            continue;
        }
        std.debug.print("Error: Unexpected token at {d}\n", .{cursor});
    }
    return token_list;
}
pub fn printFileContent(file_content: []const u8) void {
    std.debug.print("{s}\n", .{file_content});
}
