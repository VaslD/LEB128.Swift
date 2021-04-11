extension Byte {
    func asHexString() -> String {
        let string = String(self, radix: 16, uppercase: true)
        if string.count == 1 {
            return "0\(string)"
        } else {
            return string
        }
    }
}
