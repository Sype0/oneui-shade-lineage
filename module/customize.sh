# The patched SystemUI only matches the exact ROM build it was made from.
EXPECTED_BUILD=1747406400
[ "$(getprop ro.build.version.sdk)" = "35" ] || abort "! Android 15 (API 35) gerekli"
[ "$(getprop ro.system_ext.build.date.utc)" = "$EXPECTED_BUILD" ] || \
  abort "! Bu modül başka bir ROM derlemesi için yapıldı (system_ext build $EXPECTED_BUILD). ROM güncellendiyse modül yeniden derlenmeli."
ui_print "- One UI Shade kuruluyor"
ui_print "- Sorun olursa: açılışta Ses Kısma tuşuna basılı tut (Magisk güvenli mod)"
