const engine = @import("./engine.zig");
const menu = @import("./menu.zig");

pub const ApiVersion = 6;

pub fn init() isize {
    engine.printlnF("ZIG UI Initialising {}.", .{99});

    return 0;
}

pub fn shutdown() isize {
    engine.println("ZIG UI shut down.");

    menu.shutdown();

    return 0;
}

pub fn keyEvent(key: c_int) isize {
    _ = key;
    return 0;
}

pub fn mouseEvent(dx: c_int, dy: c_int) isize {
    _ = dx;
    _ = dy;
    return 0;
}

pub fn refresh(time: c_int) isize {
    _ = time;
    return 0;
}

pub fn isFullscreen() isize {
    return 1;
}

pub fn setActiveMenu(menuType: c_int) isize {
    const mt = @intToEnum(UiMenuCommand_t, menuType);

    const ret = switch (mt) {
        .UIMENU_NONE => 0,
        .UIMENU_MAIN => menu.setMenu("main"),
        else => 0,
    };

    return ret;
}

const UiMenuCommand_t = enum(c_int) { UIMENU_NONE, UIMENU_MAIN, UIMENU_INGAME, UIMENU_NEED_CD, UIMENU_BAD_CD_KEY, UIMENU_TEAM, UIMENU_POSTGAME };

pub fn consoleCommand(realtime: c_int) isize {
    _ = realtime;
    return 0;
}

pub fn drawConnectScreen(overlay: c_int) isize {
    _ = overlay;
    return 0;
}
