const std = @import("std");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};

///
/// Engine syscalls
///

const UiImport_t = enum(usize) { UI_ERROR, UI_PRINT, UI_MILLISECONDS, UI_CVAR_SET, UI_CVAR_VARIABLEVALUE, UI_CVAR_VARIABLESTRINGBUFFER, UI_CVAR_SETVALUE, UI_CVAR_RESET, UI_CVAR_CREATE, UI_CVAR_INFOSTRINGBUFFER, UI_ARGC, UI_ARGV, UI_CMD_EXECUTETEXT, UI_FS_FOPENFILE, UI_FS_READ, UI_FS_WRITE, UI_FS_FCLOSEFILE, UI_FS_GETFILELIST, UI_R_REGISTERMODEL, UI_R_REGISTERSKIN, UI_R_REGISTERSHADERNOMIP, UI_R_CLEARSCENE, UI_R_ADDREFENTITYTOSCENE, UI_R_ADDPOLYTOSCENE, UI_R_ADDLIGHTTOSCENE, UI_R_RENDERSCENE, UI_R_SETCOLOR, UI_R_DRAWSTRETCHPIC, UI_UPDATESCREEN, UI_CM_LERPTAG, UI_CM_LOADMODEL, UI_S_REGISTERSOUND, UI_S_STARTLOCALSOUND, UI_KEY_KEYNUMTOSTRINGBUF, UI_KEY_GETBINDINGBUF, UI_KEY_SETBINDING, UI_KEY_ISDOWN, UI_KEY_GETOVERSTRIKEMODE, UI_KEY_SETOVERSTRIKEMODE, UI_KEY_CLEARSTATES, UI_KEY_GETCATCHER, UI_KEY_SETCATCHER, UI_GETCLIPBOARDDATA, UI_GETGLCONFIG, UI_GETCLIENTSTATE, UI_GETCONFIGSTRING, UI_LAN_GETPINGQUEUECOUNT, UI_LAN_CLEARPING, UI_LAN_GETPING, UI_LAN_GETPINGINFO, UI_CVAR_REGISTER, UI_CVAR_UPDATE, UI_MEMORY_REMAINING, UI_GET_CDKEY, UI_SET_CDKEY, UI_R_REGISTERFONT, UI_R_MODELBOUNDS, UI_PC_ADD_GLOBAL_DEFINE, UI_PC_LOAD_SOURCE, UI_PC_FREE_SOURCE, UI_PC_READ_TOKEN, UI_PC_SOURCE_FILE_AND_LINE, UI_S_STOPBACKGROUNDTRACK, UI_S_STARTBACKGROUNDTRACK, UI_REAL_TIME, UI_LAN_GETSERVERCOUNT, UI_LAN_GETSERVERADDRESSSTRING, UI_LAN_GETSERVERINFO, UI_LAN_MARKSERVERVISIBLE, UI_LAN_UPDATEVISIBLEPINGS, UI_LAN_RESETPINGS, UI_LAN_LOADCACHEDSERVERS, UI_LAN_SAVECACHEDSERVERS, UI_LAN_ADDSERVER, UI_LAN_REMOVESERVER, UI_CIN_PLAYCINEMATIC, UI_CIN_STOPCINEMATIC, UI_CIN_RUNCINEMATIC, UI_CIN_DRAWCINEMATIC, UI_CIN_SETEXTENTS, UI_R_REMAP_SHADER, UI_VERIFY_CDKEY, UI_LAN_SERVERSTATUS, UI_LAN_GETSERVERPING, UI_LAN_SERVERISVISIBLE, UI_LAN_COMPARESERVERS, UI_FS_SEEK, UI_SET_PBCLSTATUS, UI_MEMSET = 100, UI_MEMCPY, UI_STRNCPY, UI_SIN, UI_COS, UI_ATAN2, UI_SQRT, UI_FLOOR, UI_CEIL };

// syscall function signature
const SyscallFn = fn (UiImport_t, ...) callconv(.C) isize;

// syscalls are the entry point to the engine functions
var syscall: ?SyscallFn = null;

// set the callback pointer so we can use engine functions
pub fn setSyscallptr(ptr: usize) void {
    syscall = @intToPtr(SyscallFn, ptr);
}

///
/// Printing
///

fn err(s: [:0]const u8) void {
    _ = syscall.?(.UI_ERROR, s.ptr);
}

fn print(s: [:0]const u8) void {
    _ = syscall.?(.UI_PRINT, s.ptr);
}

pub fn errorln(s: []const u8) void {
    const str = std.fmt.allocPrintZ(&gpa.allocator, "{s}\n", .{ s }) catch "errorln error.\n";
    defer gpa.allocator.free(str);
    err(str);
    @panic(str);
}

pub fn println(s: []const u8) void {
    printlnF( "{s}", .{ s });
}

pub fn printlnF(comptime fmt: []const u8, args: anytype) void {
    const str = std.fmt.allocPrintZ(&gpa.allocator, "^2" ++ fmt ++ "\n", args) catch "printlnF error.\n";
    defer gpa.allocator.free(str);
    print(str);
}

///
/// Key catching
///

const KEYCATCH_UI = 2;

pub fn keyIsCatchUI() bool {
    (keyGetCatcher() & KEYCATCH_UI) != 0;
}

pub fn keyCatchUI() void {
    const catcher = keyGetCatcher() | KEYCATCH_UI;
    keySetCatcher(catcher);
}

fn keyGetCatcher() c_int {
    const result = syscall.?(.UI_KEY_GETCATCHER);
    return @intCast(c_int, result);
}

fn keySetCatcher(catcher: c_int) void {
    _ = syscall.?(.UI_KEY_SETCATCHER, catcher);
}

///
/// File system
///

const fileHandle_t = i32;

const fsMode_t = enum(c_int) {
    FS_READ,
    FS_WRITE,
    FS_APPEND,
    FS_APPEND_SYNC
};

const fsOrigin_t = enum(c_int) {
    FS_SEEK_CUR,
    FS_SEEK_END,
    FS_SEEK_SET
};

fn openFile(qpath : [:0]const u8, f : *fileHandle_t, mode : fsMode_t) isize {
    const length = syscall.?(.UI_FS_FOPENFILE, qpath.ptr, f, mode);
    return length;
}

fn closeFile(f : fileHandle_t) void {
    _ = syscall.?(.UI_FS_FCLOSEFILE, f);
}

fn readFile(len : usize, f : fileHandle_t) ![]u8 {
    const buffer = try gpa.allocator.alloc(u8, len);

    _ = syscall.?(.UI_FS_READ, buffer.ptr, len, f);
    // FIXME: the engine does not tell us how many bytes were actually read!

    return buffer;
}

pub const FileError = error {
    CouldNotOpen,
};

pub const File = struct {
    fileHandle : fileHandle_t,
    length : isize,

    pub fn open(name : []const u8) !File {
        const nameZ = try gpa.allocator.dupeZ(u8, name);
        defer gpa.allocator.free(nameZ);
        var f = File {
            .fileHandle = undefined,
            .length = undefined,
        };
        f.length = openFile(nameZ, &f.fileHandle, .FS_READ);
        if (f.length < 0 or f.fileHandle == 0)
            return FileError.CouldNotOpen;
        return f;
    }

    pub fn close(self: File) void {
        closeFile(self.fileHandle);
    }

    pub fn read(self: File) ![]const u8 {
        return readFile(@intCast(usize, self.length), self.fileHandle);
    }
};
