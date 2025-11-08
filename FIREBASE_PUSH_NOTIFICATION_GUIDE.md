# Firebase Push Notification Setup Guide

## Đã Setup

### 1. Dependencies đã thêm vào `pubspec.yaml`:
```yaml
firebase_core: ^3.6.0
firebase_messaging: ^15.1.3
flutter_local_notifications: ^18.0.1
```

### 2. Permissions đã thêm vào `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

### 3. Firebase configuration:
- File `google-services.json` đã có trong `android/app/`
- Meta-data cho notification channel đã thêm vào AndroidManifest

### 4. Files đã tạo:
- `lib/core/services/firebase_notification_service.dart` - Service quản lý FCM
- `lib/presentation/screens/push_notification_demo_screen.dart` - Màn hình demo

## Cách Test

### Bước 1: Cài đặt dependencies
```bash
flutter pub get
```

### Bước 2: Chạy app
```bash
flutter run
```

App sẽ tự động mở màn hình Push Notification Demo.

### Bước 3: Test Local Notification
1. Nhập Title và Body trong form
2. Nhấn "Send Local Notification"
3. Notification sẽ hiển thị ngay lập tức

### Bước 4: Test Firebase Cloud Messaging

#### 4.1. Lấy FCM Token
1. Copy FCM Token từ màn hình demo (nút "Copy Token")
2. Token này unique cho mỗi device

#### 4.2. Gửi notification từ Firebase Console
1. Đi tới: https://console.firebase.google.com
2. Chọn project của bạn
3. Chọn "Cloud Messaging" từ menu bên trái
4. Nhấn "Send your first message" hoặc "New campaign"
5. Nhập notification title và body
6. Nhấn "Send test message"
7. Paste FCM token vào
8. Nhấn "Test"

#### 4.3. Gửi notification từ API
```bash
# Lấy Server Key từ Firebase Console > Project Settings > Cloud Messaging > Server key

curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "FCM_TOKEN_HERE",
    "notification": {
      "title": "Test Notification",
      "body": "This is a test notification from API"
    },
    "data": {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "custom_data": "any_value"
    }
  }'
```

### Bước 5: Test Topic Subscription
1. Bật switch "Subscribe to plants topic" trong app
2. Gửi notification đến topic từ Firebase Console:
   - Chọn "Send to topic"
   - Nhập topic name: `plants`
   - Tất cả devices đã subscribe sẽ nhận được notification

## Các Tính Năng

### 1. Local Notifications
- Gửi notification trực tiếp từ app
- Không cần internet
- Dùng cho reminders, alerts local

### 2. Remote Notifications (FCM)
- Nhận notification từ Firebase server
- Hoạt động khi app đang:
  - Foreground (đang mở)
  - Background (minimize)
  - Terminated (đã đóng hoàn toàn)

### 3. Topic Subscription
- Subscribe/Unsubscribe topics
- Gửi notification đến nhiều devices cùng lúc
- Use cases: 
  - Notification theo category (plants, diseases, tips)
  - Notification theo location
  - Broadcast messages

### 4. Message Handling
- Hiển thị notification khi app foreground
- Handle tap notification để navigate
- Lưu lịch sử messages nhận được

## Architecture

```
lib/
├── core/
│   └── services/
│       └── firebase_notification_service.dart
└── presentation/
    └── screens/
        └── push_notification_demo_screen.dart
```

### FirebaseNotificationService
- Singleton service
- Initialize Firebase và FCM
- Handle foreground, background, terminated messages
- Manage topics subscription
- Show local notifications

### PushNotificationDemoScreen
- UI để test tất cả features
- Display FCM token
- Send local notifications
- Subscribe/unsubscribe topics
- Show received messages history

## Production Usage

### 1. Thay đổi home screen về login:
```dart
// main.dart
home: SignInPage(), // Uncomment this
// home: const PushNotificationDemoScreen(), // Comment this
```

### 2. Navigate đến demo screen từ app:
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const PushNotificationDemoScreen(),
  ),
);
```

### 3. Integrate vào app logic:
```dart
// Listen to messages anywhere in app
FirebaseNotificationService().messageStream.listen((message) {
  // Handle navigation based on message data
  if (message.data['type'] == 'plant_disease') {
    // Navigate to disease detail screen
  }
});
```

### 4. Send notifications từ backend:
```dart
// Example với Node.js
const admin = require('firebase-admin');

admin.messaging().send({
  token: userFcmToken,
  notification: {
    title: 'Plant Disease Detected!',
    body: 'Your plant may have leaf spot disease'
  },
  data: {
    plant_id: '123',
    disease_id: '456',
    type: 'plant_disease'
  }
});
```

## Troubleshooting

### 1. Không nhận được notification
- Kiểm tra internet connection
- Kiểm tra Firebase project configuration
- Verify google-services.json đúng project
- Check permission đã granted (Android 13+)

### 2. Token null
- Chờ một chút sau khi app start
- Kiểm tra Firebase đã initialize đúng
- Check device có Google Play Services (Android)

### 3. Notification không hiển thị khi foreground
- Service đã handle và show local notification
- Check local notification channel đã create

### 4. Background/Terminated không work
- Verify background handler đã setup
- Check AndroidManifest có đầy đủ permissions
- iOS cần additional setup trong `ios/Runner/AppDelegate.swift`

## iOS Setup (Nếu cần)

### 1. Add capabilities trong Xcode:
- Push Notifications
- Background Modes > Remote notifications

### 2. Update `ios/Runner/AppDelegate.swift`:
```swift
import UIKit
import Flutter
import Firebase

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### 3. Request APNs certificate từ Apple Developer
### 4. Upload APNs key/certificate lên Firebase Console

## Best Practices

1. **Lưu FCM Token**: Save token vào database khi user login
2. **Update Token**: Listen to token refresh và update database
3. **Unsubscribe Topics**: Khi user logout, unsubscribe all topics
4. **Handle Deep Links**: Navigate user đến đúng screen khi tap notification
5. **Analytics**: Track notification open rate
6. **Localization**: Send notification theo language của user
7. **Timing**: Không gửi notification vào giờ ngủ
8. **Content**: Keep title/body ngắn gọn, meaningful

## Next Steps

1. Tạo backend API để manage và send notifications
2. Implement notification preferences (user settings)
3. Add notification categories và actions
4. Implement notification scheduling
5. Add analytics tracking
6. Create notification templates
7. Implement notification badges
8. Add rich notifications (images, actions)
