# One UI Shade for LineageOS 22 (Redmi Note 12 4G)

One UI tarzı bildirim çekmecesi ve Hızlı Ayarlar, Magisk modülü olarak.

**Sadece tek bir ROM derlemesi için** (LineageOS 22, system_ext build `1747406400`). SystemUI'nin
kodu yamalandığı için başka derlemelerde çalışmaz; modül kurulumda bunu kontrol eder.

## Nasıl çalışır
- `orig/SystemUI.apk`: ROM'un orijinal SystemUI'si.
- `patches/*.patch`: smali yamaları. Sadece `classes*.dex` yeniden derlenir; kaynaklar ve diğer
  dosyalar orijinal bayt bayt korunur.
- `overlay/`: görünüm (layout, ölçü, renk) için RRO overlay.
- Orijinal APK imza bloğu yeni APK'ya taşınır. Sistem bölümündeki uygulamalar açılışta içerik
  özeti doğrulanmadan tarandığı için orijinal sertifika kabul edilir.

## Kurulum / geri alma
Release'ten zip'i Magisk ile kur, yeniden başlat. Geri almak için modülü Magisk'te kapat;
sistem açılmazsa açılışta **Ses Kısma** tuşuna basılı tut (Magisk güvenli mod, tüm modüller kapanır).

## Derleme
GitHub Actions her push'ta derler. Yerelde: `tools/apktool.jar` koy, `./scripts/build.sh`.
