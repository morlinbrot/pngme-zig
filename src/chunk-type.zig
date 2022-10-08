const std = @import("std");

const ASCII_UPPER = 0b0010_0000;

const ParseError = error{
    TooLong,
    InvalidChunkTypeCode,
};

pub const ChunkType = struct {
    bytes: [4]u8,

    fn is_valid_byte(byte: u8) bool {
        return (byte >= 65 and byte <= 90) or (byte >= 97 and byte <= 122);
    }

    fn is_valid(self: *ChunkType) bool {
        return self.bytes_are_alphanumeric() and self.is_reserved_bit_valid();
    }

    fn bytes_are_alphanumeric(self: *ChunkType) bool {
        for (self.bytes) |byte| {
            if (!ChunkType.is_valid_byte(byte)) {
                return false;
            }
        }

        return true;
    }

    fn get_bytes(self: *ChunkType) [4]u8 {
        return self.bytes;
    }

    fn is_critical(self: *ChunkType) bool {
        return self.bytes[0] & ASCII_UPPER == 0;
    }

    fn is_public(self: *ChunkType) bool {
        return self.bytes[1] & ASCII_UPPER == 0;
    }

    fn is_reserved_bit_valid(self: *ChunkType) bool {
        return self.bytes[2] & ASCII_UPPER == 0;
    }

    fn is_safe_to_copy(self: *ChunkType) bool {
        return self.bytes[3] & ASCII_UPPER != 0;
    }

    fn try_from_str(str: []const u8) !ChunkType {
        if (str.len != 4) {
            return error.TooLong;
        }

        var chunk = ChunkType{ .bytes = [4]u8{ str[0], str[1], str[2], str[3] } };

        if (!chunk.bytes_are_alphanumeric()) {
            return error.InvalidChunkTypeCode;
        }

        return chunk;
    }

    fn try_from(arr: [4]u8) !ChunkType {
        if (arr.len != 4) {
            return error.TooLong;
        }

        return ChunkType{ .bytes = arr };
    }

    fn to_string(self: *ChunkType) []const u8 {
        return self.bytes[0..];
    }
};

test "chunk type from bytes" {
    const expected = [4]u8{ 82, 117, 83, 116 };
    var actual = try ChunkType.try_from([_]u8{ 82, 117, 83, 116 });

    try std.testing.expectEqual(expected, actual.get_bytes());
}

test "chunk type from str" {
    const expected = try ChunkType.try_from([4]u8{ 82, 117, 83, 116 });
    const actual = try ChunkType.try_from_str("RuSt");

    try std.testing.expectEqual(expected, actual);
}

test "chunk type from str error" {
    const expected = ParseError.TooLong;
    const actual = ChunkType.try_from_str("RuStt");

    try std.testing.expectError(expected, actual);
}

test "test chunk type is critical" {
    var chunk = try ChunkType.try_from_str("RuSt");
    try std.testing.expect(chunk.is_critical());
}

test "test chunk type is not critical" {
    var chunk = try ChunkType.try_from_str("ruSt");
    try std.testing.expect(!chunk.is_critical());
}

test "chunk type is public" {
    var chunk = try ChunkType.try_from_str("RUSt");
    try std.testing.expect(chunk.is_public());
}

test "chunk type is not public" {
    var chunk = try ChunkType.try_from_str("RuSt");
    try std.testing.expect(!chunk.is_public());
}

test "chunk type is reserved bit valid" {
    var chunk = try ChunkType.try_from_str("RuSt");
    try std.testing.expect(chunk.is_reserved_bit_valid());
}

test "chunk type is reserved bit invalid" {
    var chunk = try ChunkType.try_from_str("Rust");
    try std.testing.expect(!chunk.is_reserved_bit_valid());
}

test "chunk type is safe to copy" {
    var chunk = try ChunkType.try_from_str("RuSt");
    try std.testing.expect(chunk.is_safe_to_copy());
}

test "chunk type is unsafe to copy" {
    var chunk = try ChunkType.try_from_str("RuST");
    try std.testing.expect(!chunk.is_safe_to_copy());
}

// Mark
test "valid_chunk_is_valid" {
    var chunk = try ChunkType.try_from_str("RuSt");
    try std.testing.expect(chunk.is_valid());
}

test "invalid_chunk_is_valid" {
    var chunk = try ChunkType.try_from_str("Rust");
    try std.testing.expect(!chunk.is_valid());

    const expected = ParseError.InvalidChunkTypeCode;
    const actual = ChunkType.try_from_str("Ru1t");
    try std.testing.expectError(expected, actual);
}

test "chunk_type_string" {
    var chunk = try ChunkType.try_from_str("RuSt");
    try std.testing.expectEqualStrings("RuSt", chunk.to_string());
}
