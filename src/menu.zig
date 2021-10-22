const std = @import("std");
const engine = @import("./engine.zig");

// this is intended for storing data for the whole UI session
var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);

const Urc = []const u8;
var menuCache = std.StringHashMap(Urc).init(&arena.allocator);
var menuStack = std.ArrayList(*Urc).init(&arena.allocator);

// const Vec3 = struct { x: f32, y: f32, z: f32 };

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
        cacheEntry.value_ptr.* = loadUrc(name);
    }

    try menuStack.append(cacheEntry.value_ptr);
    engine.println(name);
}

fn loadUrc(name: []const u8) Urc {
    return name;
}
