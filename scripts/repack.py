#!/usr/bin/env python3
"""Rebuild an APK from the original, swapping only classes*.dex.
Every other entry keeps its original bytes and compression method.
Usage: repack.py orig.apk dex_dir out_unaligned.apk"""
import os, sys, zipfile

orig, dex_dir, out = sys.argv[1:4]
new_dex = sorted(f for f in os.listdir(dex_dir) if f.startswith("classes") and f.endswith(".dex"))
if not new_dex: sys.exit("no dex files in " + dex_dir)

with zipfile.ZipFile(orig) as zin, zipfile.ZipFile(out, "w") as zout:
    for info in zin.infolist():
        if info.filename.startswith("classes") and info.filename.endswith(".dex"):
            continue
        zout.writestr(info, zin.read(info.filename), compress_type=info.compress_type)
    for name in new_dex:
        zi = zipfile.ZipInfo(name, date_time=(2009, 1, 1, 0, 0, 0))
        zi.compress_type = zipfile.ZIP_DEFLATED
        zout.writestr(zi, open(os.path.join(dex_dir, name), "rb").read())
print("repacked with", ", ".join(new_dex))
