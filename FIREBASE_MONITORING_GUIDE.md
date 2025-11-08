# Firebase Push Notification Monitoring Guide

## 🔥 Monitor trên Firebase Console

### 1. **Cloud Messaging Dashboard**
```
URL: https://console.firebase.google.com/project/kltn-d256a/messaging
```

**Xem được:**
- ✅ Total messages sent
- ✅ Delivery rate
- ✅ Open rate (nếu có analytics)
- ✅ Failed deliveries

### 2. **Analytics - Events**
```
URL: https://console.firebase.google.com/project/kltn-d256a/analytics/events
```

**Track events:**
- `notification_sent` - Khi gửi notification
- `notification_received` - Khi user nhận được
- `notification_opened` - Khi user tap vào notification

### 3. **DebugView (Real-time)**
```
URL: https://console.firebase.google.com/project/kltn-d256a/analytics/debugview
```

Xem events real-time khi test trên device.

**Enable DebugView:**
```bash
# Android
adb shell setprop debug.firebase.analytics.app com.example.se501_plantheon

# iOS
flutter run --dart-define=FIREBASE_ANALYTICS_DEBUG_MODE=true
```

## 📱 Monitor Local Notifications

### Check Android Logs:
```bash
flutter logs | grep -i "notification\|firebase"
```

### Check Notification Permission:
```bash
adb shell dumpsys notification_listener
```

## 🔧 Troubleshooting - Tại sao không thấy notification?

### 1. Check Permission (Android 13+)
Vào **Settings → Apps → Plantheon → Notifications**
- Ensure "All notifications" is **ON**

### 2. Check Notification Channel
```bash
adb shell dumpsys notification | grep -A 5 "se501_plantheon"
```

### 3. Test Manual Notification
Vào màn hình **Push Notification Demo** trong app:
- Nhập title & body
- Nhấn "Send Local Notification"
- Nếu hiện → Permission OK
- Nếu không hiện → Permission bị block

### 4. Check Do Not Disturb
- Settings → Sound → Do Not Disturb: **OFF**

### 5. Check App Battery Optimization
- Settings → Battery → App battery usage
- Find "Plantheon" → Set to **Unrestricted**

## 📊 Firebase Analytics Integration

Để track notifications trong Firebase Analytics, thêm code:

```dart
import 'package:firebase_analytics/firebase_analytics.dart';

class NotificationAnalytics {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  // Log khi gửi notification
  static Future<void> logNotificationSent({
    required String type,
    required String title,
  }) async {
    await _analytics.logEvent(
      name: 'notification_sent',
      parameters: {
        'type': type,
        'title': title,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
  
  // Log khi user tap notification
  static Future<void> logNotificationOpened({
    required String type,
    required String source,
  }) async {
    await _analytics.logEvent(
      name: 'notification_opened',
      parameters: {
        'type': type,
        'source': source,
      },
    );
  }
}
```

## 🎯 Real Use Case - Monitor Chi Tiêu Notifications

### Tracking Flow:
1. **User tạo chi tiêu** với cảnh báo "Trước 5 phút"
2. **Log event:** `expense_alert_scheduled`
3. **5 phút trước:** Gửi notification
4. **Log event:** `expense_alert_sent`
5. **User tap notification:** `expense_alert_opened`
6. **Navigate to detail:** `expense_detail_viewed`

### Firebase Console sẽ show:
```
Funnel Analysis:
├─ expense_alert_scheduled: 100 users
├─ expense_alert_sent: 95 users (95% delivery)
├─ expense_alert_opened: 60 users (63% open rate)
└─ expense_detail_viewed: 55 users (92% engagement)
```

## 🔍 Debug Commands

### Check if Firebase initialized:
```bash
flutter logs | grep "Firebase"
```

### Check FCM Token:
```bash
flutter logs | grep "FCM Token"
```

### Check notification sent:
```bash
flutter logs | grep "🔔"
```

### Monitor all Firebase events:
```bash
adb logcat | grep -i "firebase\|fcm\|notification"
```

## 📈 KPIs to Monitor

### Delivery Metrics:
- **Send Success Rate**: (Sent / Attempted) × 100%
- **Delivery Rate**: (Delivered / Sent) × 100%
- **Device Availability**: Devices online when sent

### Engagement Metrics:
- **Open Rate**: (Opened / Delivered) × 100%
- **Click-through Rate**: (Clicked / Opened) × 100%
- **Time to Open**: Avg time từ khi nhận đến khi tap

### Technical Metrics:
- **Token Refresh Rate**: How often FCM tokens expire
- **Error Rate**: Failed deliveries
- **Permission Granted Rate**: Users who accept notification permission

## 🚀 Next Steps

1. **Add Firebase Analytics** package
2. **Implement tracking** trong notification service
3. **Create custom dashboard** trong Firebase Console
4. **Set up alerts** cho delivery failures
5. **A/B test** notification messages

## 📚 Resources

- [Firebase Cloud Messaging Docs](https://firebase.google.com/docs/cloud-messaging)
- [Firebase Analytics Events](https://firebase.google.com/docs/analytics/events)
- [Debug Firebase on Android](https://firebase.google.com/docs/analytics/debugview)
