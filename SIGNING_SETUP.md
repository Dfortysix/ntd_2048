# Hướng dẫn cấu hình Signing cho ứng dụng Android

## Các file đã được cấu hình:

1. **my-release-key.jks** - File keystore chính (đã có sẵn)
2. **android/key.properties** - File chứa thông tin signing
3. **android/app/build.gradle.kts** - Đã cấu hình signing config
4. **android/app/proguard-rules.pro** - Quy tắc ProGuard

## Các bước cần thực hiện:

### 1. Cập nhật thông tin trong file `android/key.properties`:
```properties
storePassword=your_actual_store_password
keyPassword=your_actual_key_password
keyAlias=upload
storeFile=../my-release-key.jks
```

**Lưu ý:** Thay thế `your_actual_store_password` và `your_actual_key_password` bằng mật khẩu thực tế của bạn.

### 2. Build ứng dụng ở chế độ release:
```bash
flutter build appbundle --release
```

### 3. Tìm file .aab:
File .aab sẽ được tạo tại: `build/app/outputs/bundle/release/app-release.aab`

## Bảo mật:

- File `key.properties` và `my-release-key.jks` đã được thêm vào `.gitignore`
- Không commit các file này lên git
- Lưu trữ mật khẩu một cách an toàn

## Troubleshooting:

Nếu gặp lỗi signing, hãy kiểm tra:
1. Mật khẩu trong `key.properties` có đúng không
2. File `my-release-key.jks` có tồn tại không
3. Key alias có đúng không (mặc định là "upload") 