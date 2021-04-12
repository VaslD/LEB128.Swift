public typealias Byte = UInt8

public protocol SevenBitEncodedInteger:
    ExpressibleByArrayLiteral, ExpressibleByIntegerLiteral, ExpressibleByStringLiteral,
    LosslessStringConvertible, CustomDebugStringConvertible, Codable, Equatable
    where ArrayLiteralElement == Byte, IntegerLiteralType: BinaryInteger, StringLiteralType == String
{
    var buffer: ContiguousArray<UInt8> { get }

    var value: IntegerLiteralType { get }

    init?<T: BidirectionalCollection>(bytes: T) where T.Element == Byte, T.Index: BinaryInteger
}

// MARK: - SevenBitEncodedInteger + ExpressibleByArrayLiteral

public extension SevenBitEncodedInteger {
    init(arrayLiteral elements: Byte...) {
        self.init(bytes: elements)!
    }
}

// MARK: - SevenBitEncodedInteger + ExpressibleByStringLiteral

public extension SevenBitEncodedInteger {
    init(stringLiteral value: String) {
        self.init(value)!
    }
}

// MARK: - SevenBitEncodedInteger + LosslessStringConvertible

public extension SevenBitEncodedInteger {
    init?(_ description: String) {
        let hexValues = description.dropFirst().dropLast().split(separator: " ")
        let bytes = hexValues.compactMap { (value) -> UInt8? in
            guard value.count == 2 else { return nil }
            return UInt8(value, radix: 16)
        }
        if hexValues.count == bytes.count {
            self.init(bytes: bytes)
            return
        }

        print("Invalid string representation.")
        return nil
    }
}

// MARK: - SevenBitEncodedInteger + CustomStringConvertible

public extension SevenBitEncodedInteger {
    var description: String {
        guard !self.buffer.isEmpty else {
            return "(00)"
        }

        return "(\(self.buffer.asHexString()))"
    }
}

// MARK: - SevenBitEncodedInteger + CustomDebugStringConvertible

public extension SevenBitEncodedInteger {
    var debugDescription: String {
        return "\(String(describing: value)) \(String(describing: self))"
    }
}

// MARK: - SevenBitEncodedInteger + Codable

public extension SevenBitEncodedInteger {
    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(contentsOf: self.buffer)
    }

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let bytes = try container.decode([UInt8].self)
        self.init(bytes: bytes)!
    }
}
