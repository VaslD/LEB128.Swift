public enum LEB128Decoder {
    public static func decode<C>(signed bytes: C, bytesConsumed count: inout Int) -> Int?
        where C: Collection, C.Element == Byte
    {
        count = 0

        var result: Int = 0
        var shift: Int = 0
        let size: Int = MemoryLayout<Int>.size * 8
        var byte: Byte = 0

        let indices = bytes.indices
        for i in indices {
            if shift > Int.bitWidth {
#if DEBUG
                print("Conversion to Int will overflow on this platform.")
#endif
                return nil
            }

            byte = bytes[i]
            result |= ((Int(byte) & 0x7F) << shift)
            shift += 7

            count += 1
            if !byte.isBitSet(at: 7) { break }
        }

        if shift < size, ((Int(byte) & 0x40) >> 6) == 1 {
            result |= -(1 << shift)
        }
        return result
    }

    public static func decode<C>(unsigned bytes: C, bytesConsumed count: inout Int) -> UInt?
        where C: Collection, C.Element == Byte
    {
        count = 0

        var result: UInt = 0
        var shift: UInt = 0

        let indices = bytes.indices
        for i in indices {
            if shift > UInt.bitWidth {
#if DEBUG
                print("Conversion to UInt will overflow on this platform.")
#endif
                return nil
            }

            let byte = bytes[i]
            result |= ((UInt(byte) & 0x7F) << shift)
            shift += 7

            count += 1
            if !byte.isBitSet(at: 7) { break }
        }

        return result
    }

    public static func decode<C, I>(_ bytes: C, bytesConsumed count: inout Int) -> I?
        where C: Collection, C.Element == Byte, I: BinaryInteger
    {
        if I.isSigned {
            if let value = self.decode(signed: bytes, bytesConsumed: &count) {
                return I(value)
            } else {
                return nil
            }
        } else {
            if let value = self.decode(unsigned: bytes, bytesConsumed: &count) {
                return I(value)
            } else {
                return nil
            }
        }
    }

    public static func decode<C>(signed bytes: C) -> Int? where C: Collection, C.Element == Byte {
        var ignored = 0
        return Self.decode(signed: bytes, bytesConsumed: &ignored)
    }

    public static func decode<C>(unsigned bytes: C) -> UInt? where C: Collection, C.Element == Byte {
        var ignored = 0
        return Self.decode(unsigned: bytes, bytesConsumed: &ignored)
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
