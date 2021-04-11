#if canImport(Foundation)

import Foundation

public extension LEB128Decoder {
    static func decodeData(signed data: Data) -> Int {
        Self.decode(signed: data)
    }

    static func decodeData(unsigned data: Data) -> UInt {
        Self.decode(unsigned: data)
    }

    static func decode<I: BinaryInteger>(_ data: Data) -> I {
        if I.isSigned {
            return I(self.decodeData(signed: data))
        } else {
            return I(self.decodeData(unsigned: data))
        }
    }
}

#endif
