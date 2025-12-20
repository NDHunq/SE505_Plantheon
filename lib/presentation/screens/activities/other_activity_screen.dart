import 'package:flutter/material.dart';

class OtherActivityScreen extends StatelessWidget {
  const OtherActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hoạt Động Khác')),
      body: const Center(child: Text('Màn hình Hoạt Động Khác')),
    );
  }
}