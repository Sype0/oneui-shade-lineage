#!/usr/bin/env bash
# Builds the Magisk module zip. Needs: java, python3, zipalign, aapt2, apksigner, zip, patch.
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
OUT=$ROOT/out; WORK=$OUT/work
APKTOOL=${APKTOOL:-$ROOT/tools/apktool.jar}
rm -rf "$OUT"; mkdir -p "$WORK"
( cd "$ROOT/orig" && sha256sum -c SystemUI.apk.sha256 )

echo "== decode smali (resources left untouched)"
java -Xmx${JAVA_XMX:-6g} -jar "$APKTOOL" d -r -f -o "$WORK/src" "$ROOT/orig/SystemUI.apk"

echo "== apply patches"
shopt -s nullglob
for p in "$ROOT"/patches/*.patch; do
  echo "-- $(basename "$p")"; patch -d "$WORK/src" -p1 --no-backup-if-mismatch < "$p"
done

echo "== assemble dex"
java -Xmx${JAVA_XMX:-6g} -jar "$APKTOOL" b -f --no-apk "$WORK/src"
mkdir -p "$WORK/dex"; cp "$WORK"/src/build/apk/classes*.dex "$WORK/dex/"

echo "== repack + align + transplant signing block"
python3 "$ROOT/scripts/repack.py" "$ROOT/orig/SystemUI.apk" "$WORK/dex" "$WORK/repacked.apk"
zipalign -f -p 4 "$WORK/repacked.apk" "$WORK/aligned.apk"
python3 "$ROOT/scripts/transplant_sig.py" "$ROOT/orig/SystemUI.apk" "$WORK/aligned.apk" "$WORK/SystemUI.apk"

echo "== module"
M=$WORK/module; cp -r "$ROOT/module" "$M"
D=$M/system/system_ext/priv-app/SystemUI; mkdir -p "$D"
cp "$WORK/SystemUI.apk" "$D/"; touch "$D/.replace"   # hides the stale oat/ dir
if [ -f "$ROOT/overlay/AndroidManifest.xml" ]; then
  echo "== overlay"
  "$ROOT/scripts/build_overlay.sh" "$WORK/overlay"
  mkdir -p "$M/system/product/overlay"; cp "$WORK/overlay/OneUIShadeOverlay.apk" "$M/system/product/overlay/"
fi
VER=${VERSION:-dev}; sed -i "s/^version=.*/version=$VER/" "$M/module.prop"
( cd "$M" && zip -qr9 "$OUT/OneUIShade-$VER.zip" . )
echo "built $OUT/OneUIShade-$VER.zip"
