import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:se501_plantheon/presentation/screens/community/post_detail.dart';
import 'package:toastification/toastification.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  /// Initializes the Deep Link Service.
  /// Use [context] if you need to perform navigation immediately (e.g., via Navigator).
  /// Note: Ideally, use a GlobalKey<NavigatorState> for navigation if not using context.
  Future<void> initialize({GlobalKey<NavigatorState>? navigatorKey}) async {
    _appLinks = AppLinks();

    // Check initial link
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) {
        _handleLink(uri, navigatorKey);
      }
    } catch (e) {
      debugPrint('Error getting initial link: $e');
    }

    // Listen to incoming links
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        _handleLink(uri, navigatorKey);
      },
      onError: (err) {
        debugPrint('Deep Link Error: $err');
      },
    );
  }

  void _handleLink(Uri uri, GlobalKey<NavigatorState>? navigatorKey) {
    debugPrint('Received Deep Link: $uri');
    // Example: plantheon://post?id=123

    // Check scheme
    if (uri.scheme != 'plantheon') return;

    // Handle different paths
    if (uri.host == 'post') {
      final String? postId = uri.queryParameters['id'];
      if (postId != null && navigatorKey != null) {
        // Navigate to post details
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (context) => PostDetail(postId: postId)),
        );
      }
    }

    // For now, just logging. Expand this method based on your routing needs.
  }

  /// Generates a deep link and shares it.
  /// Example: scheme='plantheon', host='post', path='', params={'id': '123'}
  /// Result: plantheon://post?id=123
  Future<void> shareLink({
    required String host,
    String? path,
    Map<String, String>? params,
    String? subject,
    String? text,
  }) async {
    final Uri uri = Uri(
      scheme: 'plantheon',
      host: host,
      path: path,
      queryParameters: params,
    );

    final String link = uri.toString();
    await Share.share(link, subject: subject);
  }

  /// Generates a deep link, copies it to clipboard, and shows a snackbar.
  Future<void> copyLinkToClipboard(
    BuildContext context, {
    required String host,
    String? path,
    Map<String, String>? params,
  }) async {
    final Uri uri = Uri(
      scheme: 'plantheon',
      host: host,
      path: path,
      queryParameters: params,
    );

    final String link = uri.toString();
    await Clipboard.setData(ClipboardData(text: link));

    if (context.mounted) {
      toastification.show(
        context: context,
        type: ToastificationType.success,
        style: ToastificationStyle.flat,
        title: const Text('Đã sao chép liên kết vào bộ nhớ tạm'),
        autoCloseDuration: const Duration(seconds: 2),
        alignment: Alignment.bottomCenter,
        showProgressBar: true,
        icon: const Icon(Icons.check_circle, color: AppColors.primary_main),
      );
    }
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}
