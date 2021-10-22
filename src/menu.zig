const std = @import("std");
const engine = @import("./engine.zig");

// this is intended for storing data for the whole UI session
var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);

const Urc = []const u8;
var menuCache = std.StringHashMap(Urc).init(&arena.allocator);
var menuStack = std.ArrayList(*Urc).init(&arena.allocator);


pub fn setMenu(name: []const u8) isize {
    pushMenu(name) catch return -1;
    engine.keyCatchUI();
    return 0;
}

pub fn shutdown() void {
    menuCache.deinit();
    arena.deinit();
}

pub fn pushMenu(name: []const u8) !void {
    const cacheEntry = try menuCache.getOrPut(name);
    if (cacheEntry.found_existing == false) {
        cacheEntry.value_ptr.* = try loadUrc(name);
    }

    try menuStack.append(cacheEntry.value_ptr);
    engine.println(cacheEntry.value_ptr.*);
}

fn loadUrc(name: []const u8) !Urc {
    var file = try engine.File.open(name);
    defer file.close();

    const urc = try file.read();
    return urc;
}
