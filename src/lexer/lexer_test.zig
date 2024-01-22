const lexer = @import("lexer.zig");
const std = @import("std");
const testing = std.testing;

test "lexer getIntegerToken" {
    const Test = struct {
        source: []const u8,
        cursor: usize,
        expectedValue: []const u8,
        exprectedCursor: usize,
    };
    const test_list: [3]Test = .{
        Test{
            .source = "foo 123",
            .cursor = 4,
            .expectedValue = "123",
            .exprectedCursor = 7,
        },
        Test{
            .source = "foo 12 3",
            .cursor = 4,
            .expectedValue = "12",
            .exprectedCursor = 6,
        },
        Test{
            .source = "foo 12a 3",
            .cursor = 4,
            .expectedValue = "12",
            .exprectedCursor = 6,
        },
    };

    for (test_list) |test_case| {
        const source = test_case.source;
        var cursor = test_case.cursor;
        const expectedValue = test_case.expectedValue;
        const expectedCursor = test_case.exprectedCursor;
        std.debug.print("source: {s}, cursor: {any}, expectedValue: {s}, expectedCursor: {any}\n", .{ source, cursor, expectedValue, expectedCursor });
        const token = try lexer.getIntegerToken(source, cursor);
        try testing.expectEqualStrings(token.value, expectedValue);
        try testing.expectEqual(token.location, expectedCursor);
    }
}

test "lexer getIdentifierToken" {
    const Test = struct {
        source: []const u8,
        cursor: usize,
        expectedValue: []const u8,
        exprectedCursor: usize,
    };
    const test_list: [2]Test = .{
        Test{
            .source = "123 ab + ",
            .cursor = 4,
            .expectedValue = "ab",
            .exprectedCursor = 6,
        },
        Test{
            .source = "123 ab123 + ",
            .cursor = 4,
            .expectedValue = "ab123",
            .exprectedCursor = 9,
        },
    };

    for (test_list) |test_case| {
        const source = test_case.source;
        const cursor = test_case.cursor;
        const expectedValue = test_case.expectedValue;
        const expectedCursor = test_case.exprectedCursor;
        const token = try lexer.getIdentifierToken(source, cursor);
        try testing.expectEqualStrings(token.value, expectedValue);
        try testing.expectEqual(token.location, expectedCursor);
    }
}

// test "lexer" {
//     const _source = @as([]u8, " ( add 13 2  )");
//     const Test = struct {
//         source: []u8,
//         expectedTokens: [5]lexer.Token,
//     };
//     const test_list: [1]Test = .{Test{
//         .source = _source,
//         .expectedTokens = .{
//             lexer.Token{ .value = "(", .kind = lexer.tokens.syntax, .location = 1, .current_location = null },
//             lexer.Token{ .value = "add", .kind = lexer.tokens.identifier, .location = 3, .current_location = null },
//             lexer.Token{ .value = "13", .kind = lexer.tokens.number, .location = 7, .current_location = null },
//             lexer.Token{ .value = "2", .kind = lexer.tokens.number, .location = 10, .current_location = null },
//             lexer.Token{ .value = ")", .kind = lexer.tokens.syntax, .location = 12, .current_location = null },
//         },
//     }};
//     for (test_list) |test_suite| {
//         const source = test_suite.source;
//         const expectedTokens = test_suite.expectedTokens;
//         const tokens = try lexer.lex(source);
//         try testing.expectEqual(tokens.len, expectedTokens.len);
//         for (tokens, 0..) |token, i| {
//             const expectedToken = expectedTokens[i];
//             try testing.expectEqualStrings(token.value, expectedToken.value);
//             try testing.expectEqual(token.kind, expectedToken.kind);
//             try testing.expectEqual(token.location, expectedToken.location);
//         }
//     }
// }
