public enum LEB128Decoder {
    public static func decode<C>(signed bytes: C) -> Int? where C: Collection, C.Element == Byte {
        guard bytes.count * 7 <= Int.bitWidth else {
#if DEBUG
            print("Conversion to Int will overflow on this platform.")
#endif
            return nil
        }

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

    public static func decode<C>(unsigned bytes: C) -> UInt? where C: Collection, C.Element == Byte {
        guard bytes.count * 7 <= UInt.bitWidth else {
#if DEBUG
            print("Conversion to UInt will overflow on this platform.")
#endif
            return nil
        }

        var result: UInt = 0
        var shift: UInt = 0

        for byte in bytes {
            result |= ((UInt(byte) & 0x7F) << shift)
            shift += 7
        }

        return result
    }

    public static func decode<C, I>(_ bytes: C) -> I? where C: Collection, C.Element == Byte, I: BinaryInteger {
        if I.isSigned {
            if let value = self.decode(signed: bytes) {
                return I(value)
            } else {
                return nil
            }
        } else {
            if let value = self.decode(unsigned: bytes) {
                return I(value)
            } else {
                return nil
            }
        }
    }
}
