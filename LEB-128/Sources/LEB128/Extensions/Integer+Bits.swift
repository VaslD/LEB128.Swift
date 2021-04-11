extension BinaryInteger {
    func isBitSet(at index: Int) -> Bool {
        ((self >> index) & 1) > 0
    }

    mutating func setBit(at index: Int) {
        self |= 1 << index
    }

    mutating func clearBit(at index: Int) {
        self &= ~(1 << index)
    }

    mutating func toggleBit(at index: Int) {
        self ^= 1 << index
    }
}
