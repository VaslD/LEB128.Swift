public struct UnsignedLEB128: BinaryInteger, LosslessStringConvertible, CustomDebugStringConvertible {
    init(_ words: Words) {
        self.words = words
    }

    // MARK: ExpressibleByIntegerLiteral

    public typealias IntegerLiteralType = UInt

    public init(integerLiteral value: UInt) {
        self.words = LEB128Encoder.encode(value).map { UInt($0) }
    }

    // MARK: Numeric

    public typealias Magnitude = Self

    public var magnitude: UnsignedLEB128 { self }

    public static func + (lhs: Self, rhs: Self) -> Self {
        precondition(!lhs.words.isEmpty, "Left-hand side has an empty internal buffer.")
        precondition(!rhs.words.isEmpty, "Right-hand side has an empty internal buffer.")

        let length = max(lhs.words.count, rhs.words.count)

        var buffer = ContiguousArray<UInt>()
        var carry = false
        for index in 0 ..< length {
            var x = lhs.words[safe: index] ?? 0
            var y = rhs.words[safe: index] ?? 0
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

        return Self([UInt](buffer))
    }

    public static func - (lhs: Self, rhs: Self) -> Self {
        precondition(!lhs.words.isEmpty, "Left-hand side has an empty internal buffer.")
        precondition(!rhs.words.isEmpty, "Right-hand side has an empty internal buffer.")

        let length = max(lhs.words.count, rhs.words.count)

        var buffer = ContiguousArray<UInt>()
        var borrow = false
        for index in 0 ..< length {
            var x = lhs.words[safe: index] ?? 0
            var y = rhs.words[safe: index] ?? 0
            x.clearBit(at: 7)
            y.clearBit(at: 7)

            var byte: UInt
            if x >= y + (borrow ? 1 : 0) {
                byte = x - y - (borrow ? 1 : 0)
                borrow = false
            } else {
                x.setBit(at: 7)
                byte = x - y - (borrow ? 1 : 0)
                borrow = true
            }

            byte.setBit(at: 7)
            buffer.append(byte)
        }

        precondition(!borrow, "Subtraction results in a negative value.")

        var byte = buffer.popLast()
        byte?.clearBit(at: 7)
        while byte == 0 {
            byte = buffer.popLast()
            byte?.clearBit(at: 7)
        }

        if let value = byte {
            buffer.append(value)
        }

        if buffer.isEmpty {
            buffer.append(0)
        }

        return Self([UInt](buffer))
    }

    public static func * (lhs: Self, rhs: Self) -> Self {
        fatalError()
    }

    public static func *= (lhs: inout Self, rhs: Self) {
        fatalError()
    }

    public static func / (lhs: Self, rhs: Self) -> Self {
        fatalError()
    }

    public static func /= (lhs: inout Self, rhs: Self) {
        fatalError()
    }

    public static func % (lhs: Self, rhs: Self) -> Self {
        fatalError()
    }

    public static func %= (lhs: inout Self, rhs: Self) {
        fatalError()
    }

    // MARK: BinaryInteger

    public typealias Words = [UInt]

    public static let isSigned = false

    public var words: [UInt]

    public var bitWidth: Int {
        self.words.count * 8 - self.words.count
    }

    public var trailingZeroBitCount: Int {
        var count = 0
        for word in self.words {
            count += word.trailingZeroBitCount
            if count != 7 { break }
        }
        return count
    }

    public init?<T>(exactly source: T) where T: BinaryInteger {
        guard !T.isSigned, let value = UInt(exactly: source) else { return nil }
        self.words = LEB128Encoder.encode(value).map { UInt($0) }
    }

    public init?<T>(exactly source: T) where T: BinaryFloatingPoint {
        guard let value = UInt(exactly: source) else { return nil }
        self.words = LEB128Encoder.encode(value).map { UInt($0) }
    }

    public init<T>(_ source: T) where T: BinaryInteger {
        let value = UInt(source)
        self.words = LEB128Encoder.encode(value).map { UInt($0) }
    }

    public init<T>(_ source: T) where T: BinaryFloatingPoint {
        let value = UInt(source)
        self.words = LEB128Encoder.encode(value).map { UInt($0) }
    }

    public init<T>(clamping source: T) where T: BinaryInteger {
        let value = UInt(source)
        self.words = LEB128Encoder.encode(value).map { UInt($0) }
    }

    public init<T>(truncatingIfNeeded source: T) where T: BinaryInteger {
        let value = UInt(source)
        self.words = LEB128Encoder.encode(value).map { UInt($0) }
    }

    public static prefix func ~ (x: Self) -> Self {
        fatalError()
    }

    public static func &= (lhs: inout Self, rhs: Self) {
        fatalError()
    }

    public static func |= (lhs: inout Self, rhs: Self) {
        fatalError()
    }

    public static func ^= (lhs: inout Self, rhs: Self) {
        fatalError()
    }

    public static func <<= <RHS>(lhs: inout Self, rhs: RHS) where RHS: BinaryInteger {
        fatalError()
    }

    public static func >>= <RHS>(lhs: inout Self, rhs: RHS) where RHS: BinaryInteger {
        fatalError()
    }

    // MARK: LosslessStringConvertible

    public var description: String {
        guard !self.words.isEmpty else {
            return "(00)"
        }

        let description = self.words.map { byte in
            let string = String(byte, radix: 16, uppercase: true)
            if string.count == 1 {
                return "0" + string
            } else {
                return string
            }
        }.joined(separator: " ")
        return "(\(description))"
    }

    public init?(_ description: String) {
        let hexValues = description.dropFirst().dropLast().split(separator: " ")
        let bytes = hexValues.compactMap { value -> UInt? in
            guard value.count == 2 else { return nil }
            return UInt(value, radix: 16)
        }
        if hexValues.count == bytes.count {
            self.init(bytes)
            return
        }

        return nil
    }

    // MARK: CustomDebugStringConvertible

    public var debugDescription: String {
        let value: String = {
            if let value = LEB128Decoder.decode(unsigned: self.words.map { UInt8($0) }) {
                return String(value)
            }
            return "??"
        }()
        return "[\(value)] \(self.description)"
    }
}
