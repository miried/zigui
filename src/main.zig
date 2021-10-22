const engine = @import("./engine.zig");
const ui = @import("./ui.zig");

export fn dllEntry(syscallptr: usize) void {
    engine.setSyscallptr(syscallptr);
}

export fn vmMain(command: c_int, arg0: c_int, arg1: c_int, _: c_int, _: c_int, _: c_int, _: c_int, _: c_int, _: c_int, _: c_int, _: c_int, _: c_int, _: c_int) isize {
    const cmd = @intToEnum(UiExport_t, command);
    const ret = switch (cmd) {
        .UI_GETAPIVERSION => ui.ApiVersion,
        .UI_INIT => ui.init(),
        .UI_SHUTDOWN => ui.shutdown(),
        .UI_KEY_EVENT => ui.keyEvent(arg0),
        .UI_MOUSE_EVENT => ui.mouseEvent(arg0, arg1),
        .UI_REFRESH => ui.refresh(arg0),
        .UI_IS_FULLSCREEN => ui.isFullscreen(),
        .UI_SET_ACTIVE_MENU => ui.setActiveMenu(arg0),
        .UI_CONSOLE_COMMAND => ui.consoleCommand(arg0),
        .UI_DRAW_CONNECT_SCREEN => ui.drawConnectScreen(arg0),
        .UI_HASUNIQUECDKEY => 0,
    };
    return ret;
}

const UiExport_t = enum(c_int) {
    UI_GETAPIVERSION,
    //  system reserved
    UI_INIT,
    //	void	UI_Init( void );
    UI_SHUTDOWN,
    //	void	UI_Shutdown( void );
    UI_KEY_EVENT,
    //	void	UI_KeyEvent( int key );
    UI_MOUSE_EVENT,
    //	void	UI_MouseEvent( int dx, int dy );
    UI_REFRESH,
    //	void	UI_Refresh( int time );
    UI_IS_FULLSCREEN,
    //	qboolean UI_IsFullscreen( void );
    UI_SET_ACTIVE_MENU,
    //	void	UI_SetActiveMenu( uiMenuCommand_t menu );
    UI_CONSOLE_COMMAND,
    //	qboolean UI_ConsoleCommand( int realTime );
    UI_DRAW_CONNECT_SCREEN,
    //	void	UI_DrawConnectScreen( qboolean overlay );
    UI_HASUNIQUECDKEY,
};
