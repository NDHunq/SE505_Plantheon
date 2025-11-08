# Troubleshooting - White Screen Issue

## Vấn đề: Màn hình trắng khi chạy app

### Nguyên nhân:
Firebase chưa được initialize đúng cách với platform-specific options.

### Đã Fix:
✅ Thêm import `firebase_options.dart` vào service
✅ Truyền `DefaultFirebaseOptions.currentPlatform` khi initialize Firebase
✅ Enable core library desugaring cho Android

### Code đã sửa:

**Before:**
```dart
await Firebase.initializeApp();
```

**After:**
```dart
import 'package:se501_plantheon/firebase_options.dart';

await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

### Android Build Issues Fixed:

**1. Core Library Desugaring Error:**
```
Dependency ':flutter_local_notifications' requires core library desugaring
```

**Solution:** Thêm vào `android/app/build.gradle.kts`:
```kotlin
compileOptions {
    isCoreLibraryDesugaringEnabled = true
    sourceCompatibility = JavaVersion.VERSION_11
    targetCompatibility = JavaVersion.VERSION_11
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
```

## Kiểm tra lại:

### 1. Clean build nếu cần:
```bash
flutter clean
flutter pub get
flutter run
```

### 2. Xem logs nếu vẫn có vấn đề:
```bash
flutter logs
```

### 3. Check Firebase initialization:
Trong console bạn sẽ thấy:
```
I/flutter : User granted permission: AuthorizationStatus.authorized
I/flutter : FCM Token: [your-token-here]
```

## Next Steps:

Sau khi app chạy thành công, bạn sẽ thấy màn hình **Push Notification Demo** với:
- ✅ FCM Token
- ✅ Form gửi local notification
- ✅ Topic subscription toggle
- ✅ Received messages list

## Common Issues:

### Màn hình vẫn trắng?
- Check console có error gì không
- Verify `google-services.json` đúng project
- Ensure internet connection

### Không nhận được FCM Token?
- Chờ vài giây sau khi app start
- Check Google Play Services (Android)
- Verify Firebase project configuration

### Build failed?
- Run `flutter clean`
- Delete `build` folder
- Run `flutter pub get` lại
