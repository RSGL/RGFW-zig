pub const RGFW = @cImport({
    @cDefine("RGFW_IMPLEMENTATION", "");
    @cInclude("RGFW.h");
});
