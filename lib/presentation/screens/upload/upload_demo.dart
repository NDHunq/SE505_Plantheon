import 'package:flutter/material.dart';
import 'package:se501_plantheon/presentation/screens/upload/file_upload_screen.dart';

/// File này để demo màn hình upload
/// Để test, thêm route này vào Navigator hoặc chạy trực tiếp
class UploadDemo extends StatelessWidget {
  const UploadDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return const FileUploadScreen();
  }
}

/// Hoặc để test nhanh, có thể thay đổi home trong main.dart thành:
/// home: const FileUploadScreen(),