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

  // GitHub Pages domain configuration
  static const String _httpsHost = 'kkuyen.github.io';
  static const String _httpsPathPrefix = '/plantheon-links';
  static const String _customScheme = 'plantheon';

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
    } catch (e) {}

    // Listen to incoming links
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleLink(uri, navigatorKey);
    }, onError: (err) {});
  }

  void _handleLink(Uri uri, GlobalKey<NavigatorState>? navigatorKey) {
    String? postId;

    // Handle Custom URL Scheme: plantheon://post?id=123
    if (uri.scheme == _customScheme && uri.host == 'post') {
      postId = uri.queryParameters['id'];
    }

    // Handle App Links: https://kkuyen.github.io/plantheon-links/post?id=123
    if (uri.scheme == 'https' && uri.host == _httpsHost) {
      if (uri.path.startsWith('$_httpsPathPrefix/post')) {
        postId = uri.queryParameters['id'];
      }
    }

    // Navigate to post detail if postId found
    if (postId != null && navigatorKey != null) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (context) => PostDetail(postId: postId!)),
      );
    }
  }

  /// Generates a deep link and shares it.
  /// Example: host='post', params={'id': '123'}
  /// Result: https://kkuyen.github.io/plantheon-links/post?id=123
  Future<void> shareLink({
    required String host,
    String? path,
    Map<String, String>? params,
    String? subject,
    String? text,
  }) async {
    final Uri uri = Uri(
      scheme: 'https',
      host: _httpsHost,
      path: '$_httpsPathPrefix/$host${path ?? ''}',
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
      scheme: 'https',
      host: _httpsHost,
      path: '$_httpsPathPrefix/$host${path ?? ''}',
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
