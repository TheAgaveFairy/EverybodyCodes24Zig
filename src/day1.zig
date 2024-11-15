const std = @import("std");

fn charToValue(c: u8) !usize {
    return switch (c) {
        'A' => 0,
        'B' => 1,
        'C' => 3,
        'D' => 5,
        'x' => 0,
        else => error.BadChar,
    };
}

fn partOne(allocator: std.mem.Allocator) !usize {
    const inputfilename = "../inputs/everybody_codes_e2024_q01_p1.txt";
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
    const p2_inputfilename = "../inputs/everybody_codes_e2024_q01_p2.txt";
    var infile = try std.fs.cwd().openFile(p2_inputfilename, .{});
    defer infile.close();

    const reader = infile.reader();
    var potions: usize = 0;

    while (true) {
        const pair: [2]u8 = readPair(reader) catch |err| switch (err) {
            error.EndOfStream => break,
            error.IncompletePair => {
                std.debug.print("Incomplete pair at end.\n", .{});
                break;
            },
            else => unreachable,
        };
        //std.debug.print("Got pair: {c}{c}.\n", .{pair[0], pair[1]});
        
        potions += try charToValue(pair[0]);
        potions += try charToValue(pair[1]);
        potions += 2;
        if (pair[0] == 'x' or pair[1] == 'x') {
            potions -= 2;
        }
    }
    return potions;
}

fn readTrio(reader: anytype) ![3]u8 {
    var trio: [3]u8 = undefined;
    const bytes_read = try reader.readAll(&trio);
    
    return switch (bytes_read) {
        0 => error.EndOfStream, // could've done null here since Zig isn't ass about nulls with forced error handling
        1 => error.IncompleteTrio,
        2 => error.IncompleteTrio,
        3 => trio,
        else => unreachable,
    };
}

fn partThree() !usize {
    const p3_inputfilename = "../inputs/everybody_codes_e2024_q01_p3.txt";
    var infile = try std.fs.cwd().openFile(p3_inputfilename, .{});
    defer infile.close();

    const reader = infile.reader();
    var potions: usize = 0;

    while (true) {
        const trio: [3]u8 = readTrio(reader) catch |err| switch (err) {
            error.EndOfStream => break,
            error.IncompleteTrio => {
                std.debug.print("Incomplete trio at end.\n", .{});
                break;
            },
            else => unreachable,
        };
        std.debug.print("Got trio: {c}{c}{c}.\n", .{trio[0], trio[1], trio[2]});
        
        var xs: usize = 0;
        for (trio) |t| {
            potions += try charToValue(t);
            if (t == 'x') xs += 1;
        }
        const extra_potions: usize = switch (xs) {
            0 => 6, // two extra potions per creature in a trio attack
            1 => 2, // one extra per creature in a duo attack
            else => 0,
        };
        potions += extra_potions;
    }
    return potions;
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
    
    const part_three_answer = try partThree();
    std.debug.print("Part Three Answer: {}!\n", .{part_three_answer});
}
