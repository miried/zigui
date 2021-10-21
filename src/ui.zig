const std = @import("std");
const engine = @import("./engine.zig");

pub const ApiVersion = 6;

// this is intended for storing data for the whole UI session
var arena: std.heap.ArenaAllocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
var allocator: std.mem.Allocator = arena.allocator;

pub fn init() usize {
    engine.printlnF("ZIG UI Initialising {}.", .{ 99 });

    return 0;
}

pub fn shutdown() usize {
    engine.println("ZIG UI shut down.");

    arena.deinit();

    return 0;
}

pub fn keyEvent(key: c_int) usize {
    _ = key;
    return 0;
}

pub fn mouseEvent(dx: c_int, dy: c_int) usize {
    _ = dx;
    _ = dy;
    return 0;
}

pub fn refresh( time: c_int ) usize {
    _ = time;
    return 0;
}

pub fn isFullscreen() usize {
    return 0;
}

fn setMainMenu() usize {
    return 0;
}

pub fn setActiveMenu( menu: c_int ) usize {
    const menuType = @intToEnum(UiMenuCommand_t, menu);

    const ret = switch (menuType) {
        .UIMENU_NONE => 0,
        .UIMENU_MAIN => setMainMenu(),
        else => 0,
    };

    return ret;
}

const UiMenuCommand_t = enum(c_int) {
    UIMENU_NONE,
    UIMENU_MAIN,
    UIMENU_INGAME,
    UIMENU_NEED_CD,
    UIMENU_BAD_CD_KEY,
    UIMENU_TEAM,
    UIMENU_POSTGAME
};

pub fn consoleCommand(realtime: c_int) usize {
    _ = realtime;
    return 0;
}

pub fn drawConnectScreen( overlay: c_int) usize {
    _ = overlay;
    return 0;
}
