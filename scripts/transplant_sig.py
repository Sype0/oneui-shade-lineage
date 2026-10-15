#!/usr/bin/env python3
"""Copy the APK Signing Block from an original APK into a rebuilt (unsigned) APK.
System-partition apps are scanned without content-digest verification, so the
original certificate is accepted. Usage: transplant_sig.py orig.apk new.apk out.apk"""
import struct, sys

MAGIC = b"APK Sig Block 42"

def eocd(data):
    i = data.rfind(b"PK\x05\x06")
    if i < 0: sys.exit("EOCD not found")
    cd_size, cd_off = struct.unpack_from("<II", data, i + 12)
    return i, cd_off, cd_size

def sig_block(data):
    _, cd_off, _ = eocd(data)
    if data[cd_off - 16:cd_off] != MAGIC: sys.exit("no signing block in original")
    size = struct.unpack_from("<Q", data, cd_off - 24)[0]
    start = cd_off - (size + 8)
    assert struct.unpack_from("<Q", data, start)[0] == size
    return data[start:cd_off]

orig, new, out = sys.argv[1:4]
blk = sig_block(open(orig, "rb").read())
d = open(new, "rb").read()
ei, cd_off, cd_size = eocd(d)
if d[cd_off - 16:cd_off] == MAGIC: sys.exit("new apk already signed")
assert cd_off + cd_size == ei
res = bytearray(d[:cd_off] + blk + d[cd_off:])
struct.pack_into("<I", res, ei + len(blk) + 16, cd_off + len(blk))
open(out, "wb").write(res)
print(f"signing block {len(blk)} bytes transplanted -> {out}")
