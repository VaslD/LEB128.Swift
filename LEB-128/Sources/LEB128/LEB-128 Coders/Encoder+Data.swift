#if canImport(Foundation)

import Foundation

public extension LEB128Encoder {
    static func encodeData<I: SignedInteger>(_ integer: I) -> Data {
        let buffer: ContiguousArray<Byte> = Self.encode(integer)
        return Data(buffer)
    }

    static func encodeData<I: UnsignedInteger>(_ integer: I) -> Data {
        let buffer: ContiguousArray<Byte> = Self.encode(integer)
        return Data(buffer)
    }

    static func encodeData<I: SignedInteger>(unsigned integer: I) -> Data {
        if integer >= 0 {
            return Self.encodeData(UInt(integer))
        } else {
            return Self.encodeData(UInt(abs(integer)))
        }
    }

    static func encodeData<I: UnsignedInteger>(signed integer: I) -> Data {
        Self.encodeData(Int(integer))
    }
}

#endif
