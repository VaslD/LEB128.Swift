public struct Unsigned7BitEncodedInteger: SevenBitEncodedInteger {
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
            print("Invalid byte buffer passed into Unsigned7BitEncodedInteger initializer.")
#endif
            return nil
        }

        self.buffer = ContiguousArray<Byte>(bytes)
    }

    public init(_ integer: UInt) {
        self.buffer = LEB128Encoder.encode(integer)
    }

    public var value: UInt {
        LEB128Decoder.decode(unsigned: self.buffer)
    }
}

// MARK: - Unsigned7BitEncodedInteger + ExpressibleByIntegerLiteral

extension Unsigned7BitEncodedInteger: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: UInt) {
        self.init(value)
    }
}

// MARK: - Unsigned7BitEncodedInteger + Equatable

extension Unsigned7BitEncodedInteger: Equatable {
    public static func == (lhs: Unsigned7BitEncodedInteger, rhs: Unsigned7BitEncodedInteger) -> Bool {
        guard lhs.buffer.count == rhs.buffer.count else { return false }

        for i in lhs.buffer.indices {
            if lhs.buffer[i] != rhs.buffer[i] {
                return false
            }
        }

        return true
    }
}

// MARK: - Unsigned7BitEncodedInteger + Comparable

extension Unsigned7BitEncodedInteger: Comparable {
    public static func < (lhs: Unsigned7BitEncodedInteger, rhs: Unsigned7BitEncodedInteger) -> Bool {
        if lhs.buffer.count < rhs.buffer.count { return true }
        guard lhs.buffer.count == rhs.buffer.count else { return false }

        var isSmaller = false
        for index in lhs.buffer.indices {
            let x = lhs.buffer[index]
            let y = rhs.buffer[index]
            if x < y {
                isSmaller = true
            } else if x > y {
                isSmaller = false
            }
        }

        return isSmaller
    }

    public static func <= (lhs: Unsigned7BitEncodedInteger, rhs: Unsigned7BitEncodedInteger) -> Bool {
        if lhs.buffer.count < rhs.buffer.count { return true }
        if lhs.buffer.count > rhs.buffer.count { return false }

        var isSmaller = false
        for index in lhs.buffer.indices {
            let x = lhs.buffer[index]
            let y = rhs.buffer[index]
            isSmaller = x <= y
        }

        return isSmaller
    }

    public static func > (lhs: Unsigned7BitEncodedInteger, rhs: Unsigned7BitEncodedInteger) -> Bool {
        if lhs.buffer.count > rhs.buffer.count { return true }
        guard lhs.buffer.count == rhs.buffer.count else { return false }

        var isLarger = false
        for index in lhs.buffer.indices {
            let x = lhs.buffer[index]
            let y = rhs.buffer[index]
            if x > y {
                isLarger = true
            } else if x < y {
                isLarger = false
            }
        }

        return isLarger
    }

    public static func >= (lhs: Unsigned7BitEncodedInteger, rhs: Unsigned7BitEncodedInteger) -> Bool {
        if lhs.buffer.count > rhs.buffer.count { return true }
        if lhs.buffer.count < rhs.buffer.count { return false }

        var isLarger = true
        for index in lhs.buffer.indices {
            let x = lhs.buffer[index]
            let y = rhs.buffer[index]
            if x > y {
                isLarger = true
            } else if x < y {
                isLarger = false
            }
        }

        return isLarger
    }
}

// MARK: - Unsigned7BitEncodedInteger + AdditiveArithmetic

extension Unsigned7BitEncodedInteger: AdditiveArithmetic {
    public static func + (lhs: Unsigned7BitEncodedInteger, rhs: Unsigned7BitEncodedInteger)
        -> Unsigned7BitEncodedInteger
    {
        precondition(!lhs.buffer.isEmpty, "Integer has empty byte buffer.")
        precondition(!rhs.buffer.isEmpty, "Integer has empty byte buffer.")

        let length = max(lhs.buffer.count, rhs.buffer.count)

        var buffer = ContiguousArray<Byte>()
        var carry = false
        for index in 0 ..< length {
            var x = lhs.buffer[safe: index] ?? 0
            var y = rhs.buffer[safe: index] ?? 0
            x.clearBit(at: 7)
            y.clearBit(at: 7)

            var byte = x + y + (carry ? 1 : 0)
            carry = byte.isBitSet(at: 7)
            byte.setBit(at: 7)
            buffer.append(byte)
        }

        var byte = buffer.popLast()!
        if carry {
            buffer.append(byte)
            buffer.append(1)
        } else {
            byte.clearBit(at: 7)
            buffer.append(byte)
        }

        return Unsigned7BitEncodedInteger(bytes: buffer)!
    }

    public static func - (lhs: Unsigned7BitEncodedInteger, rhs: Unsigned7BitEncodedInteger)
        -> Unsigned7BitEncodedInteger
    {
        fatalError("Not Implemented.")
    }
}
