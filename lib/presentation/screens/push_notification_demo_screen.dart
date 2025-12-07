import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:se501_plantheon/core/services/firebase_notification_service.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:toastification/toastification.dart';

class PushNotificationDemoScreen extends StatefulWidget {
  const PushNotificationDemoScreen({super.key});

  @override
  State<PushNotificationDemoScreen> createState() =>
      _PushNotificationDemoScreenState();
}

class _PushNotificationDemoScreenState
    extends State<PushNotificationDemoScreen> {
  final FirebaseNotificationService _notificationService =
      FirebaseNotificationService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final TextEditingController _topicController = TextEditingController();

  String? _fcmToken;
  List<RemoteMessage> _messages = [];
  bool _isSubscribedToPlants = false;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _setupMessageListener();
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
    setState(() {
      _fcmToken = _notificationService.fcmToken;
    });
  }

  void _setupMessageListener() {
    _notificationService.messageStream.listen((RemoteMessage message) {
      setState(() {
        _messages.insert(0, message);
      });

      // Show snackbar when message received
      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.info,
          style: ToastificationStyle.flat,
          title: Text(
            'New notification: ${message.notification?.title ?? "No title"}',
          ),
          autoCloseDuration: const Duration(seconds: 3),
          alignment: Alignment.bottomCenter,
          showProgressBar: true,
        );
      }
    });
  }

  Future<void> _sendLocalNotification() async {
    if (_titleController.text.isEmpty || _bodyController.text.isEmpty) {
      toastification.show(
        context: context,
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
        title: Text('Please enter both title and body'),
        autoCloseDuration: const Duration(seconds: 3),
        alignment: Alignment.bottomCenter,
        showProgressBar: true,
      );
      return;
    }

    await _notificationService.sendLocalNotification(
      title: _titleController.text,
      body: _bodyController.text,
      payload: 'test_payload',
    );

    _titleController.clear();
    _bodyController.clear();

    if (mounted) {
      toastification.show(
        context: context,
        type: ToastificationType.success,
        style: ToastificationStyle.flat,
        title: Text('Local notification sent!'),
        autoCloseDuration: const Duration(seconds: 3),
        alignment: Alignment.bottomCenter,
        showProgressBar: true,
      );
    }
  }

  Future<void> _toggleTopicSubscription(String topic) async {
    if (_isSubscribedToPlants) {
      await _notificationService.unsubscribeFromTopic(topic);
      setState(() {
        _isSubscribedToPlants = false;
      });
      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.info,
          style: ToastificationStyle.flat,
          title: Text('Unsubscribed from $topic'),
          autoCloseDuration: const Duration(seconds: 3),
          alignment: Alignment.bottomCenter,
          showProgressBar: true,
        );
      }
    } else {
      await _notificationService.subscribeToTopic(topic);
      setState(() {
        _isSubscribedToPlants = true;
      });
      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.success,
          style: ToastificationStyle.flat,
          title: Text('Subscribed to $topic'),
          autoCloseDuration: const Duration(seconds: 3),
          alignment: Alignment.bottomCenter,
          showProgressBar: true,
        );
      }
    }
  }

  void _copyTokenToClipboard() {
    if (_fcmToken != null) {
      Clipboard.setData(ClipboardData(text: _fcmToken!));
      toastification.show(
        context: context,
        type: ToastificationType.success,
        style: ToastificationStyle.flat,
        title: Text('FCM Token copied to clipboard!'),
        autoCloseDuration: const Duration(seconds: 2),
        alignment: Alignment.bottomCenter,
        showProgressBar: true,
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Push Notification Demo'),
        backgroundColor: AppColors.primary_main,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // FCM Token Section
            _buildSectionCard(
              title: 'FCM Token',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: SelectableText(
                      _fcmToken ?? 'Loading...',
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _copyTokenToClipboard,
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy Token'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary_main,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Send Local Notification Section
            _buildSectionCard(
              title: 'Send Local Notification',
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: AppColors.primary_main,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _bodyController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Body',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: AppColors.primary_main,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _sendLocalNotification,
                    icon: const Icon(Icons.send),
                    label: const Text('Send Local Notification'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary_main,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Topic Subscription Section
            _buildSectionCard(
              title: 'Topic Subscription',
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Subscribe to "plants" topic',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Switch(
                        value: _isSubscribedToPlants,
                        onChanged: (value) =>
                            _toggleTopicSubscription('plants'),
                        activeColor: AppColors.primary_main,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isSubscribedToPlants
                        ? '✓ You will receive notifications for plants topic'
                        : '✗ Not subscribed to plants topic',
                    style: TextStyle(
                      fontSize: 12,
                      color: _isSubscribedToPlants
                          ? Colors.green[700]
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Received Messages Section
            _buildSectionCard(
              title: 'Received Messages (${_messages.length})',
              child: _messages.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.notifications_none,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No messages received yet',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _messages.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary_main,
                            child: const Icon(
                              Icons.notifications,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            message.notification?.title ?? 'No Title',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(message.notification?.body ?? 'No Body'),
                              const SizedBox(height: 4),
                              Text(
                                'Data: ${message.data.toString()}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          isThreeLine: true,
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),

            // Instructions Section
            _buildSectionCard(
              title: 'How to Test',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInstructionItem(
                    number: '1',
                    text: 'Copy the FCM token above',
                  ),
                  _buildInstructionItem(
                    number: '2',
                    text:
                        'Go to Firebase Console > Cloud Messaging > Send test message',
                  ),
                  _buildInstructionItem(
                    number: '3',
                    text: 'Paste the token and send a notification',
                  ),
                  _buildInstructionItem(
                    number: '4',
                    text:
                        'Or use the "Send Local Notification" feature above for quick testing',
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Topic subscriptions allow you to send notifications to multiple devices at once.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[900],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem({required String number, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: AppColors.primary_main,
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
