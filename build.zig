const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const opengl = b.option(bool, "opengl", "enables opengl") orelse true;

    const mod = b.addModule("RGFW", .{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .root_source_file = b.path("root.zig")
    });
    mod.addIncludePath(b.path("."));

    if (opengl) mod.addCMacro("RGFW_OPENGL", "");

    switch (target.result.os.tag) {
        .linux, .freebsd, .openbsd, .dragonfly => {
            mod.linkSystemLibrary("x11", .{.needed = true});
            mod.linkSystemLibrary("xrandr", .{.needed = true});
            if (opengl) mod.linkSystemLibrary("GL", .{.needed = true});
        },
        .macos => {
            mod.linkFramework("CoreVideo", .{.needed = true});
            mod.linkFramework("Cocoa", .{.needed = true});
            mod.linkFramework("IOKit", .{.needed = true});
            if (opengl) mod.linkFramework("OpenGL", .{.needed = true});
        },
        .windows => {
            mod.linkSystemLibrary("gdi32", .{.needed = true});
            if (opengl) mod.linkSystemLibrary("opengl32", .{.needed = true});
        },
        else => {}
    }
}
