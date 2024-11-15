const std = @import("std");

const inputfilename = "../inputs/everybody_codes_e2024_q01_p1.txt";

fn partOne(allocator: std.mem.Allocator) !usize {

    var infile = try std.fs.cwd().openFile(inputfilename, .{});
    defer infile.close();

    const reader = infile.reader();
    var char_freq = std.AutoHashMap(u8, usize).init(allocator);
    defer char_freq.deinit();

    while (true) {
        const byte = reader.readByte() catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };
        
        const result = try char_freq.getOrPut(byte);
        if (!result.found_existing) {
            result.value_ptr.* = 0;
        }
        result.value_ptr.* += 1;
    }

    var it = char_freq.iterator();
    while (it.next()) |entry| {
        const char = entry.key_ptr.*;
        const count = entry.value_ptr.*;

        if(std.ascii.isPrint(char)) {
            std.debug.print("Character {c} appears {} times.\n", .{char, count});
        } else {
            std.debug.print("Non-ASCII 0x{x} appears {} times.\n", .{char, count});
        }
    }
    std.debug.print("Total unique chars: {}.\n", .{char_freq.count()});

    const ancient_ant: usize = char_freq.get('A') orelse 0;
    const badass_beetle: usize = char_freq.get('B') orelse 0;
    const creepy_cockroach: usize = char_freq.get('C') orelse 0;
    //const diabolical_dragonfly: usize = char_freq.get('D') orelse 0;    

    const answer = 0 * ancient_ant + 1 * badass_beetle + 3 * creepy_cockroach;
    return answer;
}

fn readPair(reader: anytype) ![2]u8 {
    var pair: [2]u8 = undefined;
    const bytes_read = try reader.readAll(&pair);
    
    return switch (bytes_read) {
        0 => error.EndOfStream, // could've done null here since Zig isn't ass about nulls with forced error handling
        1 => error.IncompletePair,
        2 => pair,
        else => unreachable,
    };
}

fn partTwo() !usize {
    var infile = try std.fs.cwd().openFile(inputfilename, .{});
    defer infile.close();

    const reader = infile.reader();
    while (true) {
        const pair: [2]u8 = try readPair(reader) catch |err| switch (err) {
            error.EndOfStream => break,
            error.IncompletePair => {
                std.debug.print("Incomplete pair at end.\n", .{});
                break;
            },
            else => unreachable,
        };
        std.debug.print("Got pair: {c}{c}.\n", .{pair[0], pair[1]});
    }
    return 69;
}

pub fn main() !void {
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

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

    const part_two_answer = try partTwo();
    std.debug.print("Part Two Answer: {}!\n", .{part_two_answer});
}
