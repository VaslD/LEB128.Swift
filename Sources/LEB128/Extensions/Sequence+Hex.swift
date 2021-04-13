extension Sequence where Element == Byte {
    func asHexString(separator: String) -> String {
        self.map { $0.asHexString() }.joined(separator: separator)
    }
}
