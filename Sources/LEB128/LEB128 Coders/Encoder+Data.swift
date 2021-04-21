#if canImport(Foundation)

import Foundation

public extension LEB128Encoder {
    static func encodeAsData<I: SignedInteger>(_ integer: I) -> Data {
        let buffer: ContiguousArray<Byte> = Self.encode(integer)
        return Data(buffer)
    }

    static func encodeAsData<I: UnsignedInteger>(_ integer: I) -> Data {
        let buffer: ContiguousArray<Byte> = Self.encode(integer)
        return Data(buffer)
    }

    static func encodeAsData<I: SignedInteger>(unsigned integer: I) -> Data {
        if integer >= 0 {
            return Self.encodeAsData(UInt(integer))
        } else {
            return Self.encodeAsData(UInt(abs(integer)))
        }
    }

    static func encodeAsData<I: UnsignedInteger>(signed integer: I) -> Data {
        Self.encodeAsData(Int(integer))
    }
}

#endif
