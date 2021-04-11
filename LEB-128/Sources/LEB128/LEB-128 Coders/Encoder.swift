public enum LEB128Encoder {
    public static func encode<I: SignedInteger>(_ integer: I) -> ContiguousArray<Byte> {
        var value = integer
        var buffer = ContiguousArray<Byte>()

        var more = true
#if DEBUG
        var count = 0
#endif

        while more {
            var byte = Byte(value & 0x7F)
            value = value >> 7

            if (value == 0 && (byte >> 6) == 0) || (value == -1 && (byte >> 6) == 1) {
                more = false
            } else {
                byte |= 0x80
            }

            buffer.append(byte)
#if DEBUG
            count += 1
#endif
        }

#if DEBUG
        precondition(buffer.count == count, "Internal error!")
#endif

        return buffer
    }

    public static func encode<I: UnsignedInteger>(_ integer: I) -> ContiguousArray<Byte> {
        var value = integer
        var buffer = ContiguousArray<Byte>()

#if DEBUG
        var count = 0
#endif

        repeat {
            var byte = Byte(value & 0x7F)
            value = value >> 7
            if value != 0 {
                byte |= 0x80
            }
            buffer.append(byte)

#if DEBUG
            count += 1
#endif
        } while value != 0

#if DEBUG
        precondition(buffer.count == count, "Internal error!")
#endif

        return buffer
    }

    public static func encode<I: SignedInteger>(unsigned integer: I) -> ContiguousArray<Byte> {
        if integer >= 0 {
            return Self.encode(UInt(integer))
        } else {
            return Self.encode(UInt(abs(integer)))
        }
    }

    public static func encode<I: UnsignedInteger>(signed integer: I) -> ContiguousArray<Byte> {
        Self.encode(Int(integer))
    }
}
