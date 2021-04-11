public enum LEB128Decoder {
    public static func decode<C>(signed bytes: C) -> Int where C: Collection, C.Element == Byte {
        var result: Int = 0
        var shift: Int = 0
        let size: Int = MemoryLayout<Int>.size * 8
        var byte: Byte = 0

        for i in bytes.indices {
            byte = bytes[i]
            result |= ((Int(byte) & 0x7F) << shift)
            shift += 7
        }

        if shift < size, ((Int(byte) & 0x40) >> 6) == 1 {
            result |= -(1 << shift)
        }
        return result
    }

    public static func decode<C>(unsigned bytes: C) -> UInt where C: Collection, C.Element == Byte {
        var result: UInt = 0
        var shift: UInt = 0

        for byte in bytes {
            result |= ((UInt(byte) & 0x7F) << shift)
            shift += 7
        }

        return result
    }

    public static func decode<C, I>(_ bytes: C) -> I where C: Collection, C.Element == Byte, I: BinaryInteger {
        if I.isSigned {
            return I(self.decode(signed: bytes))
        } else {
            return I(self.decode(unsigned: bytes))
        }
    }
}
