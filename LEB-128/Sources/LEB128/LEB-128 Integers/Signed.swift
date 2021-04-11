public struct Signed7BitEncodedInteger: SevenBitEncodedInteger {
    public let buffer: ContiguousArray<Byte>

    public init?<T: BidirectionalCollection>(bytes: T) where T.Element == Byte, T.Index: BinaryInteger {
        guard !bytes.isEmpty else {
#if DEBUG
            print("Byte buffer is empty.")
#endif
            return nil
        }

        guard bytes.prefix(upTo: bytes.endIndex - 1).allSatisfy({ $0.isBitSet(at: 7) }),
              !bytes.last!.isBitSet(at: 7)
        else {
#if DEBUG
            print("Invalid byte buffer passed into Signed7BitEncodedInteger initializer.")
#endif
            return nil
        }

        self.buffer = ContiguousArray<Byte>(bytes)
    }

    public init(_ integer: Int) {
        self.buffer = LEB128Encoder.encode(integer)
    }

    public var value: Int {
        LEB128Decoder.decode(signed: self.buffer)
    }
}

// MARK: - Signed7BitEncodedInteger + ExpressibleByIntegerLiteral

extension Signed7BitEncodedInteger: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self.init(value)
    }
}

// MARK: - Signed7BitEncodedInteger + Equatable

extension Signed7BitEncodedInteger: Equatable {
    public static func == (lhs: Signed7BitEncodedInteger, rhs: Signed7BitEncodedInteger) -> Bool {
        guard lhs.buffer.count == rhs.buffer.count else { return false }

        for i in lhs.buffer.indices {
            if lhs.buffer[i] != rhs.buffer[i] {
                return false
            }
        }

        return true
    }
}

/*
 // MARK: - Unsigned7BitEncodedInteger + AdditiveArithmetic

 extension Unsigned7BitEncodedInteger: AdditiveArithmetic {
     public static func + (lhs: Unsigned7BitEncodedInteger, rhs: Unsigned7BitEncodedInteger)
         -> Unsigned7BitEncodedInteger {

     }

     public static func - (lhs: Unsigned7BitEncodedInteger, rhs: Unsigned7BitEncodedInteger)
     ->        Unsigned7BitEncodedInteger {

     }
 }
 */
