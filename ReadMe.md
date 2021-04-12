**此文档提供[简体中文](ReadMe%20(Chinese).md)版本。**

# LEB128

[**LEB128**](https://en.wikipedia.org/wiki/LEB128) or **Little Endian Base 128** is a form of [variable-length code](https://en.wikipedia.org/wiki/Variable-length_code) compression used to store an arbitrarily large integer in a small number of bytes, unlike traditional 32-bit or 64-bit encoded integers that always occupy a fixed number of bytes.

LEB128 and VLQ ([Variable-Length Quantity](https://en.wikipedia.org/wiki/Variable-length_quantity)), used in MIDI and other protocols and formats, both compress any unsigned integer into not only the same number of bits,  but exactly the same bits—the two formats differ only in exactly how  those bits are arranged. In some context, LEB128 is referred to as a **7-bit Encoded Integer**.

In its core, LEB128 splits the binary representation of a given integer into 7-bit chunks and uses the MSB of every byte to indicate whether another byte is required.

# LEB128.Swift

Swift doesn’t have a system framework that deals with LEB128 encoding. *LEB128.Swift* is created to address this issue. It provides codecs for conversion between LEB128 encoded byte buffers and Swift native integer types: `Int` and `UInt`. It also has its own signed and unsigned integer types that acts as `BigInteger`s in other language to work with values larger than 64-bit.

## Codec

`LEB128Encoder` and `LEB128Decoder` facilitate conversion between Swift integer types and LEB128 encoded byes. They are useful when working with file formats and data streams using LEB128 encoding.

- `LEB128Encoder` can transform any `BinaryInteger` conforming types to LEB128 encoded `ContigousArray<UInt8>`. Using `ContigousArray<UInt8>` ensures performance. When `Foundation` framework is available, additional extension methods that returns `Data` are also provided.
- `LEB128Decoder` can transform any `Collection` of `UInt8`s to platform-independent `Int` or `UInt`, depending on whether the original encoding is signed or unsigned. Because `[UInt8]` and `Data` conform to `Collection`, no extension methods are provided for more specialized collections. Be aware that the size of `Int` and `UInt` are limited, depending on the platform implementation, they are either 32-bit or 64-bit. Therefore, not all LEB128 encoded arbitrary-length integers can fit, when the size of encoded integer exceeds platform limitation, decoding methods return `nil`.

## 7-bit Encoded Integers

`Signed7BitEncodedInteger`, `Unsigned7BitEncodedInteger` and the base protocol `SevenBitEncodedInteger` store any integer value in a native LEB128 byte buffer. This allows storage and arithmetic operations on arbitrarily large values.

Swift `Int` and `UInt` values can be extracted from corresponding types. However, when the stored value exceeds platform limitation, properties returning Swift integers become unavailable and debugging prints raw bytes instead of human-readable decimals.

`Signed7BitEncodedInteger` and `Unsigned7BitEncodedInteger` have not yet supported all arithmetic operations. Conformance to `BinaryInteger` is scheduled on is in the works.

