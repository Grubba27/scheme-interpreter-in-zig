const std = @import("std");
const lexer = @import("src/lexer/lexer.zig");
const process = std.process;
const fs = std.fs;

fn printFileContent(file_content: []const u8) void {
    std.debug.print("{s}\n", .{file_content});
}

pub fn main() !void {
    const filepath = try getFirstArg();
    const file = try getFileContent(filepath);
    const file_content = file.contents[0..file.len];
    lexer.printFileContent(file_content);
}

const CLIErrs = error{
    FileNotFound,
    ArgumentNotFound,
};

const File = struct {
    len: usize,
    contents: [1024]u8,
};

pub fn getFileContent(filename: []const u8) CLIErrs!File {
    const file = fs.cwd().openFile(filename, .{}) catch {
        std.debug.print("Error opening file\n", .{});
        return CLIErrs.FileNotFound;
    };
    defer file.close();
    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var file_contents: [1024]u8 = undefined;
    const file_len = in_stream.read(file_contents[0..]) catch {
        std.debug.print("Error reading file\n", .{});
        return CLIErrs.FileNotFound;
    };
    return File{ .len = file_len, .contents = file_contents };
}
pub fn getFirstArg() CLIErrs![]const u8 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var args = try process.argsWithAllocator(allocator);
    defer args.deinit();
    _ = args.next();
    const filename = args.next() orelse {
        std.debug.print("Expected filename argument.\n", .{});
        return CLIErrs.ArgumentNotFound;
    };
    return filename;
}
