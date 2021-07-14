import LEB128

let i = UnsignedLEB128(Int.max)
let j = Unsigned7BitEncodedInteger(Int.max)!
print(i.debugDescription)
print(j.debugDescription)
