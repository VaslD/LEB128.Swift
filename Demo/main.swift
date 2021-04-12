import Foundation
import LEB128

let five = Unsigned7BitEncodedInteger(5)
for i in 127 ... UInt16.max {
    let y = Unsigned7BitEncodedInteger(integerLiteral: UInt(i) - 5)
    let x = Unsigned7BitEncodedInteger(UInt(i))
    let sum = x - five

    assert(sum == y)
}
