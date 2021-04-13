extension Sequence where Element == Byte {
    func asHexString() -> String {
        self.map { $0.asHexString() }.joined(separator: " ")
    }
}
