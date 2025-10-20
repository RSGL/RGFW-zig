const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const opengl = b.option(bool, "opengl", "enables opengl") orelse false;
    const wayland = b.option(bool, "wayland", "enables wayland") orelse false;
    const vulkan = b.option(bool, "vulkan", "enables vulkan") orelse false;

    const cRGFW = b.addTranslateC(.{
        .link_libc = true,
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("RGFW.h")
    });
    cRGFW.addIncludePath(b.path("."));

    cRGFW.defineCMacro("RGFW_IMPLEMENTATION", "");
    if (opengl) cRGFW.defineCMacro("RGFW_OPENGL", "");
    if (wayland) cRGFW.defineCMacro("RGFW_WAYLAND", "");
    if (vulkan) cRGFW.defineCMacro("RGFW_VULKAN", "");

    const mod = cRGFW.addModule("RGFW");
    
    switch (target.result.os.tag) {
        .linux, .freebsd, .openbsd, .dragonfly => {
            if (opengl) mod.linkSystemLibrary("GL", .{.needed = true});
            if (vulkan) mod.linkSystemLibrary("vulkan", .{.needed = true});
            if (wayland) {
                if (opengl) {
                    mod.linkSystemLibrary("EGL", .{.needed = true});
                    mod.linkSystemLibrary("wayland-egl", .{.needed = true});
                }
                mod.addCSourceFiles(.{
                    .files = &.{
                        "xdg/xdg-shell.c",
                        "xdg/xdg-toplevel-icon-v1.c",
                        "xdg/xdg-output-unstable-v1.c",
                        "xdg/xdg-decoration-unstable-v1.c",
                        "xdg/relative-pointer-unstable-v1.c",
                        "xdg/pointer-constraints-unstable-v1.c",
                    }
                });
                mod.addIncludePath(b.path("xdg"));
                mod.linkSystemLibrary("wayland-client", .{.needed = true});
                mod.linkSystemLibrary("wayland-cursor", .{.needed = true});
                mod.linkSystemLibrary("xkbcommon", .{.needed = true});
            }
            else {
                mod.linkSystemLibrary("x11", .{.needed = true});
                mod.linkSystemLibrary("xrandr", .{.needed = true});
            }
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
