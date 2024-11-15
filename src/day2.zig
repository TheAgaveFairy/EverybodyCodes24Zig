const std = @import("std");

fn countMatches(keys: []const []const u8, text: []const u8) usize {
    var total_matches: usize = 0;

    var i: usize = 0;
    while (i < text.len) : (i += 1) {
        for (keys) |key| { // alternatively we could iterate through the possible lengths of the keys (2,3) and match those substrings. this would take us from Theta(number of keys) to O(number of keys).
            if (i + key.len > text.len) continue;
            if (std.mem.eql(u8, text[i..i+key.len], key)) total_matches += 1;
        }
    }
    return total_matches;
}

fn partOne(allocator: std.mem.Allocator) !usize {
    const infile = "../inputs/everybody_codes_e2024_q02_p1.txt";
    const file = try std.fs.cwd().openFile(infile, .{});
    defer file.close();
    
    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [2048]u8 = undefined; 

    const keys_line_buf = try in_stream.readUntilDelimiter(&buf, '\n');
    //std.debug.print("keys_line {s}\n", .{keys_line});
    var keys_line = try allocator.alloc(u8, keys_line_buf.len);
    defer allocator.free(keys_line);
    @memcpy(keys_line, keys_line_buf);

    _ = try in_stream.readUntilDelimiter(&buf, '\n');
    const text_line = try in_stream.readUntilDelimiterOrEof(&buf, '\n') orelse unreachable;
    
    var keys = std.ArrayList([]const u8).init(allocator);
    defer keys.deinit();

    for (keys_line, 0..) |c, i| {
        std.debug.print("byte {}: {c} ({d})\n", .{i,c,c});
    }

    const after_prefix = std.mem.indexOfScalar(u8, keys_line, ':') orelse return error.InvalidFormat;
    var keys_iter = std.mem.splitScalar(u8, keys_line[after_prefix + 1 ..], ',');
    while (keys_iter.next()) |key| {
        try keys.append(key);
    }

    return countMatches(keys.items, text_line);
}

pub fn main() !void {
    //const stdout_file = std.io.getStdOut().writer();
    //var bw = std.io.bufferedWriter(stdout_file);
    //const stdout = bw.writer();

    //try stdout.print("Run `zig build test` to run the tests.\n", .{});
    //try bw.flush(); // Don't forget to flush!

    //var buf_reader = std.io.bufferedReader(infile);
    //var in_stream = buf_reader.reader():
    //var buf: [256]u8 = undefined;
    //while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
    
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};    
    defer _ = gpa.deinit();
    const allocator = gpa.allocator(); 

    const part_one_answer = try partOne(allocator);   
    std.debug.print("Part One Answer: {}!\n", .{part_one_answer});

}
