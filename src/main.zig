const std = @import("std");
// TODO: Decide on package or library pattern.
// const ChunkType = @import("chunk-type").ChunkType;
const chunk_type = @import("chunk-type.zig");

pub fn main() anyerror!void {
    std.log.info("All your codebase are belong to us.", .{});
}

test {
    std.testing.refAllDecls(@This());
}
