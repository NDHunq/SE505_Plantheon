# Quick Start - Firebase Push Notification

## ✅ Đã Setup Xong

Tất cả các file và configuration đã được setup sẵn:
- ✅ Firebase dependencies
- ✅ Android permissions
- ✅ Notification service
- ✅ Demo screen
- ✅ Main.dart integration

## 🚀 Chạy Ngay

```bash
flutter run
```

App sẽ mở màn hình Push Notification Demo.

## 🧪 Test Nhanh

### 1. Test Local Notification (Không cần Firebase)
1. Nhập Title: `Test Notification`
2. Nhập Body: `This is a test message`
3. Nhấn **Send Local Notification**
4. ✅ Bạn sẽ thấy notification xuất hiện!

### 2. Test Firebase Cloud Messaging

#### Lấy FCM Token:
- Copy token từ màn hình demo (nút **Copy Token**)

#### Gửi từ Firebase Console:
1. Vào: https://console.firebase.google.com
2. Chọn project của bạn
3. Cloud Messaging → Send test message
4. Paste FCM token
5. Nhấn **Test**

### 3. Test Topic Subscription
1. Bật switch **Subscribe to "plants" topic**
2. Từ Firebase Console, gửi notification đến topic `plants`
3. Tất cả devices đã subscribe sẽ nhận được!

## 📱 Các Tính Năng

✨ **Local Notifications** - Gửi notification từ app
✨ **Remote Notifications** - Nhận từ Firebase (foreground/background/terminated)
✨ **Topic Subscription** - Subscribe/unsubscribe topics
✨ **Message History** - Xem lịch sử notifications nhận được
✨ **FCM Token** - Copy token để test

## 📂 Files Quan Trọng

```
lib/
├── core/services/
│   └── firebase_notification_service.dart   # ⭐ Service chính
├── presentation/screens/
│   └── push_notification_demo_screen.dart  # ⭐ Demo UI
└── main.dart                                # ⭐ Đã initialize FCM
```

## 🔄 Quay Về Login Screen

Khi test xong, uncomment dòng này trong `main.dart`:

```dart
// home: SignInPage(),  // ← Uncomment này
home: const PushNotificationDemoScreen(),  // ← Comment hoặc xóa này
```

## 📖 Chi Tiết Hơn

Xem file `FIREBASE_PUSH_NOTIFICATION_GUIDE.md` để:
- Setup iOS
- Integrate vào production
- Send từ backend API
- Best practices
- Troubleshooting

## 🎯 Use Cases

### Trong App Plantheon:
1. **Thông báo bệnh cây** - "Your plant may have leaf spot disease"
2. **Reminder tưới cây** - "Time to water your Monstera!"
3. **Tips hàng ngày** - "Did you know: Orchids love humidity"
4. **Community updates** - "New post in Plants Care group"
5. **Admin announcements** - Broadcast to all users

### Ví dụ Code:

```dart
// Anywhere in your app
FirebaseNotificationService().messageStream.listen((message) {
  // Navigate based on notification data
  if (message.data['type'] == 'plant_disease') {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DiseaseDetailScreen(
          diseaseId: message.data['disease_id'],
        ),
      ),
    );
  }
});
```

## ❓ Troubleshooting

**Không nhận được notification?**
- ✅ Check internet
- ✅ Verify FCM token không null
- ✅ Check Firebase project configuration
- ✅ Android 13+: Xem permission notification đã granted chưa

**Token null?**
- Chờ 2-3 giây sau khi app start
- Check Firebase đã initialize trong console log

## 🎨 Screenshots

Màn hình demo bao gồm:
- 📋 FCM Token section (copy token)
- ✉️ Send local notification form
- 🔔 Topic subscription toggle
- 📜 Received messages list
- 📖 Instructions guide

---

**Happy Coding! 🎉**

Questions? Check `FIREBASE_PUSH_NOTIFICATION_GUIDE.md` or ask me!
