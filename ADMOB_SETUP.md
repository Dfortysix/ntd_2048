# Hướng dẫn cấu hình AdMob cho project mới

## 🔥 Các bước cần thực hiện:

### 1. **Tạo AdMob App**
1. Vào [AdMob Console](https://admob.google.com/)
2. Tạo app mới với package name: `com.company.Fruits2048`
3. Lấy **App ID** (dạng: `ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy`)

### 2. **Tạo Ad Units**
Tạo 3 loại quảng cáo:
- **Banner Ad Unit** → Lấy Banner Ad Unit ID
- **Interstitial Ad Unit** → Lấy Interstitial Ad Unit ID  
- **Rewarded Ad Unit** → Lấy Rewarded Ad Unit ID

### 3. **Cập nhật AndroidManifest.xml**
Thay thế trong file `android/app/src/main/AndroidManifest.xml`:
```xml
<!-- Thay thế test App ID bằng App ID thật -->
android:value="ca-app-pub-YOUR_APP_ID_HERE"
```

### 4. **Cập nhật Firebase Remote Config**
Vào Firebase Console → Remote Config, tạo các tham số:
- `banner_ad_unit_id` = Banner Ad Unit ID thật
- `interstitial_ad_unit_id` = Interstitial Ad Unit ID thật
- `rewarded_ad_unit_id` = Rewarded Ad Unit ID thật

### 5. **Test và Publish**
1. Test với test IDs trước
2. Khi hoạt động tốt, thay bằng Ad Unit ID thật
3. Publish Remote Config

## 📝 Lưu ý:
- **Test IDs** hiện tại chỉ dùng để test
- **Ad Unit ID thật** chỉ hoạt động khi app được publish lên Google Play
- Đảm bảo SHA fingerprints đã được thêm vào Firebase

## 🔧 Troubleshooting:
- Nếu quảng cáo không hiển thị, kiểm tra:
  - App ID trong AndroidManifest.xml
  - Ad Unit ID trong Remote Config
  - SHA fingerprints trong Firebase
  - App đã được publish lên Google Play (cho Ad Unit ID thật) 